interface CourtCardProps {
    name: string;
    description: string;
    pricePerHour?: number; // Giá có thể không bắt buộc để tránh lỗi
    currency?: string;
  }
  
  export function CourtCard({ name, description, pricePerHour = 0, currency = "VND" }: CourtCardProps) {
    // Kiểm tra nếu pricePerHour không hợp lệ
    const formattedPrice = Number.isFinite(pricePerHour) 
      ? new Intl.NumberFormat("vi-VN").format(pricePerHour) 
      : "N/A";
  
    return (
      <div className="border rounded-md p-4 hover:shadow-md transition-shadow">
        <h5 className="font-medium">{name}</h5>
        <p className="text-sm text-[#4b4b4b] mt-1">{description}</p>
        <p className="text-[#198155] font-medium mt-2">
          {formattedPrice !== "N/A" ? `${formattedPrice} ${currency} / hour` : "Giá không khả dụng"}
        </p>
      </div>
    );
  }