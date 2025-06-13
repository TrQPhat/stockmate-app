-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th6 13, 2025 lúc 09:04 PM
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
('1474341f-d412-474a-854a-2b55df8d0fe3', 'Đồ khô & Gia vị', 'Các loại mỳ, gạo, đậu và gia vị nấu ăn', '2025-06-11 23:21:40'),
('7038b6a6-5d92-4913-892e-642e01aa8755', 'Đồ khô & Gia vị', 'Các loại mỳ, gạo, đậu và gia vị nấu ăn', '2025-06-11 23:19:03'),
('cat-uuid-001', 'Rau củ', 'Các loại rau củ quả tươi', '2025-06-09 09:00:00'),
('cat-uuid-003', 'Gia vị', 'Các loại gia vị dùng trong nấu ăn', '2025-06-09 09:02:00'),
('cat-uuid-004', 'Đồ khô', 'Gạo, mỳ, các loại đậu...', '2025-06-09 09:03:00'),
('cat-uuid-005', 'Đồ uống', 'Sữa, nước ngọt, nước trái cây...', '2025-06-09 09:04:00');

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
('379f4b00-d423-49df-9a53-32cde0df57c4', 'dish-uuid-001', 'user-uuid-002', '2025-06-13 18:26:07', 'Lần này nấu ngon hơn lần trước.'),
('ch-uuid-001', 'dish-uuid-002', 'user-uuid-002', '2025-06-08 18:30:00', 'Ngon, lần sau cho thêm chút tiêu.');

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
('03373609-b84e-4c37-810a-a07e8812f2f9', 'Thịt bò xào lúc lắc', 'Thịt bò mềm ngọt, thấm vị, ăn kèm với rau củ giòn tươi.', '1. Cắt thịt bò thành khối vuông. 2. Ướp gia vị trong 15 phút. 3. Xào nhanh thịt bò trên lửa lớn. 4. Thêm rau củ, đảo đều và nêm nếm lại.', NULL, 20, 2, 'user-uuid-003', '2025-06-11 23:35:07', '2025-06-11 23:35:07'),
('dish-uuid-001', 'Thịt kho trứng', 'Món ăn truyền thống của người Việt, đậm đà đưa cơm', '1. Rửa sạch thịt, thái miếng vừa ăn. Luộc trứng, bóc vỏ.\n2. Thắng nước màu καραμέλ.\n3. Cho thịt vào xào săn, nêm nước mắm, đường.\n4. Cho trứng và nước dừa vào kho liu riu trong 1 tiếng.\n5. Nêm nếm lại và thưởng thức.', NULL, 75, 4, 'user-uuid-001', '2025-06-09 20:08:17', '2025-06-09 20:08:17'),
('dish-uuid-002', 'Canh cà chua trứng', 'Món canh đơn giản, nhanh gọn và bổ dưỡng', '1. Rửa sạch cà chua, thái múi cau. Đập trứng ra bát, đánh tan.\n2. Phi thơm hành, cho cà chua vào xào chín mềm.\n3. Đổ nước vào đun sôi, nêm gia vị vừa ăn.\n4. Từ từ đổ trứng đã đánh vào nồi, khuấy nhẹ.\n5. Thêm hành lá, tắt bếp.', NULL, 15, 3, 'user-uuid-002', '2025-06-09 20:08:17', '2025-06-09 20:08:17');

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
('6cef1d05-6898-4fc7-bd3c-97ec927f43d4', '03373609-b84e-4c37-810a-a07e8812f2f9', 'prod-uuid-004', 30.00, 'gram'),
('9440b672-9de4-42cc-bcfe-9abdbc0a7269', '03373609-b84e-4c37-810a-a07e8812f2f9', 'prod-uuid-005', 10.00, 'gram'),
('di-uuid-001', 'dish-uuid-001', 'prod-uuid-001', 500.00, 'gram'),
('di-uuid-002', 'dish-uuid-001', 'prod-uuid-002', 5.00, 'quả'),
('di-uuid-003', 'dish-uuid-001', 'prod-uuid-005', 50.00, 'ml'),
('di-uuid-004', 'dish-uuid-002', 'prod-uuid-003', 300.00, 'gram'),
('di-uuid-005', 'dish-uuid-002', 'prod-uuid-002', 2.00, 'quả'),
('di-uuid-006', 'dish-uuid-002', 'prod-uuid-004', 50.00, 'gram');

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
('fcm-uuid-001', 'user-uuid-001', 'dummy_fcm_token_string_for_user_a', 'Samsung Galaxy S23', 'android', '2025-06-09 20:08:17');

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
('prod-uuid-001', 'storage-uuid-001', 'Thịt ba rọi heo', 'cat-uuid-002', 500, 'gram', '2025-06-08', '2025-06-12', 'Hàng CP', 'con_dung', NULL, '2025-06-09 20:08:17', '2025-06-09 20:08:17'),
('prod-uuid-002', 'storage-uuid-001', 'Trứng gà', 'cat-uuid-002', 10, 'quả', '2025-06-05', '2025-06-25', 'Trứng gà ta', 'con_dung', NULL, '2025-06-09 20:08:17', '2025-06-11 23:15:26'),
('prod-uuid-003', 'storage-uuid-002', 'Cà chua', 'cat-uuid-001', 800, 'gram', '2025-06-09', '2025-06-14', 'Cà chua Đà Lạt', 'con_dung', NULL, '2025-06-09 20:08:17', '2025-06-09 20:08:17'),
('prod-uuid-004', 'storage-uuid-002', 'Hành lá', 'cat-uuid-001', 100, 'gram', '2025-06-09', '2025-06-11', '', 'con_dung', NULL, '2025-06-09 20:08:17', '2025-06-09 20:08:17'),
('prod-uuid-005', 'storage-uuid-002', 'Nước mắm', 'cat-uuid-003', 1, 'chai', '2025-05-10', '2026-05-10', 'Nước mắm Nam Ngư', 'con_dung', NULL, '2025-06-09 20:08:17', '2025-06-09 20:08:17'),
('prod-uuid-006', 'storage-uuid-001', 'Sữa tươi không đường', 'cat-uuid-005', 1, 'hộp 1L', '2025-06-01', '2025-06-07', 'Đã hết hạn hôm qua', 'het_han', NULL, '2025-06-09 20:08:17', '2025-06-09 20:08:17'),
('prod-uuid-007', 'storage-uuid-002', 'Gạo ST25', 'cat-uuid-004', 5, 'kg', '2025-06-01', '2025-12-01', 'Đã dùng một ít', 'con_dung', NULL, '2025-06-09 20:08:17', '2025-06-09 20:08:17');

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
('pl-uuid-001', 'prod-uuid-006', 'tu_dong_het_han', 1, 'Hệ thống tự động chuyển trạng thái', '2025-06-09 20:08:17'),
('pl-uuid-002', 'prod-uuid-007', 'da_dung', 1, 'Nấu bữa tối', '2025-06-09 20:08:17'),
('pl-uuid-003', 'prod-uuid-004', 'cap_nhat', 100, 'Mua thêm', '2025-06-09 20:08:17');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `shopping_lists`
--

