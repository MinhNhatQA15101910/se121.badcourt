import { Server } from "socket.io";

export const users = new Map<string, string>();

export const socketHandler = (io: Server) => {
  io.on("connection", (socket) => {
    console.log(`User ${socket.id} connected`);

    socket.on("login", (userId) => {
      users.set(userId, socket.id);
      console.log(users);
    });

    socket.on("disconnect", () => {
      console.log(`User ${socket.id} disconnected`);
    });
  });
};
