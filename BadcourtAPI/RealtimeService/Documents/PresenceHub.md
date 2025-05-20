# 📡 PresenceHub SignalR Documentation

## Overview

PresenceHub is a SignalR hub that manages **real-time online presence tracking** for users. Frontend clients can connect to this hub to:

- Notify others when a user goes online or offline
- Get a real-time list of currently online users

The hub is **authorized**, meaning only authenticated users can connect.

## 🔐 Authorization

The \[Authorize\] attribute on the hub ensures that only authenticated users with valid tokens can establish a connection. Clients **must provide a valid JWT access token** during the SignalR connection.

## 🔌 How to Connect (Frontend)

Use SignalR in your frontend to establish a connection to the hub, for example (in JavaScript with @microsoft/signalr):

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`javascriptCopyEditimport * as signalR from '@microsoft/signalr';  const connection = new signalR.HubConnectionBuilder()    .withUrl('https://your-api.com/hubs/presence', {      accessTokenFactory: () => getAccessToken(), // replace with your auth logic    })    .withAutomaticReconnect()    .build();  await connection.start();`

## 📥 Server-to-Client Events

The server can send the following **named events** (method names) to clients:

### 1\. "UserIsOnline"

**Description:** Triggered when another user comes online.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`javascriptCopyEditconnection.on("UserIsOnline", (userId) => {    console.log("User is online:", userId);  });`

### 2\. "UserIsOffline"

**Description:** Triggered when a user goes offline.

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`javascriptCopyEditconnection.on("UserIsOffline", (userId) => {    console.log("User is offline:", userId);  });`

### 3\. "GetOnlineUsers"

**Description:** Sends the **current list of all online users**. This is triggered:

- When a new user connects
- When a user disconnects

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`javascriptCopyEditconnection.on("GetOnlineUsers", (onlineUsers) => {    console.log("Online users:", onlineUsers);  });`

> onlineUsers is typically a list of user IDs (e.g., string\[\])

## 🔄 Lifecycle Summary

- When a user connects:

  - Their user ID is registered as online.
  - Other users are notified via "UserIsOnline".
  - All clients receive an updated "GetOnlineUsers" list.

- When a user disconnects:

  - Their connection ID is removed.
  - If no more active connections exist, the user is considered offline.
  - Other users are notified via "UserIsOffline".
  - All clients receive an updated "GetOnlineUsers" list.

## 🛠 Server Class Summary

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`csharpCopyEdit[Authorize]  public class PresenceHub(PresenceTracker presenceTracker) : Hub`

- **OnConnectedAsync()**:

  - Registers the user as online.
  - Sends updates to other clients.

- **OnDisconnectedAsync(Exception? exception)**:

  - Unregisters the user connection.
  - Notifies others if user goes fully offline.

## 📌 Notes for FE Developers

- Ensure SignalR connection is resilient (withAutomaticReconnect()).
- Use the correct hub endpoint: /hubs/presence.
- Register handlers before calling .start().
- Use accessTokenFactory for authentication.
