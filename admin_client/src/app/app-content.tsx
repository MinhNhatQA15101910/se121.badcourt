"use client";

import type React from "react";
import {
  SidebarInset,
  SidebarProvider,
  SidebarTrigger,
} from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/app-sidebar";
import { HeaderContent } from "@/components/header-content";
import { AccountDropdown } from "@/components/account-dropdown";
import { NotificationDropdown } from "@/components/notification-dropdown";
import { useSession } from "next-auth/react";
import { usePathname } from "next/navigation";

export default function AppContent({
  children,
}: {
  children: React.ReactNode;
}) {
  const { data: session, status } = useSession();
  const pathname = usePathname();

  const isLoginPage = pathname === "/login";

  if (isLoginPage || status === "unauthenticated") {
    return <>{children}</>;
  }

  return (
    <SidebarProvider>
      <div className="flex h-screen w-full">
        <AppSidebar />
        <div className="flex flex-col flex-1 h-full">
          {/* Header cố định chiều cao */}
          <header className="h-16 shrink-0 flex items-center gap-2 bg-[#23C16B]">
            <div className="flex w-full items-center px-2">
              <div className="flex-shrink-0">
                <SidebarTrigger className="flex -ml-1 text-white hover:bg-light-green hover:text-green font-bold" />
              </div>
              <div className="flex-1 flex justify-center items-center">
                <HeaderContent />
              </div>
              <NotificationDropdown />
              <div className="flex-shrink-0 flex items-center gap-2 mr-6">
                <AccountDropdown
                  user={{
                    name: session?.user?.name || "User",
                    email: session?.user?.email || "",
                    avatar: session?.user?.image || "",
                  }}
                />
              </div>
            </div>
          </header>

          {/* Phần còn lại sẽ scroll nếu tràn */}
          <SidebarInset className="flex-1 flex flex-col">
            <main className="flex-1 overflow-y-auto mr-3">{children}</main>
          </SidebarInset>
        </div>
      </div>
    </SidebarProvider>
  );
}
