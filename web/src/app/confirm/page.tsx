

// web/src/app/confirm-action/page.tsx
'use client';

import React, { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Button } from '@/components/ui/button'; // Đảm bảo đường dẫn đúng
import { Card, CardContent } from '@/components/ui/card'; // Đảm bảo đường dẫn đúng
import { CheckCircle, Shield, ArrowRight } from 'lucide-react';

// Định nghĩa một key cho localStorage để dễ quản lý
const EMAIL_LOCAL_STORAGE_KEY = 'user_email_for_verification';

export default function ConfirmActionPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [status, setStatus] = useState<string>('Đang tải...');
  const [loading, setLoading] = useState<boolean>(true);
  const [confirmationUrl, setConfirmationUrl] = useState<string | null>(null);
  const [userEmail, setUserEmail] = useState<string | null>(null); // State mới để lưu email

  useEffect(() => {
    const url = searchParams.get('confirmation_url'); // Lấy confirmation_url
    const email = searchParams.get('email'); // Lấy email từ query parameter

    if (email) {
      setUserEmail(email); // Lưu email vào state
       // Lưu email vào localStorage ngay khi nhận được
      localStorage.setItem(EMAIL_LOCAL_STORAGE_KEY, email);
      // Bạn có thể dùng email ở đây, ví dụ để tùy chỉnh tin nhắn
      setStatus(`Chào mừng ${email}! Nhấn nút bên dưới để xác nhận tài khoản của bạn.`);
    } else {
      setUserEmail(null);
      setStatus('Nhấn nút bên dưới để xác nhận tài khoản của bạn.'); // Tin nhắn mặc định nếu không có email
    }

    if (url) {
    console.log("url: ", url);
      setConfirmationUrl(url);
    } else {
      setStatus('Liên kết xác nhận không hợp lệ hoặc bị thiếu.');
    }
    setLoading(false);
  }, [searchParams]); // Thêm searchParams vào dependency array

  const handleConfirmClick = () => {
    if (confirmationUrl) {
      setStatus('Đang xác nhận...');
      setLoading(true);
      // Điều hướng người dùng đến URL xác nhận thực sự của Supabase
      window.location.href = confirmationUrl;
    } else {
      setStatus('Không thể xác nhận. Liên kết không hợp lệ.');
    }
  };

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
              <h1 style={{ color: '#333', fontSize: '2em', marginBottom: '15px' }}>Đang tải...</h1>
              <p style={{ color: '#007bff', fontSize: '1.1em' }}>{status}</p>
            </>
          ) : (
            <>
              <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '20px' }}>
                {confirmationUrl ? (
                  <CheckCircle style={{ width: '60px', height: '60px', color: '#28a745' }} />
                ) : (
                  <Shield style={{ width: '60px', height: '60px', color: 'red' }} />
                )}
              </div>
              <h1 style={{ color: '#333', fontSize: '2em', marginBottom: '15px' }}>Xác nhận Tài khoản</h1>
              {userEmail && (
                <p style={{ color: '#555', fontSize: '1em', marginBottom: '15px' }}>
                  Bạn đang xác nhận tài khoản cho: <span style={{ fontWeight: 'bold' }}>{userEmail}</span>
                </p>
              )}
              <p style={{ color: confirmationUrl ? '#333' : 'red', fontSize: '1.1em', marginBottom: '30px' }}>
                {status}
              </p>
              {confirmationUrl && (
                <Button
                  onClick={handleConfirmClick}
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
                  disabled={loading}
                >
                  {loading ? 'Đang xác nhận...' : 'Xác nhận Tài khoản của tôi'}
                  {!loading && <ArrowRight className="ml-2 w-5 h-5" />}
                </Button>
              )}
               {!confirmationUrl && (
                <Button
                  onClick={() => router.push('/')}
                  style={{
                    padding: '12px 25px',
                    fontSize: '1.1em',
                    backgroundColor: '#007bff',
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