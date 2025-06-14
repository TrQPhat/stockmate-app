-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th6 14, 2025 lúc 05:27 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `stock_mate`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

CREATE TABLE `categories` (
  `id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `created_at`) VALUES
('cat-uuid-001', 'Thịt & Gia cầm', 'Các loại thịt tươi sống, đông lạnh và gia cầm', '2025-06-14 09:39:53'),
('cat-uuid-002', 'Hải sản', 'Các loại cá, tôm, mực và hải sản khác', '2025-06-14 09:39:53'),
('cat-uuid-003', 'Rau củ', 'Các loại rau, củ, quả tươi', '2025-06-14 09:39:53'),
('cat-uuid-004', 'Gia vị & Sốt', 'Các loại gia vị, nước sốt, dầu ăn', '2025-06-14 09:39:53'),
('cat-uuid-005', 'Đồ khô & Đóng hộp', 'Gạo, mì, miến, đồ hộp các loại', '2025-06-14 09:39:53');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `cooking_history`
--

CREATE TABLE `cooking_history` (
  `id` char(36) NOT NULL,
  `dish_id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL COMMENT 'Người đã nấu món này',
  `cooked_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Thời điểm nấu',
  `notes` text DEFAULT NULL COMMENT 'Ghi chú thêm (vd: ngon, lần sau cho ít muối hơn)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `cooking_history`
--

INSERT INTO `cooking_history` (`id`, `dish_id`, `user_id`, `cooked_at`, `notes`) VALUES
('ch-b-01', 'dish-b-01', 'user-uuid-002', '2025-06-14 19:30:00', 'Chồng khen ngon.');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dishes`
--

CREATE TABLE `dishes` (
  `id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `instructions` text NOT NULL COMMENT 'Các bước thực hiện, công thức',
  `image_url` text DEFAULT NULL COMMENT 'Đường dẫn đến hình ảnh món ăn',
  `cook_time_minutes` int(11) DEFAULT NULL COMMENT 'Thời gian nấu (phút)',
  `serving_size` int(11) DEFAULT NULL COMMENT 'Số người ăn',
  `created_by_user_id` char(36) NOT NULL COMMENT 'Người dùng tạo công thức',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `dishes`
--

INSERT INTO `dishes` (`id`, `name`, `description`, `instructions`, `image_url`, `cook_time_minutes`, `serving_size`, `created_by_user_id`, `created_at`, `updated_at`) VALUES
('dish-b-01', 'Thịt ba chỉ xào cải thìa', 'Món xào đơn giản, nhanh gọn cho bữa cơm gia đình.', '1. Luộc sơ cải thìa. 2. Thái thịt ba chỉ, xào cháy cạnh. 3. Phi thơm tỏi, cho cải và thịt vào xào chung, nêm dầu hào.', NULL, 15, 2, 'user-uuid-002', '2025-06-14 09:39:53', '2025-06-14 09:39:53'),
('dish-d-01', 'Mì Ý chay tỏi và ớt', 'Spaghetti Aglio e Olio - món mì Ý kinh điển, siêu tốc và đầy hương vị.', '1. Luộc mì. 2. Phi thơm thật nhiều tỏi và ớt khô trong dầu olive. 3. Vớt mì đã luộc vào chảo, đảo đều. Nêm muối, tiêu và thêm lá oregano.', NULL, 12, 1, 'user-uuid-003', '2025-06-14 09:39:53', '2025-06-14 09:39:53');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `dish_ingredients`
--

CREATE TABLE `dish_ingredients` (
  `id` char(36) NOT NULL,
  `dish_id` char(36) NOT NULL,
  `product_id` char(36) NOT NULL,
  `quantity` decimal(10,2) NOT NULL COMMENT 'Số lượng cần dùng',
  `unit` varchar(50) NOT NULL COMMENT 'Đơn vị tính (vd: gram, ml, muỗng canh)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `dish_ingredients`
--

INSERT INTO `dish_ingredients` (`id`, `dish_id`, `product_id`, `quantity`, `unit`) VALUES
('di-b-01', 'dish-b-01', 'prod-b-001', 300.00, 'gram'),
('di-b-02', 'dish-b-01', 'prod-b-002', 1.00, 'bó'),
('di-b-03', 'dish-b-01', 'prod-b-003', 50.00, 'gram'),
('di-d-01', 'dish-d-01', 'prod-d-001', 150.00, 'gram'),
('di-d-02', 'dish-d-01', 'prod-d-002', 1.00, 'muỗng cà phê');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `fcm_tokens`
--

CREATE TABLE `fcm_tokens` (
  `id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `token` text NOT NULL,
  `device_name` text DEFAULT NULL,
  `platform` enum('android','ios','web') DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `fcm_tokens`
--

INSERT INTO `fcm_tokens` (`id`, `user_id`, `token`, `device_name`, `platform`, `created_at`) VALUES
('fcm-b-01', 'user-uuid-002', 'token_string_for_user_002_new_device', 'Oppo Reno10', 'android', '2025-06-14 09:39:53'),
('fcm-d-01', 'user-uuid-003', 'token_string_for_user_003_new_device', 'Macbook Air M3', 'web', '2025-06-14 09:39:53');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `products`
--

CREATE TABLE `products` (
  `id` char(36) NOT NULL,
  `storage_id` char(36) NOT NULL,
  `name` text NOT NULL,
  `category_id` char(36) DEFAULT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `unit` text DEFAULT NULL,
  `import_date` date DEFAULT NULL,
  `expire_date` date DEFAULT NULL,
  `note` text DEFAULT NULL,
  `status` enum('con_dung','het_han','da_dung','huy') NOT NULL DEFAULT 'con_dung',
  `image_path` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `products`
--

INSERT INTO `products` (`id`, `storage_id`, `name`, `category_id`, `quantity`, `unit`, `import_date`, `expire_date`, `note`, `status`, `image_path`, `created_at`, `updated_at`) VALUES
('prod-b-001', 'storage-b-01', 'Thịt ba chỉ heo', 'cat-uuid-001', 500, 'gram', NULL, '2025-06-20', NULL, 'con_dung', NULL, '2025-06-14 09:39:53', '2025-06-14 09:39:53'),
('prod-b-002', 'storage-b-01', 'Cải thìa', 'cat-uuid-003', 1, 'bó', NULL, '2025-06-18', NULL, 'con_dung', NULL, '2025-06-14 09:39:53', '2025-06-14 09:39:53'),
('prod-b-003', 'storage-b-02', 'Tỏi', 'cat-uuid-003', 100, 'gram', NULL, '2025-08-14', NULL, 'con_dung', NULL, '2025-06-14 09:39:53', '2025-06-14 09:39:53'),
('prod-d-001', 'storage-d-01', 'Mì Ý De Cecco', 'cat-uuid-005', 1, 'hộp', NULL, '2026-10-20', NULL, 'con_dung', NULL, '2025-06-14 09:39:53', '2025-06-14 09:39:53'),
('prod-d-002', 'storage-d-01', 'Lá Oregano khô', 'cat-uuid-004', 1, 'lọ', NULL, '2026-05-15', NULL, 'con_dung', NULL, '2025-06-14 09:39:53', '2025-06-14 09:39:53');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_logs`
--

CREATE TABLE `product_logs` (
  `id` char(36) NOT NULL,
  `product_id` char(36) NOT NULL,
  `action` enum('da_dung','huy','cap_nhat','tu_dong_het_han') NOT NULL,
  `quantity` int(11) NOT NULL,
  `note` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `product_logs`
--

INSERT INTO `product_logs` (`id`, `product_id`, `action`, `quantity`, `note`, `created_at`) VALUES
('pl-b-01', 'prod-b-001', 'da_dung', 300, 'Dùng cho món thịt xào cải thìa', '2025-06-14 09:39:53'),
('pl-d-01', 'prod-d-001', 'cap_nhat', 1, 'Mới mua thêm 1 hộp', '2025-06-14 09:39:53');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `shopping_lists`
--

CREATE TABLE `shopping_lists` (
  `id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `purchase_date` date DEFAULT NULL,
  `total_cost` decimal(15,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `shopping_lists`
--

INSERT INTO `shopping_lists` (`id`, `user_id`, `name`, `created_at`, `updated_at`, `purchase_date`, `total_cost`) VALUES
('3ef954d1-9298-4c7e-a580-fdbd62c8bac3', 'user-uuid-002', 'Danh sách test của tôi', '2025-06-14 02:59:10', '2025-06-14 02:59:10', '2025-06-14', 0.00),
('sl-b-01', 'user-uuid-002', 'Mua đồ cuối tuần', '2025-06-14 09:39:53', '2025-06-14 09:39:53', '2025-06-15', 120000.00),
('sl-d-01', 'user-uuid-003', 'Mua đồ làm bánh', '2025-06-14 09:39:53', '2025-06-14 09:39:53', '2025-06-16', 0.00),
('sl-tet-uuid', 'user-uuid-002', 'Đi chợ Tết - Đã cập nhật', '2025-06-14 02:47:56', '2025-06-14 03:03:30', '2025-01-25', 0.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `shopping_list_items`
--

CREATE TABLE `shopping_list_items` (
  `id` char(36) NOT NULL,
  `shopping_list_id` char(36) NOT NULL,
  `product_id` char(36) DEFAULT NULL,
  `item_name` text NOT NULL,
  `quantity` int(11) DEFAULT 1,
  `unit` text DEFAULT NULL,
  `is_purchased` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `price` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `shopping_list_items`
--

INSERT INTO `shopping_list_items` (`id`, `shopping_list_id`, `product_id`, `item_name`, `quantity`, `unit`, `is_purchased`, `created_at`, `price`) VALUES
('6a6b591d-8ee0-447b-9d48-5aa3e1b16a18', 'sl-tet-uuid', NULL, 'Bánh chưng', 2, 'cái', 0, '2025-06-14 02:53:15', 80000.00),
('sli-b-01', 'sl-b-01', NULL, 'Dầu hào', 1, 'chai', 1, '2025-06-14 09:39:53', 25000.00),
('sli-b-02', 'sl-b-01', NULL, 'Cá lóc', 1, 'con', 1, '2025-06-14 09:39:53', 95000.00),
('sli-d-01', 'sl-d-01', NULL, 'Bột mì số 13', 1, 'kg', 0, '2025-06-14 09:39:53', 50000.00),
('sli-d-02', 'sl-d-01', NULL, 'Men nở khô', 1, 'hộp', 0, '2025-06-14 09:39:53', 30000.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `storages`
--

CREATE TABLE `storages` (
  `id` char(36) NOT NULL,
  `name` text NOT NULL,
  `owner_id` char(36) NOT NULL,
  `key` char(10) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `storages`
--

INSERT INTO `storages` (`id`, `name`, `owner_id`, `key`, `created_at`) VALUES
('storage-b-01', 'Tủ lạnh nhà B', 'user-uuid-002', 'B01B01B01B', '2025-06-14 09:39:53'),
('storage-b-02', 'Kệ bếp nhà B', 'user-uuid-002', 'B02B02B02B', '2025-06-14 09:39:53'),
('storage-d-01', 'Tủ đồ khô Dzi', 'user-uuid-003', 'D01D01D01D', '2025-06-14 09:39:53');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `storage_members`
--

CREATE TABLE `storage_members` (
  `id` char(36) NOT NULL,
  `storage_id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `role` enum('owner','editor','viewer') NOT NULL,
  `joined_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `storage_members`
--

INSERT INTO `storage_members` (`id`, `storage_id`, `user_id`, `role`, `joined_at`) VALUES
('sm-uuid-b01', 'storage-b-01', 'user-uuid-002', 'owner', '2025-06-14 09:39:53'),
('sm-uuid-b02', 'storage-b-02', 'user-uuid-002', 'owner', '2025-06-14 09:39:53'),
('sm-uuid-d01', 'storage-d-01', 'user-uuid-003', 'owner', '2025-06-14 09:39:53'),
('sm-uuid-share01', 'storage-b-01', 'user-uuid-003', 'viewer', '2025-06-14 09:39:53');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `user_id` char(36) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `password_hash` text NOT NULL,
  `avatar_url` text DEFAULT NULL,
  `gender` enum('male','female','other') DEFAULT 'other',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `user_id`, `email`, `phone`, `full_name`, `password_hash`, `avatar_url`, `gender`, `created_at`, `updated_at`) VALUES
(1, 'user-uuid-001', 'b@example.com', '0901234567', 'Nguyễn Văn A', '$2y$10$nSFz.FPUYgi1N0QXMIz.MeskpA/JfHnxezNvivDExqPhySh2Yvuaa', 'https://i.pravatar.cc/150?u=nguyenvana', 'male', '2025-06-09 10:00:00', '2025-06-11 10:32:03'),
(2, 'user-uuid-002', 'tuvi112203@gmail.com', '0987654321', 'Trần Thị Ngọc B', '$2a$10$WakFZ8V8GFinPQB/RG3mNeD.DATrvFiG9MhGa79n.obR4AOE/45s6', 'https://i.pravatar.cc/150?u=tranthingocb', 'female', '2025-06-09 10:05:00', '2025-06-11 07:32:45'),
(6, 'user-uuid-003', 'Dzicute@gmail.com', '0123456789', 'Dzi', '$2b$10$4HDnq5ISBiijMlCzrKNKcuxKf62Dg9t.SsNQLHdhu7KRJ8Gvs58jO', NULL, 'other', '2025-06-11 10:27:12', '2025-06-11 10:27:12');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `cooking_history`
--
ALTER TABLE `cooking_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `dish_id` (`dish_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `dishes`
--
ALTER TABLE `dishes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by_user_id` (`created_by_user_id`);

--
-- Chỉ mục cho bảng `dish_ingredients`
--
ALTER TABLE `dish_ingredients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `dish_product_unique` (`dish_id`,`product_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Chỉ mục cho bảng `fcm_tokens`
--
ALTER TABLE `fcm_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `storage_id` (`storage_id`),
  ADD KEY `fk_products_category` (`category_id`);

--
-- Chỉ mục cho bảng `product_logs`
--
ALTER TABLE `product_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Chỉ mục cho bảng `shopping_lists`
--
ALTER TABLE `shopping_lists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `shopping_list_items`
--
ALTER TABLE `shopping_list_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `shopping_list_id` (`shopping_list_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Chỉ mục cho bảng `storages`
--
ALTER TABLE `storages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Chỉ mục cho bảng `storage_members`
--
ALTER TABLE `storage_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `storage_id` (`storage_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `cooking_history`
--
ALTER TABLE `cooking_history`
  ADD CONSTRAINT `cooking_history_ibfk_1` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cooking_history_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `dishes`
--
ALTER TABLE `dishes`
  ADD CONSTRAINT `dishes_ibfk_1` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `dish_ingredients`
--
ALTER TABLE `dish_ingredients`
  ADD CONSTRAINT `dish_ingredients_ibfk_1` FOREIGN KEY (`dish_id`) REFERENCES `dishes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `dish_ingredients_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `fcm_tokens`
--
ALTER TABLE `fcm_tokens`
  ADD CONSTRAINT `fcm_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Các ràng buộc cho bảng `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`storage_id`) REFERENCES `storages` (`id`);

--
-- Các ràng buộc cho bảng `product_logs`
--
ALTER TABLE `product_logs`
  ADD CONSTRAINT `product_logs_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Các ràng buộc cho bảng `shopping_lists`
--
ALTER TABLE `shopping_lists`
  ADD CONSTRAINT `shopping_lists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `shopping_list_items`
--
ALTER TABLE `shopping_list_items`
  ADD CONSTRAINT `shopping_list_items_ibfk_1` FOREIGN KEY (`shopping_list_id`) REFERENCES `shopping_lists` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `shopping_list_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `storages`
--
ALTER TABLE `storages`
  ADD CONSTRAINT `storages_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`);

--
-- Các ràng buộc cho bảng `storage_members`
--
ALTER TABLE `storage_members`
  ADD CONSTRAINT `storage_members_ibfk_1` FOREIGN KEY (`storage_id`) REFERENCES `storages` (`id`),
  ADD CONSTRAINT `storage_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
