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
    url: string;
    icon?: LucideIcon;
  }[];
}) {
  const [selectedItem, setSelectedItem] = useState<string | null>(null);

  // Khi component mount, chọn phần tử đầu tiên nếu có items
  useEffect(() => {
    if (items.length > 0) {
      setSelectedItem(items[0].title);
    }
  }, [items]);

  return (
    <SidebarGroup>
      <SidebarMenu>
        {items.map((item) => (
          <SidebarMenuItem
            key={item.title}
            onClick={() => setSelectedItem(item.title)}
          >
            <SidebarMenuButton className="hover:bg-dark-green hover:text-white" asChild>
              <a
                href={item.url}
                className={`p-6 text-base font-medium flex items-center space-x-3
                    ${
                      selectedItem === item.title
                        ? "bg-green text-white" // Nếu được chọn, giữ màu xanh
                        : "bg-transparent text-dark-grey" // Nếu chưa chọn, giữ màu mặc định
                    }`}
              >
                {item.icon && <item.icon/>}
                <span>{item.title}</span>
              </a>
            </SidebarMenuButton>
          </SidebarMenuItem>
        ))}
      </SidebarMenu>
    </SidebarGroup>
  );
}
