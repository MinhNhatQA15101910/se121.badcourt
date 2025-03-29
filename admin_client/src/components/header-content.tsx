"use client";

import { useEffect, useMemo, useState } from "react";
import { usePathname } from "next/navigation";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

interface HeaderContentProps {
  pageName?: string;
  showSearch?: boolean;
  searchPlaceholder?: string;
  className?: string;
}

export function HeaderContent({
  pageName,
  showSearch = true,
  searchPlaceholder,
  className,
}: HeaderContentProps) {
  const isClient = typeof window !== "undefined";

  // eslint-disable-next-line react-hooks/rules-of-hooks
  const pathname = isClient ? usePathname() : "/";
  const [currentPageName, setCurrentPageName] = useState(pageName || "Dashboard");

  useEffect(() => {
    if (!pageName) {
      setCurrentPageName(getPageNameFromPath(pathname));
    }
  }, [pathname, pageName]);

  const currentPlaceholder = useMemo(
    () => searchPlaceholder || getSearchPlaceholderFromPath(pathname),
    [pathname, searchPlaceholder]
  );

  return (
    <div className={cn("flex items-center justify-between gap-4 w-full p-6", className)}>
      <h1 className="text-2xl font-medium text-white">{currentPageName}</h1>

      {showSearch && (
        <div className="relative w-full ml-8 mr-8">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-white/70" />
          <Input
            type="search"
            placeholder={currentPlaceholder}
            className="pl-9 bg-light-green/20 border-light-green/30 text-white placeholder:text-white/70 focus-visible:ring-light-green"
          />
        </div>
      )}
    </div>
  );
}

// Helper function to get page name from path
function getPageNameFromPath(path: string): string {
  if (!path || path === "/") return "Dashboard";

  const segment = path.split("/")[1] || "Dashboard";
  return segment.charAt(0).toUpperCase() + segment.slice(1).replace(/-/g, " ");
}

// Helper function to get search placeholder based on path
function getSearchPlaceholderFromPath(path: string): string {
  const placeholderMap: { [key: string]: string } = {
    "/users": "Tìm kiếm người dùng...",
    "/products": "Tìm kiếm sản phẩm...",
    "/orders": "Tìm kiếm đơn hàng...",
    "/reports": "Tìm kiếm báo cáo...",
    "/settings": "Tìm kiếm cài đặt...",
  };

  return placeholderMap[path] || "Tìm kiếm...";
}
