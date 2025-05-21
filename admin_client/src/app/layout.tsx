import type React from "react";
import { Inter } from "next/font/google";
import "./globals.css";
import AppContent from "./app-content";
import { Providers } from "./providers";

const inter = Inter({ subsets: ["latin"], variable: "--font-inter" });

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body
        className={`${inter.className} antialiased min-h-screen w-screen overflow-hidden`}
      >
        <Providers>
          <AppContent>{children}</AppContent>
        </Providers>
      </body>
    </html>
  );
}
