"use client"; 
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import Image from "next/image";

export default function LoginScreen() {
  return (
    <div className="relative w-full h-screen flex items-center justify-center bg-gray-100">
      {/* Background Image */}
      <div className="absolute inset-0">
        <Image
          src="/login-background.jpg"
          alt="Background"
          layout="fill"
          objectFit="cover"
          className="absolute inset-0 w-full h-full object-cover brightness-75"
        />
      </div>

      {/* Login Card */}
      <Card className="relative z-10 w-full max-w-md p-8 bg-white shadow-xl rounded-lg">
        <CardContent className="space-y-6">
          <div className="flex text-center gap-2 justify-center">
            <Image src="/logo.png" alt="/logo" width={50} height={50} />
            <h2 className="text-2xl font-bold mt-3 text-black-grey">BadCourt</h2>
          </div>
          <div className="space-y-4">
          <p className="text-black-grey text-xl font-medium">Login with admin</p>
            <Input type="email" placeholder="Email" className="w-full" />
            <Input type="password" placeholder="Password" className="w-full" />
            <Button className="w-full bg-green-500 hover:bg-green-600 text-white text-lg font-semibold py-2">
              Log in
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
