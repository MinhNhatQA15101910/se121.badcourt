"use client";

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
import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { NavMain } from "./nav-main";

const navMain = [
  { title: "Dashboard", url: "#", icon: LayoutDashboard, isActive: true },
  {title: "Facility Confirm", url: "#", icon: ClipboardCheck, isActive: false,},
  { title: "Facility Owners", url: "#", icon: UserCog, isActive: false },
  { title: "Customers", url: "#", icon: UserRoundCog, isActive: false },
  { title: "Post", url: "#", icon: Dribbble, isActive: false },
  { title: "Message", url: "#", icon: MessageSquare, isActive: false },
  { title: "Setting", url: "#", icon: Settings, isActive: false },
  { title: "Log Out", url: "/login", icon: LogOut, isActive: false },
];

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
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
        <div className="flex flex-col aspect-auto w-auto h-auto items-center justify-center rounded-lg text-sidebar-primary-foreground ml-6 mr-6 mt-4">
          <Image src="/info-sidebar.png" alt="Logo" width={200} height={150} />
        </div>
      </SidebarContent>
    </Sidebar>
  );
}
