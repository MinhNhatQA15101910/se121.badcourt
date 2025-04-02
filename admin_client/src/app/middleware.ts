import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { getToken } from "next-auth/jwt";

// Define valid routes for the application
const VALID_ROUTES = [
  "/dashboard",
  "/facility-confirm",
  "/facility-owners",
  "/customers",
  "/post",
  "/message",
  "/setting",
  "/login",
  "/facility-owners-detail/", // Allow dynamic paths under this route
  // Add any other valid routes here
];

// Special paths that should be excluded from middleware processing
const EXCLUDED_PATHS = [
  "/api/",
  "/_next/",
  "/favicon.ico",
  "/images/",
  "/logo",
  // Add any other excluded paths here
];

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Skip middleware for excluded paths
  if (EXCLUDED_PATHS.some((path) => pathname.startsWith(path))) {
    return NextResponse.next();
  }

  const token = await getToken({
    req: request,
    secret: process.env.NEXTAUTH_SECRET,
  });
  const isAuthPage = pathname === "/login";
  const isRootPage = pathname === "/";

  // Check if the current path is valid
  const isValidRoute = VALID_ROUTES.some(
    (route) =>
      pathname === route ||
      (route !== "/login" && pathname.startsWith(`${route}/`)) ||
      /^\/facility-owners-detail\/[\w\d]+$/.test(pathname) // Cho phép động
  );
  console.log("Path:", pathname);
console.log("IsValidRoute:", isValidRoute);
console.log("Token exists:", !!token);
  

  // If at root path, redirect to dashboard or login based on auth status
  if (isRootPage) {
    return token
      ? NextResponse.redirect(new URL("/dashboard", request.url))
      : NextResponse.redirect(new URL("/login", request.url));
  }

  // If on login page and authenticated, redirect to dashboard
  if (isAuthPage && token) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  // If not authenticated and not on login page, redirect to login
  if (!token && !isAuthPage) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  // If authenticated but on an invalid route, redirect to dashboard
  if (token && !isValidRoute) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  // If not authenticated and on an invalid route, redirect to login
  if (!token && !isValidRoute) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return NextResponse.next();
}

// Add the paths that should be processed by middleware
export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones we explicitly exclude
     */
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
};
