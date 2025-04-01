"use client";

import { FacilityConfirmTable } from "@/components/facility-confirm-table";
import { useState, useEffect } from "react";

export default function FacilityConfirmPage() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return null;
  }

  return (
    <div className="min-h-full w-full p-6 overflow-y-auto">
      <div className="grid grid-cols-12 gap-6 overflow-y-auto">
        <div className="col-span-12">
          <FacilityConfirmTable />
        </div>
      </div>
    </div>
  );
}
