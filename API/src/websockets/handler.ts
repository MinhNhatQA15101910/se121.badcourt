import { Server } from "socket.io";

export const socketHandler = (io: Server) => {
  io.on("connection", (socket) => {
    console.log(`User ${socket.id} connected`);

    socket.on("disconnect", () => {
      console.log(`User ${socket.id} disconnected`);
    });
  });
};
