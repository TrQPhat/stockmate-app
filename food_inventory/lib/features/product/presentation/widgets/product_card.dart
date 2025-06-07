import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.inventory_2,
                        color: Colors.grey[400],
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildStatusChip(context),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    if (product.category != null)
                      Text(
                        product.category!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${product.quantity} ${product.unit ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    if (product.expireDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'HSD: ${DateFormat('dd/MM/yyyy').format(product.expireDate!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getExpireDateColor(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String text;
    
    switch (product.status) {
      case ProductStatus.conDung:
        color = Colors.green;
        text = 'Còn dùng';
        break;
      case ProductStatus.hetHan:
        color = Colors.red;
        text = 'Hết hạn';
        break;
      case ProductStatus.daDung:
        color = Colors.grey;
        text = 'Đã dùng';
        break;
      case ProductStatus.huy:
        color = Colors.orange;
        text = 'Hủy';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getExpireDateColor() {
    if (product.expireDate == null) return Colors.grey;
    
    final now = DateTime.now();
    final daysUntilExpire = product.expireDate!.difference(now).inDays;
    
    if (daysUntilExpire < 0) {
      return Colors.red; // Expired
    } else if (daysUntilExpire <= 3) {
      return Colors.orange; // Expiring soon
    } else {
      return Colors.grey; // Normal
    }
  }
}
