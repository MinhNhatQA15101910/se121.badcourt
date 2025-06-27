"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"
import { useSession } from "next-auth/react"
import LoadingScreen from "@/components/loading-creen"

export default function NotFound() {
  const router = useRouter()
  const { status } = useSession()

  useEffect(() => {
    // Short delay before redirecting to avoid flash of content
    const timer = setTimeout(() => {
      if (status === "authenticated") {
        router.replace("/dashboard")
      } else {
        router.replace("/login")
      }
    }, 1500)

    return () => clearTimeout(timer)
  }, [router, status])

  return (
    <div className="flex min-h-screen flex-col items-center justify-center">
      <LoadingScreen/>
    </div>
  )
}

