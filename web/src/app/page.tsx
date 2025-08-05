"use client"

import { useState, useEffect } from "react"

import { Button } from '@/components/ui/button'; // Đảm bảo đường dẫn đúng
import { Card, CardContent } from '@/components/ui/card'; // Đảm bảo đường dẫn đúng
import { CheckCircle, BarChart3, Shield, ArrowRight,Package, Bell, Star } from 'lucide-react';

export default function WelcomePage() {
  const [currentStep, setCurrentStep] = useState(0)
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    setIsVisible(true)
  }, [])

  const features = [
    {
      icon: Package,
      title: "Quản lý kho hàng thông minh",
      description: "Theo dõi tồn kho, nhập xuất hàng một cách dễ dàng và chính xác",
    },
    {
      icon: BarChart3,
      title: "Báo cáo chi tiết",
      description: "Phân tích dữ liệu kinh doanh với các biểu đồ trực quan và báo cáo tự động",
    },
    {
      icon: Bell,
      title: "Cảnh báo thông minh",
      description: "Nhận thông báo khi hàng hóa sắp hết, hết hạn hoặc cần bổ sung",
    },
    {
      icon: Shield,
      title: "Bảo mật cao",
      description: "Dữ liệu được mã hóa và bảo vệ với các tiêu chuẩn bảo mật hàng đầu",
    },
  ]

  const steps = [
    {
      title: "Tạo kho hàng đầu tiên",
      description: "Thiết lập kho hàng và phân loại sản phẩm của bạn",
    },
    {
      title: "Thêm sản phẩm",
      description: "Nhập thông tin chi tiết về các mặt hàng trong kho",
    },
    {
      title: "Theo dõi và quản lý",
      description: "Bắt đầu quản lý kho hàng hiệu quả với StockMate",
    },
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-white to-green-50">
      {/* Hero Section */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-r from-green-600/10 to-green-400/10" />
        <div className="relative container mx-auto px-4 py-12 lg:py-20">
          <div
            className={`text-center transition-all duration-1000 ${isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-10"}`}
          >
            <div className="inline-flex items-center gap-2 bg-green-100 text-green-700 px-4 py-2 rounded-full text-sm font-medium mb-6">
              <Star className="w-4 h-4" />
              Chào mừng đến với StockMate
            </div>

            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 mb-6 leading-tight">
              Quản lý kho hàng
              <span className="text-green-600 block">thông minh & hiệu quả</span>
            </h1>

            <p className="text-lg md:text-xl text-gray-600 mb-8 max-w-3xl mx-auto leading-relaxed">
              Chào mừng bạn đến với StockMate - giải pháp quản lý kho hàng toàn diện. Hãy bắt đầu hành trình tối ưu hóa
              việc quản lý tồn kho của bạn ngay hôm nay.
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <Button
                size="lg"
                className="bg-green-600 hover:bg-green-700 text-white px-8 py-3 text-lg font-semibold rounded-xl shadow-lg hover:shadow-xl transition-all duration-300"
              >
                Bắt đầu ngay
                <ArrowRight className="ml-2 w-5 h-5" />
              </Button>
              <Button
                variant="outline"
                size="lg"
                className="border-green-600 text-green-600 hover:bg-green-50 px-8 py-3 text-lg font-semibold rounded-xl bg-transparent"
              >
                Tìm hiểu thêm
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 lg:py-24 bg-white">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">Tại sao chọn StockMate?</h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Khám phá những tính năng mạnh mẽ giúp bạn quản lý kho hàng một cách chuyên nghiệp
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <Card
                key={index}
                className={`group hover:shadow-xl transition-all duration-500 border-0 shadow-lg hover:-translate-y-2 ${
                  isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-10"
                }`}
                style={{ transitionDelay: `${index * 150}ms` }}
              >
                <CardContent className="p-8 text-center">
                  <div className="inline-flex items-center justify-center w-16 h-16 bg-green-100 text-green-600 rounded-2xl mb-6 group-hover:bg-green-600 group-hover:text-white transition-all duration-300">
                    <feature.icon className="w-8 h-8" />
                  </div>
                  <h3 className="text-xl font-bold text-gray-900 mb-4">{feature.title}</h3>
                  <p className="text-gray-600 leading-relaxed">{feature.description}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Getting Started Section */}
      <section className="py-16 lg:py-24 bg-gradient-to-r from-green-600 to-green-500">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">Bắt đầu chỉ với 3 bước đơn giản</h2>
            <p className="text-lg text-green-100 max-w-2xl mx-auto">
              Thiết lập và sử dụng StockMate chỉ trong vài phút
            </p>
          </div>

          <div className="max-w-4xl mx-auto">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {steps.map((step, index) => (
                <div key={index} className="relative text-center">
                  <div className="inline-flex items-center justify-center w-16 h-16 bg-white text-green-600 rounded-full text-2xl font-bold mb-6 shadow-lg">
                    {index + 1}
                  </div>
                  <h3 className="text-xl font-bold text-white mb-4">{step.title}</h3>
                  <p className="text-green-100 leading-relaxed">{step.description}</p>

                  {/* Connector line for desktop */}
                  {index < steps.length - 1 && (
                    <div className="hidden md:block absolute top-8 left-full w-full h-0.5 bg-green-400 transform -translate-x-1/2 -translate-y-1/2" />
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 lg:py-24 bg-white">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
            <div className="group">
              <div className="text-4xl md:text-5xl font-bold text-green-600 mb-2 group-hover:scale-110 transition-transform duration-300">
                10,000+
              </div>
              <p className="text-lg text-gray-600 font-semibold">Doanh nghiệp tin tưởng</p>
            </div>
            <div className="group">
              <div className="text-4xl md:text-5xl font-bold text-green-600 mb-2 group-hover:scale-110 transition-transform duration-300">
                99.9%
              </div>
              <p className="text-lg text-gray-600 font-semibold">Thời gian hoạt động</p>
            </div>
            <div className="group">
              <div className="text-4xl md:text-5xl font-bold text-green-600 mb-2 group-hover:scale-110 transition-transform duration-300">
                24/7
              </div>
              <p className="text-lg text-gray-600 font-semibold">Hỗ trợ khách hàng</p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 lg:py-24 bg-gradient-to-br from-gray-900 to-gray-800">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl md:text-4xl font-bold text-white mb-6">Sẵn sàng bắt đầu với StockMate?</h2>
          <p className="text-lg text-gray-300 mb-8 max-w-2xl mx-auto">
            Tham gia cùng hàng nghìn doanh nghiệp đã tin tưởng StockMate để quản lý kho hàng hiệu quả
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <Button
              size="lg"
              className="bg-green-600 hover:bg-green-700 text-white px-8 py-4 text-lg font-semibold rounded-xl shadow-lg hover:shadow-xl transition-all duration-300"
            >
              Tạo tài khoản miễn phí
              <ArrowRight className="ml-2 w-5 h-5" />
            </Button>
            <Button
              variant="outline"
              size="lg"
              className="border-gray-600 text-gray-300 hover:bg-gray-800 hover:border-gray-500 px-8 py-4 text-lg font-semibold rounded-xl bg-transparent"
            >
              Xem demo trực tiếp
            </Button>
          </div>

          <div className="mt-8 flex flex-wrap justify-center items-center gap-6 text-sm text-gray-400">
            <div className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-green-500" />
              Miễn phí 30 ngày
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-green-500" />
              Không cần thẻ tín dụng
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-green-500" />
              Hỗ trợ 24/7
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-400 py-12">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="col-span-1 md:col-span-2">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-8 h-8 bg-green-600 rounded-lg flex items-center justify-center">
                  <Package className="w-5 h-5 text-white" />
                </div>
                <span className="text-xl font-bold text-white">StockMate</span>
              </div>
              <p className="text-gray-400 mb-4 max-w-md">
                Giải pháp quản lý kho hàng thông minh, giúp doanh nghiệp tối ưu hóa quy trình và nâng cao hiệu quả kinh
                doanh.
              </p>
            </div>

            <div>
              <h4 className="text-white font-semibold mb-4">Sản phẩm</h4>
              <ul className="space-y-2">
                <li>
                  <a href="#" className="hover:text-green-400 transition-colors">
                    Quản lý kho
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-green-400 transition-colors">
                    Báo cáo
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-green-400 transition-colors">
                    Tích hợp
                  </a>
                </li>
              </ul>
            </div>

            <div>
              <h4 className="text-white font-semibold mb-4">Hỗ trợ</h4>
              <ul className="space-y-2">
                <li>
                  <a href="#" className="hover:text-green-400 transition-colors">
                    Trung tâm trợ giúp
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-green-400 transition-colors">
                    Liên hệ
                  </a>
                </li>
                <li>
                  <a href="#" className="hover:text-green-400 transition-colors">
                    Hướng dẫn
                  </a>
                </li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-800 mt-8 pt-8 text-center">
            <p>&copy; 2024 StockMate. Tất cả quyền được bảo lưu.</p>
          </div>
        </div>
      </footer>
    </div>
  )
}
