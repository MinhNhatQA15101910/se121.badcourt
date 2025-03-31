"use client";

import { useEffect, useState } from "react";
import { usePathname, useSearchParams, useRouter } from "next/navigation";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

// Hàm chuyển đổi pathname thành tiêu đề trang (viết hoa từng từ)
const getPageTitle = (pathname: string) => {
  const segments = pathname.split("/").filter(Boolean);
  const lastSegment = segments.pop() || "Dashboard";

  return lastSegment
    .replace(/[-_]/g, " ")
    .replace(/\b\w/g, (char) => char.toUpperCase());
};

const searchPlaceholders: Record<string, string> = {
  "/facility-confirm": "Tìm kiếm cơ sở cầu lông...",
  "/customers": "Tìm kiếm người chơi...",
  "/facility-owner": "Tìm kiếm chủ sân...",
  "/post": "Tìm kiếm bài viết...",
};

interface HeaderContentProps {
  searchPlaceholder?: string;
  className?: string;
}

export function HeaderContent({
  searchPlaceholder,
  className,
}: HeaderContentProps) {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const router = useRouter();

  const [searchQuery, setSearchQuery] = useState(searchParams.get("q") || "");

  useEffect(() => {
    setSearchQuery(searchParams.get("q") || "");
  }, [searchParams]);

  const pagesWithSearch = Object.keys(searchPlaceholders);
  const showSearch = pagesWithSearch.includes(pathname);

  // Nếu `searchPlaceholder` không được truyền từ props, lấy từ danh sách
  const computedPlaceholder =
    searchPlaceholder || searchPlaceholders[pathname] || "Tìm kiếm...";

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const query = e.target.value;
    setSearchQuery(query);

    const newParams = new URLSearchParams(searchParams);
    if (query) {
      newParams.set("q", query);
    } else {
      newParams.delete("q");
    }
    router.push(`${pathname}?${newParams.toString()}`, { scroll: false });
  };

  return (
    <div
      className={cn(
        "flex items-center justify-between gap-4 w-full p-6",
        className
      )}
    >
      <h1 className="w-60 text-2xl font-medium text-white">
        {getPageTitle(pathname)}
      </h1>
      {showSearch && (
        <div className="relative w-full ml-8 mr-8">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-white/70" />
          <Input
            type="search"
            value={searchQuery}
            onChange={handleSearchChange}
            placeholder={computedPlaceholder}
            className="pl-9 bg-light-green/20 border-light-green/30 text-white placeholder:text-white/70 focus-visible:ring-light-green"
          />
        </div>
      )}
    </div>
  );
}
