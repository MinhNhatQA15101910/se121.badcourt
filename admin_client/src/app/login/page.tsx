"use client";
import { useState, useEffect } from "react";
import type React from "react";

import { signIn, useSession } from "next-auth/react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import Image from "next/image";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const { status } = useSession();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  // Redirect to dashboard if already authenticated
  useEffect(() => {
    if (status === "authenticated") {
      router.replace("/dashboard");
    }
  }, [status, router]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    const result = await signIn("credentials", {
      redirect: false,
      email,
      password,
    });

    if (result?.ok) {
      router.push("/dashboard");
    } else {
      setError("Invalid email or password");
    }
  };

  // Don't render anything while checking authentication status
  if (status === "loading") {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-green-500"></div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen w-full bg-gray-100">
      {/* Background Image */}
      <div className="relative flex flex-1 items-center justify-center">
        <Image
          src="/login-background.jpg"
          alt="Background"
          fill
          className="absolute inset-0 w-full h-full object-cover"
        />

        {/* Login Card */}
        <Card className="relative z-10 w-full max-w-md bg-white shadow-xl rounded-lg">
          <CardContent className="space-y-6 px-8 py-6">
            <div className="flex text-center gap-2 justify-center">
              <Image src="/logo.png" alt="logo" width={50} height={50} />
              <h2 className="text-2xl font-bold mt-3 text-gray-700">
                BadCourt
              </h2>
            </div>
            <form onSubmit={handleLogin} className="space-y-4">
              <p className="text-gray-700 text-xl font-medium">
                Login with admin
              </p>
              {error && <p className="text-red-500 text-sm">{error}</p>}
              <Input
                type="email"
                placeholder="Email"
                className="w-full"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <Input
                type="password"
                placeholder="Password"
                className="w-full"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <Button
                type="submit"
                className="w-full bg-green-500 hover:bg-green-700 text-white text-lg font-semibold py-2"
              >
                Log in
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
