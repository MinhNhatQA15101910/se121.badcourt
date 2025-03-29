"use client";

import type React from "react";
import { Inter } from "next/font/google";
import {
  SidebarInset,
  SidebarProvider,
  SidebarTrigger,
} from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/app-sidebar";
import { Separator } from "@/components/ui/separator";
import { AccountDropdown } from "@/components/account-dropdown";
import { useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { SessionProvider } from "next-auth/react";
import "./globals.css";
import { NotificationDropdown } from "@/components/notification-dropdown";
import { HeaderContent } from "@/components/header-content";

const inter = Inter({ subsets: ["latin"], variable: "--font-inter" });

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body
        className={`${inter.variable} antialiased min-h-screen w-screen overflow-auto`}
      >
        <SessionProvider>
          <LayoutContent>{children}</LayoutContent>
        </SessionProvider>
      </body>
    </html>
  );
}

function LayoutContent({ children }: { children: React.ReactNode }) {
  const { data: session, status } = useSession();
  const router = useRouter();

  useEffect(() => {
    if (status === "unauthenticated") {
      router.push("/login");
    }
  }, [status, router]);

  if (status === "loading") {
    return (
      <div className="flex h-screen w-screen items-center justify-center text-lg">
        Loading...
      </div>
    );
  }

  return (
    <SidebarProvider>
      <div className="flex h-full w-full">
        {session ? (
          <>
            <AppSidebar />
            <div className="flex flex-col flex-1 h-full">
              <header className="flex flex-row h-16 shrink-0 items-center gap-2 bg-green">
                <div className="flex w-full items-center px-2">
                  <div className="flex-shrink-0">
                    <SidebarTrigger className="flex -ml-1 text-white hover:bg-light-green hover:text-green font-bold" />
                  </div>
                  <div className="flex-1 flex justify-center items-center">
                    <HeaderContent pageName="Dashboard" showSearch={true}   />
                  </div>
                  <NotificationDropdown />
                  <div className="flex-shrink-0 flex items-center gap-2">
                    <AccountDropdown
                      user={{
                        name: session.user?.name || "User 123",
                        email: session.user?.email || "",
                        avatar: session.user?.image || "",
                      }}
                    />
                    <Separator orientation="vertical" className="mr-2 h-4" />
                  </div>
                </div>
              </header>
              <SidebarInset className="flex-1 flex flex-col">
                <main className="flex-1 overflow-y-auto">{children}</main>
              </SidebarInset>
            </div>
          </>
        ) : (
          <main className="flex-1 h-full overflow-auto">{children}</main>
        )}
      </div>
    </SidebarProvider>
  );
}
