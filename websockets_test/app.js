let token = "";
let currUser = {};
const apiUrl = "http://localhost:3000/api/";
const socket = io("ws://localhost:3000", {
  extraHeaders: {
    Authorization: `Bearer ${token}`,
  },
});

const currentUserId = document.querySelector("#currUserId");
const currentUserEmail = document.querySelector("#currEmail");

const emailInput = document.querySelector("#inputEmail");
const passwordInput = document.querySelector("#inputPassword");
const roleInput = document.querySelector("#inputRole");

const recipientIdInput = document.querySelector("#inputRecipientId");
const roomIdInput = document.querySelector("#inputRoomId");
const messageInput = document.querySelector("#inputMessage");

// Socket events
socket.on("invokeEnterRoom", (roomId) => {
  console.log("Send request to enter room");
  socket.emit("enterRoom", roomId);
});

socket.on("newMessage", (message) => {
  messageInput.value = "";

  console.log("New message received:", message);
  const li = messageItem(message);
  document.querySelector("#messages").appendChild(li);
});

socket.on("messageRoom", (room) => {
  console.log(room);
});

// Create event listener
document
  .querySelector("#btnGetCurrentUser")
  .addEventListener("click", getCurrentUser);

document.querySelector("#formLogin").addEventListener("submit", login);

document
  .querySelector("#btnGetMessages")
  .addEventListener("click", getMessages);

document
  .querySelector("#btnSendMsgToUser")
  .addEventListener("click", sendMessageToUser);

document
  .querySelector("#btnSendMsgToRoom")
  .addEventListener("click", sendMessageToRoom);

// Functions
function login(e) {
  e.preventDefault();

  console.log(socket.id);

  fetch("http://localhost:3000/api/auth/login", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      email: emailInput.value,
      password: passwordInput.value,
      role: roleInput.value,
    }),
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then((data) => {
      token = data.token;

      socket.emit("login", data._id);

      currUser = data;
      console.log(currUser);

      emailInput.value = "";
      passwordInput.value = "";
      roleInput.value = "";
    })
    .catch((error) => {
      console.error("Error:", error);
    });
}

function getCurrentUser(e) {
  if (token === "") {
    console.log("No token provided");
    return;
  }

  e.preventDefault();

  fetch("http://localhost:3000/api/users/me", {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then((data) => {
      console.log("Response data:", data);
      currentUserId.value = data._id;
      currentUserEmail.value = data.email;
    })
    .catch((error) => {
      console.error("Error:", error);
    });
}

async function sendMessageToUser(e) {
  e.preventDefault();

  const recipientId = recipientIdInput.value;

  // Send request to fetch personal room
  let response = await fetch(`${apiUrl}messages/room/${recipientId}`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  });

  console.log(response);

  // Check if room exists
  let roomId = "";
  if (response.status === 404) {
    // Create new room
    console.log("Create new room");
    response = await fetch(`${apiUrl}messages/create-room`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        users: [recipientId],
      }),
    });

    console.log(response);

    const data = await response.json();
    roomId = data._id;
  } else {
    const data = await response.json();
    roomId = data._id;
  }

  // Send message to room
  const content = messageInput.value;
  await fetch(`${apiUrl}messages/send-to-room`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      roomId,
      content,
    }),
  });
}

async function sendMessageToRoom(e) {
  e.preventDefault();

  const roomId = roomIdInput.value;
  const content = messageInput.value;

  await fetch(`${apiUrl}messages/send-to-room`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      roomId,
      content,
    }),
  });
}

async function getMessages(e) {
  e.preventDefault();

  const roomId = roomIdInput.value;

  const response = await fetch(
    `http://localhost:3000/api/messages?roomId=${roomId}`,
    {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    }
  );

  let messages = await response.json();
  messages = messages.reverse();

  document.querySelector("#messages").innerHTML = "";
  for (let message of messages) {
    const li = messageItem(message);
    document.querySelector("#messages").appendChild(li);
  }
}

function formatMilliseconds(ms) {
  const date = new Date(ms);

  // Extract individual components
  const hours = String(date.getHours()).padStart(2, "0");
  const minutes = String(date.getMinutes()).padStart(2, "0");
  const seconds = String(date.getSeconds()).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  const month = String(date.getMonth() + 1).padStart(2, "0"); // Month is zero-based
  const year = date.getFullYear();

  // Combine into desired format
  return `${hours}:${minutes}:${seconds} ${day}/${month}/${year}`;
}

function messageItem(message) {
  const li = document.createElement("li");
  li.innerHTML = `<b>${message.senderId}</b> - ${
    message.content
  } - <i>${formatMilliseconds(message.createdAt)}</i>`;
  return li;
}
