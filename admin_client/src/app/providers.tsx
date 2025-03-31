"use client"

import type React from "react"

import { LoadingProvider } from "@/contexts/LoadingContext"
import { SessionProvider } from "next-auth/react"

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>
      <LoadingProvider>{children}</LoadingProvider>
    </SessionProvider>
  )
}

