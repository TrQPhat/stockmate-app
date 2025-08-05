// web/src/app/layout.tsx
import "./globals.css"
import type { Metadata } from 'next'; // Import Metadata type
import Link from 'next/link';

export const metadata: Metadata = { // Sử dụng kiểu Metadata
  title: 'Stockmate',
  description: 'Ứng dụng quản lý tủ lạnh cá nhân và nhà hàng',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <nav style={{ padding: '10px', backgroundColor: '#f8f8f8', borderBottom: '1px solid #eee' }}>
          <Link href="/" style={{ margin: '0 10px', textDecoration: 'none', color: '#007bff' }}>Trang chủ</Link>
          <Link href="/login" style={{ margin: '0 10px', textDecoration: 'none', color: '#007bff' }}>Đăng nhập</Link>
          <Link href="/dashboard" style={{ margin: '0 10px', textDecoration: 'none', color: '#007bff' }}>Dashboard</Link>
          <Link href="/verify" style={{ margin: '0 10px', textDecoration: 'none', color: '#007bff' }}>Xác nhận Email</Link>
        </nav>
        {children}
      </body>
    </html>
  );
}