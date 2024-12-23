import mongoose from "mongoose";
import { AppMessageRoomSchema } from "../schemas/messages/appMessageRoom.schema";

const MessageRoom = mongoose.model("MessageRoom", AppMessageRoomSchema);

export default MessageRoom;
