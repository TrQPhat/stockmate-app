# Storage Manager

Ứng dụng quản lý kho nguyên liệu được xây dựng bằng Flutter.

## 🚀 Cài đặt

### Yêu cầu hệ thống

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

### Các bước cài đặt

1. **Clone repository**
   \`\`\`bash
   git clone <repository-url>
   cd storage_manager
   \`\`\`

2. **Cài đặt dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **Generate code**
   \`\`\`bash
   flutter pub run build_runner build
   \`\`\`

4. **Chạy ứng dụng**
   \`\`\`bash
   flutter run
   \`\`\`

## 📁 Cấu trúc project

\`\`\`
lib/
├── core/ # Core functionality
│ ├── di/ # Dependency injection
│ ├── network/ # Network configuration
│ ├── router/ # App routing
│ ├── theme/ # App theming
│ └── widgets/ # Reusable widgets
├── features/ # Feature modules
│ ├── auth/ # Authentication
│ ├── home/ # Home screen
│ ├── storage/ # Storage management
│ └── product/ # Product management
└── main.dart # App entry point
\`\`\`

## 🏗️ Kiến trúc

- **Clean Architecture**: Phân tách rõ ràng các layer
- **BLoC Pattern**: State management
- **Feature-based**: Tổ chức code theo tính năng
- **Dependency Injection**: Quản lý dependencies

## 🔧 Tính năng

- ✅ Đăng nhập/Đăng ký
- ✅ Quản lý kho nguyên liệu
- ✅ Thêm/Sửa/Xóa sản phẩm
- ✅ Phân loại sản phẩm
- ✅ Theo dõi hạn sử dụng
- 🚧 Thống kê kho
- 🚧 Đề xuất mua sắm
- 🚧 Lập kế hoạch sử dụng

## 🛠️ Development

### Code generation

\`\`\`bash
flutter pub run build_runner build --delete-conflicting-outputs
\`\`\`

### Testing

\`\`\`bash
flutter test
\`\`\`

### Build APK

\`\`\`bash
flutter build apk --release
\`\`\`

## 📱 Screenshots

[Thêm screenshots ở đây]

## 🤝 Contributing

1. Fork project
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request
