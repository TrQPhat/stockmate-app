import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int totalProducts;
  final int nearExpiry;
  final int expired;

  final bool isLoading;
  final String? error;

  const HomeState({
    this.totalProducts = 0,
    this.nearExpiry = 0,
    this.expired = 0,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    int? totalProducts,
    int? nearExpiry,
    int? expired,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      totalProducts: totalProducts ?? this.totalProducts,
      nearExpiry: nearExpiry ?? this.nearExpiry,
      expired: expired ?? this.expired,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        totalProducts,
        nearExpiry,
        expired,
        isLoading,
        error,
      ];
}
