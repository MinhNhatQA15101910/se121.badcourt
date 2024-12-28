const socket = io("ws://localhost:3000");
const token =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3NWQ4ZDFiZjhhODJjYTk0OGFjOTYwYSIsImlhdCI6MTczNTM2MTk4MH0.JAhFHhPpdftwRhWP3Y6jNplv0cQ_irjNPYIYtrlnUW0";

const currentUserId = document.querySelector("#currUserId");
const currentUserEmail = document.querySelector("#currEmail");

const emailInput = document.querySelector("#email");
const passwordInput = document.querySelector("#password");
const roleInput = document.querySelector("#role");

document
  .querySelector("#btnGetCurrentUser")
  .addEventListener("click", getCurrentUser);

function getCurrentUser(e) {
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
