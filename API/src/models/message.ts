import mongoose from "mongoose";
import { AppMessageSchema } from "../schemas/messages/appMessage.schema";

const Message = mongoose.model("Message", AppMessageSchema);

export default Message;
