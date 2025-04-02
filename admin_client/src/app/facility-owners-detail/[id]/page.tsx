"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import { useParams, useRouter } from "next/navigation";
import {
  ArrowLeft,
  MessageCircle,
  ToggleLeft,
  ToggleRight,
  Building,
  Users,
  Wallet,
  Mail,
  Phone,
  MapPin,
  Hash,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Badge } from "@/components/ui/badge";
import { getOwnerById, formatCurrency } from "@/lib/data";
import { OwnerFacilitiesTable } from "../_components/owner-facilities-table";
import type { Owner } from "@/lib/types";

export default function OwnerDetailPage() {
  const params = useParams();
  const router = useRouter();
  const ownerId = params.id as string;
  const [owner, setOwner] = useState<Owner | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fetch owner data
    const ownerData = getOwnerById(ownerId);
    if (!ownerData) {
      router.push("/not-found");
      return;
    }
    setOwner(ownerData);
    setLoading(false);
  }, [ownerId, router]);

  const handleToggleStatus = () => {
    // In a real application, this would call an API to update the status
    if (owner) {
      setOwner({
        ...owner,
        status: owner.status === "Activated" ? "Deactivated" : "Activated",
      });
    }
  };

  const handleChatWithOwner = () => {
    // In a real application, this would open a chat interface
    if (owner) {
      alert(`Opening chat with ${owner.ownerName}`);
    }
  };

  const handleGoBack = () => {
    router.back();
  };

  if (loading || !owner) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-white">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-green-600 border-t-transparent rounded-full animate-spin mx-auto"></div>
          <p className="mt-4 text-lg text-gray-700">Loading owner details...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white pb-12">
      

      <div className="container mx-auto px-4 sm:px-6 lg:px-8 mt-6">
        {/* Owner Profile Card - Horizontal Layout */}
        <Card className="bg-white shadow-md overflow-hidden border-1 mb-8 py-0">
          <div className="flex flex-col md:flex-row">
            <div className="bg-green-50 p-6 flex flex-col items-center justify-center md:w-1/4 rounded-l-lg relative">
              {/* Nút ArrowLeft ở góc trái trên */}
              <Button
                variant="ghost"
                className="absolute top-4 left-4 text-green hover:text-green hover:bg-light-green"
                onClick={handleGoBack}
              >
                <ArrowLeft className="h-8 w-8 scale-150" />
              </Button>

              <div className="relative w-40 h-40 rounded-full overflow-hidden shadow-lg mb-4">
                <Image
                  src={owner.ownerImage || "/placeholder.svg"}
                  alt={owner.ownerName}
                  fill
                  className="object-cover"
                />
              </div>
              <h2 className="text-xl font-bold text-gray-800 text-center">
                {owner.ownerName}
              </h2>
              <p className="text-gray-500 font-mono text-center">
                {owner.ownerId}
              </p>
              <Badge
                className={`mt-2 ${
                  owner.status === "Activated"
                    ? "bg-green-100 text-green-800 hover:bg-green-100"
                    : "bg-red-100 text-red-800 hover:bg-red-100"
                }`}
              >
                {owner.status}
              </Badge>
            </div>

            {/* Middle - Owner details */}
            <div className="p-6 flex-1 md:w-2/4">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">
                Contact Information
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="flex items-start">
                  <Mail className="h-5 w-5 text-green-600 mr-3 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">Email</p>
                    <p className="text-gray-700">{owner.ownerEmail}</p>
                  </div>
                </div>

                <div className="flex items-start">
                  <Phone className="h-5 w-5 text-green-600 mr-3 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">Phone Number</p>
                    <p className="text-gray-700">{owner.phoneNumber}</p>
                  </div>
                </div>

                <div className="flex items-start">
                  <Users className="h-5 w-5 text-green-600 mr-3 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">Gender</p>
                    <p className="text-gray-700">{owner.gender}</p>
                  </div>
                </div>

                <div className="flex items-start">
                  <Hash className="h-5 w-5 text-green-600 mr-3 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">ID</p>
                    <p className="text-gray-700">{owner.ownerId}</p>
                  </div>
                </div>

                <div className="flex items-start col-span-2">
                  <MapPin className="h-5 w-5 text-green-600 mr-3 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">Address</p>
                    <p className="text-gray-700">{owner.ownerAddress}</p>
                  </div>
                </div>
              </div>

              <Separator className="my-4" />

              <h3 className="text-lg font-semibold text-gray-800 mb-4">
                Business Information
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="flex items-start">
                  <Building className="h-5 w-5 text-green-600 mr-3 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">
                      Number of Facilities
                    </p>
                    <p className="text-gray-700 font-semibold">
                      {owner.numberOfFacilities}
                    </p>
                  </div>
                </div>

                <div className="flex items-start">
                  <Wallet className="h-5 w-5 text-green-600 mr-3 mt-0.5" />
                  <div>
                    <p className="text-sm text-gray-500">Total Revenue</p>
                    <p className="text-gray-700 font-semibold">
                      {formatCurrency(owner.totalRevenue)}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Right side - Action buttons */}
            <div className="p-6 bg-green-50 flex flex-col justify-center md:w-1/4 border-l border-gray-100">
              <div className="text-center mb-6">
                <div
                  className={`inline-flex items-center justify-center w-16 h-16 rounded-full mb-2 ${
                    owner.status === "Activated" ? "bg-green-100" : "bg-grey"
                  }`}
                >
                  {owner.status === "Activated" ? (
                    <ToggleRight className="h-8 w-8 text-green" />
                  ) : (
                    <ToggleLeft className="h-8 w-8 text-dark-grey" />
                  )}
                </div>
                <h3 className="text-lg font-semibold text-gray-800">
                  {owner.status === "Activated"
                    ? "Active Account"
                    : "Inactive Account"}
                </h3>
                <p className="text-sm text-gray-500 mt-1">
                  {owner.status === "Activated"
                    ? "This owner is currently active"
                    : "This owner is currently deactivated"}
                </p>
              </div>

              <div className="space-y-4">
                <Button
                  className="w-full bg-green hover:bg-green-700 py-6"
                  onClick={handleChatWithOwner}
                >
                  <MessageCircle className="mr-2 h-5 w-5" />
                  Chat with Owner
                </Button>

                <Button
                  variant={
                    owner.status === "Activated" ? "destructive" : "outline"
                  }
                  className={`w-full py-6 ${
                    owner.status === "Activated"
                      ? "border-dark-grey border-1 bg-light-grey hover:bg-grey text-dark-grey"
                      : "border-green text-green hover:bg-light-green hover:text-green"
                  }`}
                  onClick={handleToggleStatus}
                >
                  {owner.status === "Activated" ? (
                    <>
                      <ToggleRight className="mr-2 h-5 w-5" />
                      Deactivate Owner
                    </>
                  ) : (
                    <>
                      <ToggleLeft className="mr-2 h-5 w-5" />
                      Activate Owner
                    </>
                  )}
                </Button>
              </div>
            </div>
          </div>
        </Card>

        {/* Facilities Table - Full Width Below */}
        <div className="bg-white rounded-xl shadow-md border overflow-hidden">
          <div className="p-6 border-b bg-green-50">
            <h2 className="text-xl font-semibold text-gray-800">
              Owner Facilities
            </h2>
            <p className="text-gray-600">
              Facilities managed by {owner.ownerName}
            </p>
          </div>
          <div className="p-0">
            <OwnerFacilitiesTable ownerId={ownerId} />
          </div>
        </div>
      </div>
    </div>
  );
}
