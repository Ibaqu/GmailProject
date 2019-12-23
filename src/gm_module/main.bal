import wso2/gmail;
import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerina/io;


//Gmail Client Configuration
gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        accessToken: config:getAsString("ACCESS_TOKEN"),
        refreshConfig: {
            refreshUrl: gmail:REFRESH_URL,
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET")
        }
    }
};

gmail:Client gmailClient = new(gmailConfig);


@http:ServiceConfig {
    basePath : "/invitation"
} service GmailInvitationService on new http:Listener(8080) {

    // Get a certain number of invitations from the email inbox
    @http:ResourceConfig {
        path : "/getInvitation",
        methods : ["GET"]
    } resource function getInvitation(http:Caller caller, http:Request request) {
        
        // HTTP Response to the Caller
        http:Response response = new();
        string responseMessage = "";
        
        // Gmail Information
        string userId = "me";
        string inboxLabel = "CATEGORY_PERSONAL";
        string searchQuery = "subject: Invitation";

        // Filter out emails in the personal inbox with search query "Invitation"
        gmail:MsgSearchFilter searchFilter = {
            includeSpamTrash: false, 
            labelIds: [inboxLabel], 
            maxResults: "50",
            q: searchQuery
        };

        // Obtain list of emails that satisfy the above search filter
        gmail:MessageListPage|error mailList = gmailClient->listMessages(userId, searchFilter);

        if (mailList is gmail:MessageListPage) {
            
            string invitationTopic = "";
            string invitationDate = ""; 
            string invitationTime = "";
            string subject = "";
            string[] labelIds = [];

            foreach json email in mailList.messages {
                string messageId = <@untainted><string>email.messageId;
                string threadId = <@untainted><string>email.threadId;

                //Read email using the message Id
                gmail:Message|error message = gmailClient->readMessage(userId, messageId);

                if (message is gmail:Message) {
                    subject = <@untainted>message.headerSubject;
                    labelIds = <@untainted>message.labelIds;

                    // String filter for certain types of Subjects
                    if (subject.startsWith("Invitation:") || subject.startsWith("Updated invitation:") ||subject.startsWith("Re: Updated invitation:") || subject.startsWith("Re: Invitation:")) {
                        
                        io:println("\nSubject : " + subject);
                        json jsonSubject = extractSubject(subject);

                        invitationTopic = jsonSubject.invitationTopic.toString();
                        invitationDate = jsonSubject.invitationDate.toString();
                        invitationTime = jsonSubject.invitationTime.toString();
                    
                        io:println("TOPIC : " + invitationTopic);
                        io:println("DATE ONLY : " + invitationDate);
                        io:println("TIME ONLY : " + invitationTime);
                    }
                } else {
                    responseMessage = "Failed to extract message : " + message.toString();
                    log:printError(responseMessage);
                }
            }
        } else {
            responseMessage = "Failed to retrieve Message List Page based on filter : " + mailList.toString();
            log:printError(responseMessage);
        }

        response.setTextPayload(<@untainted>responseMessage); 
        var result = caller->respond(response);

        if (result is error) {
            log:printError("Failed to Respond to Caller : " + result.toString());
        } 
    }
}

function extractSubject(string subject) returns json {
    string invitationTopic = subject.substring(0, <int>subject.indexOf("@"));
    string invitationDateAndTime = subject.substring(<int>subject.indexOf("@")+1, <int>subject.indexOf("(IST)"));
    string invitationDate = invitationDateAndTime.substring(0, <int>invitationDateAndTime.indexOf(",") + 6);
    string invitationTime = invitationDateAndTime.substring(<int>invitationDateAndTime.indexOf(",") + 6, invitationDateAndTime.length());

    json jsonSubject = {
        invitationTopic : invitationTopic,
        invitationDate : invitationDate,
        invitationTime : invitationTime
    };

    return jsonSubject;
}
