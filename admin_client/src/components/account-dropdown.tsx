"use client"

import { Settings, ChevronDown, LogOut, UserRound } from "lucide-react"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { SidebarMenu, SidebarMenuButton, SidebarMenuItem} from "@/components/ui/sidebar"
import { signOut } from "next-auth/react"

export function AccountDropdown({
  user,
}: {
  user: {
    name: string
    email: string
    avatar: string
  }
}) {
  return (
    <SidebarMenu >
      <SidebarMenuItem>
        <DropdownMenu >
          <DropdownMenuTrigger asChild>
            <SidebarMenuButton
              size="lg"
              className="data-[state=open]:bg-dark-green data-[state=open]:text-sidebar-accent-foreground hover:bg-dark-green"            >
              <Avatar className="h-8 w-8 rounded-b-full">
                <AvatarImage src={user.avatar} alt={user.name} />
                <AvatarFallback className="rounded-lg text-xl font-semibold text-dark-green bg-light-green">{user.name.charAt(0).toUpperCase()}</AvatarFallback>
              </Avatar>
              <div className="grid flex-1 text-left text-sm leading-tight mr-2">
                <span className="truncate font-semibold text-white text-base">{user.name}</span>
                <span className="truncate text-white text-md">{user.email}</span>
              </div>
              <ChevronDown className="ml-auto size-4 text-white" />
            </SidebarMenuButton>
          </DropdownMenuTrigger>
          <DropdownMenuContent
            className="w-[--radix-dropdown-menu-trigger-width] min-w-56 rounded-lg"
            side={"bottom"}
            align="end"
            sideOffset={4}
          >
            <DropdownMenuLabel className="p-0 font-normal">
              <div className="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
                <Avatar className="h-8 w-8 rounded-b-full">
                  <AvatarImage src={user.avatar} alt={user.name} />
                  <AvatarFallback className="rounded-lg text-xl font-semibold text-dark-green bg-light-green">{user.name.charAt(0).toUpperCase()}</AvatarFallback>
                </Avatar>
                <div className="grid flex-1 text-left text-sm leading-tight">
                  <span className="truncate font-semibold">{user.name}</span>
                  <span className="truncate text-xs">{user.email}</span>
                </div>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuGroup>
              <DropdownMenuItem>
                <UserRound />
                Account
              </DropdownMenuItem>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuGroup>
              <DropdownMenuItem>
                <Settings />
                Setting
              </DropdownMenuItem>
              
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onSelect={() => {
                signOut({ callbackUrl: "/login" });
              }}
            >
              <LogOut />
              Log out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  )
}

