/// Defines the types of comparison operations that can be used to filter data.
///
/// Each value represents a logical operator, allowing for more flexible
/// filtering conditions beyond simple equality checks.
enum FilterType {
  /// Filters records where the value in the specified column is **equal** to a given value.
  ///
  /// Example: Get all users with `status` as `'active'`.
  eq,

  /// Filters records where the value in the specified column is **not equal** to a given value.
  ///
  /// Example: Get all products where `category` is not `'electronics'`.
  neq,

  /// Filters records where the numeric value in the specified column is **greater than** a given value.
  ///
  /// Example: Get all orders with `total_amount` greater than `100.00`.
  gt,

  /// Filters records where the numeric value in the specified column is **greater than or equal to** a given value.
  ///
  /// Example: Get all posts created after or on `2023-01-01`.
  gte,

  /// Filters records where the numeric value in the specified column is **less than** a given value.
  ///
  /// Example: Get all products with `stock` less than `10`.
  lt,

  /// Filters records where the numeric value in the specified column is **less than or equal to** a given value.
  ///
  /// Example: Get all users with `age` less than or equal to `18`.
  lte,

  /// Filters records where the value in the specified column is **included in a given list** of values.
  ///
  /// Example: Get all users with `role` as `'admin'` or `'moderator'`.
  in_, // Trailing underscore to avoid conflict with Dart's 'in' keyword

  /// Filters records where the value in the specified column is **not included in a given list** of values.
  ///
  /// Example: Get all tasks where `status` is neither `'completed'` nor `'cancelled'`.
  notIn,

  // You can add more filter types here as needed.
}

/// {@template client_filter}
/// Represents a single client-side filter condition to be applied to a dataset.
///
/// This class encapsulates the column to filter on, the type of comparison to perform,
/// and the value to compare against.
/// {@endtemplate}
class ClientFilter {
  /// The name of the column to apply the filter on.
  final String column;

  /// The type of comparison to perform (e.g., equals, greater than, less than).
  /// See [FilterType] for available options.
  final FilterType type;

  /// The value to compare against the column's data.
  ///
  /// The expected type of this value depends on the [type] of the filter and
  /// the data type of the [column]. For `in_` and `notIn` filter types,
  /// this value should be a `List`.
  final dynamic value;

  /// {@macro client_filter}
  const ClientFilter({
    required this.column,
    required this.type,
    required this.value,
  });
}
