import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"
import { getToken } from "next-auth/jwt"

// Define valid routes for the application
const PUBLIC_ROUTES = ["/login", "/register", "/forgot-password"]

const PROTECTED_ROUTES = [
  "/dashboard",
  "/facility-confirm",
  "/facility-owners",
  "/customers",
  "/post",
  "/message",
  "/setting",
]

// Special paths that should be excluded from middleware processing
const EXCLUDED_PATHS = [
  "/api/",
  "/_next/",
  "/favicon.ico",
  "/images/",
  "/logo",
  // Add any other excluded paths here
]

// Dynamic route patterns (using regex)
const DYNAMIC_ROUTES = [
  /^\/facility-owners-detail\/[\w-]+$/,
  // Add other dynamic route patterns here
]

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Skip middleware for excluded paths
  if (EXCLUDED_PATHS.some((path) => pathname.startsWith(path))) {
    return NextResponse.next()
  }

  // Get the JWT token from the request
  const token = await getToken({
    req: request,
    secret: process.env.NEXTAUTH_SECRET,
  })

  const isAuthenticated = !!token
  const isPublicRoute = PUBLIC_ROUTES.some((route) => pathname === route || pathname.startsWith(`${route}/`))
  const isRootPage = pathname === "/"

  // Check if the current path is a valid protected route
  const isProtectedRoute =
    PROTECTED_ROUTES.some((route) => pathname === route || pathname.startsWith(`${route}/`)) ||
    DYNAMIC_ROUTES.some((pattern) => pattern.test(pathname))

  // Check if user has Admin role
  const isAdmin = token?.roles?.includes("Admin") || false

  // 1. Root path handling
  if (isRootPage) {
    return isAuthenticated
      ? NextResponse.redirect(new URL("/dashboard", request.url))
      : NextResponse.redirect(new URL("/login", request.url))
  }

  // 2. Public route handling
  if (isPublicRoute) {
    // If authenticated and on a public route (like login), redirect to dashboard
    if (isAuthenticated) {
      return NextResponse.redirect(new URL("/dashboard", request.url))
    }
    // Otherwise, allow access to public routes
    return NextResponse.next()
  }

  // 3. Protected route handling
  if (isProtectedRoute) {
    // If not authenticated, redirect to login
    if (!isAuthenticated) {
      return NextResponse.redirect(new URL("/login", request.url))
    }

    // Role-based access control
    // Only allow admins to access /customers
    if (pathname.startsWith("/customers") && !isAdmin) {
      return NextResponse.redirect(new URL("/unauthorized", request.url))
    }

    // User is authenticated and authorized, allow access
    return NextResponse.next()
  }

  // 4. Invalid route handling
  // If we get here, the route is neither public nor protected
  return isAuthenticated
    ? NextResponse.redirect(new URL("/dashboard", request.url))
    : NextResponse.redirect(new URL("/login", request.url))
}

// Add the paths that should be processed by middleware
export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones we explicitly exclude
     */
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
}
