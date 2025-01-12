import { Server } from "socket.io";
import User from "../models/user";

export const users = new Map<string, string>();

export const socketHandler = (io: Server) => {
  io.on("connection", (socket) => {
    console.log(`User ${socket.id} connected`);

    socket.on("login", async (userId) => {
      // Join rooms
      socket.join(userId);
      const user = await User.findById(userId);
      
      if (!user) {
        return;
      }

      for (const roomId of user.chatRooms) {
        socket.join(roomId);
      }

      users.set(userId, socket.id);
      console.log(users);
    });

    socket.on("enterRoom", (roomId) => {
      socket.join(roomId);
      console.log(`User ${socket.id} entered room ${roomId}`);
    });

    socket.on("disconnect", () => {
      console.log(`User ${socket.id} disconnected`);
    });
  });
};
