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
        string inboxLabel = "INBOX";
        string searchQuery = "subject:Invitation";

        // Filter out emails in the personal inbox with search query "Invitation"
        gmail:MsgSearchFilter searchFilter = {
            includeSpamTrash: false, 
            labelIds: [inboxLabel], 
            maxResults: "20",
            q: searchQuery
        };

        // Obtain list of emails that satisfy the above search filter
        gmail:MessageListPage|error mailList = gmailClient->listMessages(userId, searchFilter);

        if (mailList is gmail:MessageListPage) {

            foreach json email in mailList.messages {
                string messageId = <@untainted><string>email.messageId;
                string threadId = <@untainted><string>email.threadId;

                //Read email using the message Id
                gmail:Message|error message = gmailClient->readMessage(userId, messageId);

                if (message is gmail:Message) {
                    string subject = <@untainted>message.headerSubject;
                    string[] labelIds = <@untainted>message.labelIds;
                    
                    log:printInfo("Subject : " + subject);
                    foreach var labelId in labelIds {
                        io:println("Label : " + labelId);
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
