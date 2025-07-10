import React from "react";
import { PostTable } from "./_components/post-table";

function PostPage() {
  return (
        <div className="min-h-full w-full p-6 overflow-y-auto">
          <div className="grid grid-cols-12 gap-6 overflow-y-auto">
            <div className="col-span-12">
              <PostTable />
            </div>
          </div>
        </div>
  );
}

export default PostPage;
