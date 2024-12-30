let token = "";
let messages = [];
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

// Create event listener
document
  .querySelector("#btnGetCurrentUser")
  .addEventListener("click", getCurrentUser);

document.querySelector("#formLogin").addEventListener("submit", login);

document
  .querySelector("#btnGetMessages")
  .addEventListener("click", getMessages);

document
  .querySelector("#formSendMessage")
  .addEventListener("submit", sendMessage);

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

function sendMessage(e) {
  e.preventDefault();

  const recipientId = recipientIdInput.value;

  // Send request to fetch personal room
  

  // Send request to create message room
  fetch("http://localhost:3000/api/messages/create-room", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      users: [recipientId],
    }),
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json();
    })
    .then((data) => {
      console.log("Response data:", data);
    })
    .catch((error) => {
      console.error("Error:", error);
    });
}

function getMessages(e) {
  e.preventDefault();

  const roomId = roomIdInput.value;

  fetch(`http://localhost:3000/api/messages?roomId=${roomId}`, {
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
    })
    .catch((error) => {
      console.error("Error:", error);
    });
}
