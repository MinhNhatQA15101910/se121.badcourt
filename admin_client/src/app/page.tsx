"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"

// Root page that redirects to /dashboard
export default function RootPage() {
  const router = useRouter()

  useEffect(() => {
    // Redirect to dashboard on component mount
    router.replace("/dashboard")
  }, [router])

  // Show a simple loading state while redirecting
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500"></div>
    </div>
  )
}

