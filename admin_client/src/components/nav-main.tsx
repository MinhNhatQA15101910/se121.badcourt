"use client";

import { useState, useEffect } from "react";
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
  const [selectedItem, setSelectedItem] = useState<string | null>(null);

  useEffect(() => {
    if (items.length > 0) {
      setSelectedItem(items[0].title);
    }
  }, [items]);

  return (
    <SidebarGroup>
      <SidebarMenu>
        {items.map((item) => (
          <SidebarMenuItem key={item.title}>
            <SidebarMenuButton
              className="hover:bg-dark-green hover:text-white"
              asChild
              onClick={() => {
                if (item.action) {
                  item.action(); // Gọi action nếu có
                } else {
                  setSelectedItem(item.title);
                }
              }}
            >
              {item.url ? (
                <a
                  href={item.url}
                  className={`p-6 text-base font-medium flex items-center space-x-3
                    ${
                      selectedItem === item.title
                        ? "bg-green text-white"
                        : "bg-transparent text-dark-grey"
                    }`}
                >
                  {item.icon && <item.icon />}
                  <span>{item.title}</span>
                </a>
              ) : (
                <div
                  className={`p-6 text-base font-medium flex items-center space-x-3 cursor-pointer
                    ${
                      selectedItem === item.title
                        ? "bg-green text-white"
                        : "bg-transparent text-dark-grey"
                    }`}
                >
                  {item.icon && <item.icon />}
                  <span>{item.title}</span>
                </div>
              )}
            </SidebarMenuButton>
          </SidebarMenuItem>
        ))}
      </SidebarMenu>
    </SidebarGroup>
  );
}
