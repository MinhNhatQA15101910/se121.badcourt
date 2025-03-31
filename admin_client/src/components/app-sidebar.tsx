"use client";

import type React from "react";

import Image from "next/image";
import {
  LayoutDashboard,
  ClipboardCheck,
  UserCog,
  UserRoundCog,
  Dribbble,
  MessageSquare,
  Settings,
  LogOut,
} from "lucide-react";
import { signOut } from "next-auth/react";

import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { NavMain } from "./nav-main";

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  // Define the navigation items with logout action
  const navMain = [
    { title: "Dashboard", url: "/dashboard", icon: LayoutDashboard },
    {
      title: "Facility Confirm",
      url: "/facility-confirm",
      icon: ClipboardCheck,
    },
    { title: "Facility Owners", url: "/facility-owners", icon: UserCog },
    { title: "Customers", url: "/customers", icon: UserRoundCog },
    { title: "Post", url: "/post", icon: Dribbble },
    { title: "Message", url: "/message", icon: MessageSquare },
    { title: "Setting", url: "/setting", icon: Settings },
    {
      title: "Log Out",
      icon: LogOut,
      action: () => {
        // Use next-auth's signOut function to log out and redirect to login page
        signOut({ callbackUrl: "/login" });
      },
    },
  ];

  return (
    <Sidebar collapsible="icon" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              size="lg"
              className="p-3 flex items-center gap-3 mb-4"
            >
              <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-transparent text-sidebar-primary-foreground">
                <Image src="/logo.png" alt="Logo" width={32} height={32} />
              </div>
              <span className="truncate font-semibold text-2xl">BadCourt</span>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <NavMain items={navMain} />
        <div className="relative flex flex-col w-auto h-auto items-center justify-center rounded-lg text-sidebar-primary-foreground ml-6 mr-6 mt-4">
          <Image
            src="/info-sidebar.png"
            alt="Logo"
            width={200}
            height={150}
            className="rounded-lg"
          />
          <div className="absolute inset-0 flex flex-col items-center justify-center text-white text-lg font-semibold space-y-1">
            {/* Logo */}
            <Image src="/logo-reverse.svg" alt="Logo" width={40} height={40} />

            {/* Tiêu đề */}
            <h2 className="text-lg font-bold">BadCourt</h2>

            {/* Mô tả */}
            <p className="text-center text-xs">
              Badcourt provides a variety of badminton training court options.
            </p>
          </div>
        </div>
      </SidebarContent>
    </Sidebar>
  );
}
