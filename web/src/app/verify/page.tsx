// web/src/app/verify/page.tsx
'use client';

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabaseClient'; // Đảm bảo đường dẫn đúng
import { UserDetails, ApiResponse } from '@/lib/types'; // Đảm bảo đường dẫn đúng
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { CheckCircle, Shield, ArrowRight } from "lucide-react";

// Định nghĩa một key cho localStorage để dễ quản lý
const EMAIL_LOCAL_STORAGE_KEY = 'user_email_for_verification';

export default function VerifyEmailPage() {
  const [status, setStatus] = useState<string>('Đang xác nhận email của bạn...');
  const [loading, setLoading] = useState<boolean>(true);
  const router = useRouter();

  useEffect(() => {
    const handleVerification = async () => {
      setLoading(true);
      const url = new URL(window.location.href);
      const code = url.searchParams.get("code"); // Lấy tham số 'code'

      if (!code) {
        setStatus("Liên kết xác nhận không hợp lệ hoặc đã hết hạn.");
        setLoading(false);
        //setTimeout(() => router.push("/"), 3000);
        return;
      }

      try {
        // Bước quan trọng: Trao đổi 'code' lấy session
        const { data, error } = await supabase.auth.exchangeCodeForSession(code)

        console.log("data: ",data);

        // Gửi request xác thực đến backend
        const backendApiUrl = `${process.env.NEXT_PUBLIC_BACKEND_API_URL}/users/verify`;
        const userEmail = localStorage.getItem(EMAIL_LOCAL_STORAGE_KEY);

        const response = await fetch(backendApiUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            email: userEmail,
          } ),
        });

        if (!response.ok) {
          const resBody: ApiResponse = await response.json();
          throw new Error(resBody.message || "Lỗi từ backend");
        }

        setStatus("Xác thực thành công! Tài khoản của bạn đã được kích hoạt. Đang chuyển hướng...");
        console.log("Trạng thái người dùng đã được cập nhật trong backend API.");
        setTimeout(() => router.push("/"), 3000); // Chuyển hướng về trang chính sau 3 giây
      } catch (err: any) {
        console.error("❌ Lỗi xác thực:", err);
        setStatus(`Đã có lỗi xảy ra: ${err.message || 'Lỗi không xác định'}`);
        setLoading(false);
        // setTimeout(() => router.push("/"), 3000);
      } finally {
        setLoading(false);
      }
    };

    handleVerification();
  }, [router]);

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
      backgroundColor: '#f0f9ff',
      fontFamily: 'Arial, sans-serif',
      padding: '20px'
    }}>
      <Card style={{ padding: '40px', textAlign: 'center', maxWidth: '500px', width: '100%', borderRadius: '12px', boxShadow: '0 8px 16px rgba(0,0,0,0.1)' }}>
        <CardContent>
          {loading ? (
            <>
              <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '20px' }}>
                <div style={{
                  border: '4px solid #f3f3f3',
                  borderTop: '4px solid #3498db',
                  borderRadius: '50%',
                  width: '40px',
                  height: '40px',
                  animation: 'spin 1s linear infinite'
                }}></div>
              </div>
              <style jsx>{`
                @keyframes spin {
                  0% { transform: rotate(0deg); }
                  100% { transform: rotate(360deg); }
                }
              `}</style>
              <h1 style={{ color: '#333', fontSize: '2em', marginBottom: '15px' }}>Đang xác nhận email</h1>
              <p style={{ color: '#007bff', fontSize: '1.1em' }}>{status}</p>
            </>
          ) : (
            <>
              <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '20px' }}>
                {status.includes('thành công') ? (
                  <CheckCircle style={{ width: '60px', height: '60px', color: 'green' }} />
                ) : (
                  <Shield style={{ width: '60px', height: '60px', color: 'red' }} />
                )}
              </div>
              <h1 style={{ color: '#333', fontSize: '2em', marginBottom: '15px' }}>Xác nhận Email</h1>
              <p style={{ color: status.includes('thành công') ? 'green' : 'red', fontSize: '1.1em', marginBottom: '30px' }}>
                {status}
              </p>
              {!status.includes('thành công') && (
                <Button
                  onClick={() => router.push('/')}
                  style={{
                    padding: '12px 25px',
                    fontSize: '1.1em',
                    backgroundColor: '#28a745',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    cursor: 'pointer',
                    boxShadow: '0 4px 8px rgba(0,0,0,0.2)',
                    transition: 'background-color 0.3s ease'
                  }}
                >
                  Trở về trang chủ
                  <ArrowRight className="ml-2 w-5 h-5" />
                </Button>
              )}
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}