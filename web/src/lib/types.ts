// web/src/lib/types.ts
export interface UserDetails {
  id: string;
  email: string;
  // Bạn có thể thêm các trường khác nếu backend của bạn gửi về
  // Ví dụ: fullName?: string;
  // gender?: string;
}

export interface ApiResponse {
  message: string;
  // Bạn có thể thêm các trường lỗi khác nếu API trả về
  // Ví dụ: errorCode?: string;
}