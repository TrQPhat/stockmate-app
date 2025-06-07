// models/index.js
const sequelize = require("../../config/db");
const User = require("./users");
const Product = require("./products");
const Cart = require("./carts");
const Category = require("./categories");
const Order = require("./orders");
const OrderDetail = require("./orderDetails");
const Review = require("./reviews");
const Voucher = require("./vouchers");
const Payment = require("./payments");
const Delivery = require("./deliveries");
const Table = require("./tables");
const Address = require("./addresses");
const Size = require("./size");
const Option = require("./option");

// Define associations
User.hasMany(Order, { foreignKey: "user_id" });
Order.belongsTo(User, { foreignKey: "user_id" });

Order.hasMany(OrderDetail, { foreignKey: "order_id", onDelete: "CASCADE" });
OrderDetail.belongsTo(Order, { foreignKey: "order_id" });

User.hasMany(Cart, { foreignKey: "user_id" });
Cart.belongsTo(User, { foreignKey: "user_id" });

Product.hasMany(Cart, { foreignKey: "product_id" });
Cart.belongsTo(Product, { foreignKey: "product_id" });

Product.belongsTo(Category, { foreignKey: "category_id" });
Category.hasMany(Product, { foreignKey: "category_id" });

Product.hasMany(Review, { foreignKey: "product_id" });
Review.belongsTo(Product, { foreignKey: "product_id" });

Product.hasMany(OrderDetail, { foreignKey: "product_id" });
OrderDetail.belongsTo(Product, { foreignKey: "product_id" });

User.hasMany(Review, { foreignKey: "user_id" });
Review.belongsTo(User, { foreignKey: "user_id" });

Order.belongsTo(Delivery, { foreignKey: "deliveries_id", onDelete: "CASCADE" });
Order.belongsTo(Payment, { foreignKey: "payments_id", onDelete: "CASCADE" });

User.hasMany(Address, { foreignKey: "user_id", onDelete: "CASCADE" });
Address.belongsTo(User, { foreignKey: "user_id" });

// Một sản phẩm (Product) có nhiều tùy chọn (Option)
Product.hasMany(Option, { foreignKey: "product_id", onDelete: "CASCADE" });
Option.belongsTo(Product, { foreignKey: "product_id" });

module.exports = {
  sequelize,
  User,
  Product,
  Cart,
  Category,
  Order,
  OrderDetail,
  Review,
  Voucher,
  Payment,
  Delivery,
  Table,
  Address,
  Size,
  Option,
};
