Makes use of the Ballerina Gmail connector to pull emails from the Inbox based on a specific filter

# Module Overview
Makes use of the Ballerina Gmail connector to pull emails from the Inbox based on a specific filter. Scan the Subject of the Email and extract data to export to a Google spreadsheet using the Gsheets connector.

## Gmail API and Gsheets API Credentials

Use [this](https://docs.wso2.com/display/IntegrationCloud/Get+Credentials+from+Gmail) tutorial to obtain the necessary configs for Gmail.

Use [this](https://docs.wso2.com/display/IntegrationCloud/Get+Credentials+for+Google+Spreadsheet) tutorial to obtain the necessary configs for Gsheets.

## How to Build

- Create a Ballerina.conf file with the `ACCESS_TOKEN`, `CLIENT_ID`, `CLIENT_SECRET` and `REFRESH_TOKEN` in the root directory of the project. Also add the `SHEET_ID` and `SHEET_NAME` of the Gsheet you want the data to be uploaded to. Refer the `resources` directory in the GmailProject repository for a sample ballerina.conf file
- Build the Ballerina project using the following command

    ```bash
    ballerina build gm_module
    ```

- Run the generated Jar file using the following command. This will start up the service

    ```bash
    java -jar target/bin/gm_module.jar
    ```

- Invoke the service using the following curl command

    ```bash
    curl -X GET http://localhost:8080/invitation/getInvitation
    ```
