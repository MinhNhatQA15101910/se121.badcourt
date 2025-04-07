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

  // Check if the current path is the login page
  const isLoginPage = pathname === "/login";

  // If we're on the login page or not authenticated, render without sidebar
  if (isLoginPage || status === "unauthenticated") {
    return <>{children}</>;
  }

  // Otherwise render the full app layout with sidebar
  return (
    <SidebarProvider>
      <div className="flex h-full w-full">
        <AppSidebar />
        <div className="flex flex-col flex-1 h-full">
          <header className="flex flex-row h-16 shrink-0 items-center gap-2 bg-green">
            <div className="flex w-full items-center px-2">
              <div className="flex-shrink-0">
                <SidebarTrigger className="flex -ml-1 text-white hover:bg-light-green hover:text-green font-bold" />
              </div>
              <div className="flex-1 flex justify-center items-center">
                <HeaderContent />
              </div>
              <NotificationDropdown />
              <div className="flex-shrink-0 flex items-center gap-2 mr-3">
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
          <SidebarInset className="flex-1 flex flex-col">
            <main className="flex-1 h-full overflow-y-auto mr-3">{children}</main>
          </SidebarInset>
        </div>
      </div>
    </SidebarProvider>
  );
}
