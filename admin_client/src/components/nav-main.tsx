"use client";

import { usePathname } from "next/navigation";
import { type LucideIcon } from "lucide-react";
import {
  SidebarGroup,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";

export function NavMain({
  items,
}: {
  items: {
    title: string;
    url?: string;
    action?: () => void;
    icon?: LucideIcon;
  }[];
}) {
  const pathname = usePathname(); // Lấy đường dẫn hiện tại

  return (
    <SidebarGroup>
      <SidebarMenu>
        {items.map((item) => {
          const isActive = item.url && pathname.startsWith(item.url); // Kiểm tra xem mục có đang được chọn không

          return (
            <SidebarMenuItem key={item.title}>
              <SidebarMenuButton
                className="hover:bg-dark-green hover:text-white"
                asChild
                onClick={() => {
                  if (item.action) {
                    item.action(); // Gọi action nếu có
                  }
                }}
              >
                {item.url ? (
                  <a
                    href={item.url}
                    className={`p-6 text-base font-medium flex items-center space-x-3
                      ${
                        isActive
                          ? "bg-[#23C16B] text-white"
                          : "bg-transparent text-dark-grey"
                      }
                    `}
                  >
                    {item.icon && <item.icon />}
                    <span>{item.title}</span>
                  </a>
                ) : (
                  <div
                    className={`p-6 text-base font-medium flex items-center space-x-3 cursor-pointer
                      ${
                        isActive
                          ? "bg-[#23C16B] text-white"
                          : "bg-transparent text-dark-grey"
                      }
                    `}
                  >
                    {item.icon && <item.icon />}
                    <span>{item.title}</span>
                  </div>
                )}
              </SidebarMenuButton>
            </SidebarMenuItem>
          );
        })}
      </SidebarMenu>
    </SidebarGroup>
  );
}
