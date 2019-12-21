# Gmail-Spreadsheet Integration Project

Makes use of the Ballerina Gmail connector to pull emails from the Inbox based on a specific filter. Scan the Subject of the Email and extract data to export to a spreadsheet

## How to Build

- Create a Ballerina.conf file with the ACCESS_TOKEN, CLIENT_ID, CLIENT_SECRET and REFRESH_TOKEN in the root directory of the project
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

## Current Iteration

- Simply pulls emails based on the filter and logs the result

## TODO

- Sort out the Gmail filter to pull personal emails only
- Extract the information from the Email subject by manipulating the subject string
- Upload the data to a spreadsheet
