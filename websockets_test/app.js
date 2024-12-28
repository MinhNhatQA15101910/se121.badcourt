const socket = io("ws://localhost:3000");
let token = "";

const currentUserId = document.querySelector("#currUserId");
const currentUserEmail = document.querySelector("#currEmail");

const emailInput = document.querySelector("#inputEmail");
const passwordInput = document.querySelector("#inputPassword");
const roleInput = document.querySelector("#inputRole");

// Create event listener
document
  .querySelector("#btnGetCurrentUser")
  .addEventListener("click", getCurrentUser);

document.querySelector("#formLogin").addEventListener("submit", login);

// Functions
function login(e) {
  e.preventDefault();

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

      emailInput.value = "";
      passwordInput.value = "";
      roleInput.value = "";
    })
    .catch((error) => {
      console.error("Error:", error);
    });
}

function getCurrentUser(e) {
  if (token === "") return;

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