CREATE TABLE `shopping_lists` (
  `id` char(36) NOT NULL,
  `user_id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `shopping_lists`
--

INSERT INTO `shopping_lists` (`id`, `user_id`, `name`, `created_at`, `updated_at`) VALUES
('sl-uuid-001', 'user-uuid-002', 'Đi chợ cuối tuần', '2025-06-09 11:00:00', '2025-06-09 11:00:00'),
('sl-uuid-002', 'user-uuid-003', 'mua đồ dụng cụ bếp', '2025-06-11 23:44:54', '2025-06-11 23:50:11'),
('sl-uuid-003', 'user-uuid-003', 'Đồ cần mua cho chuyến dã ngoại', '2025-06-11 23:49:01', '2025-06-11 23:49:01');

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
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `shopping_list_items`
--

INSERT INTO `shopping_list_items` (`id`, `shopping_list_id`, `product_id`, `item_name`, `quantity`, `unit`, `is_purchased`, `created_at`) VALUES
('sli-uuid-001', 'sl-uuid-001', NULL, 'Cá diêu hồng', 1, 'con', 0, '2025-06-09 20:08:17'),
('sli-uuid-002', 'sl-uuid-001', NULL, 'Bí đao', 1, 'trái', 1, '2025-06-09 20:08:17'),
('sli-uuid-003', 'sl-uuid-001', 'prod-uuid-005', 'Nước mắm', 1, 'chai', 0, '2025-06-09 20:08:17'),
('sli-uuid-004', 'sl-uuid-001', NULL, 'Dầu ăn', 1, 'chai', 1, '2025-06-09 20:08:17');

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
('storage-a-uuid', 'Kho đông lạnh - Đã cập nhật', 'user-uuid-001', NULL, '2025-06-11 10:39:30'),
('storage-uuid-001', 'Tủ lạnh nhà Văn A', 'user-uuid-001', NULL, '2025-06-09 10:10:00'),
('storage-uuid-002', 'Tủ bếp chung', 'user-uuid-002', NULL, '2025-06-09 10:11:00'),
('storage-uuid-003', 'Tủ lạnh nhà AB', 'user-uuid-002', NULL, '2025-06-11 11:34:17');

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
('member-uuid-001', 'storage-uuid-001', 'user-uuid-001', 'owner', '2025-06-09 10:10:00'),
('member-uuid-002', 'storage-uuid-002', 'user-uuid-002', 'owner', '2025-06-09 10:11:00'),
('member-uuid-003', 'storage-uuid-001', 'user-uuid-002', 'editor', '2025-06-11 11:31:56');

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
  ADD KEY `storage_id` (`storage_id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
