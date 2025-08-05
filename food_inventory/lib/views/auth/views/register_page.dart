import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stock_mate/bloc/auth/auth_bloc.dart';
import 'package:stock_mate/views/auth/widgets/auth_text_field.dart';

import '../../../../core/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Đăng ký'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            // Thay đổi ở đây
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Đăng ký thành công! Vui lòng kiểm tra email để xác thực.'),
                backgroundColor: AppTheme.primaryGreen,
              ),
            );
            context.go('/login');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.replaceFirst('Exception: ', '')),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),

                  // Full name field
                  AuthTextField(
                    controller: _fullNameController,
                    label: 'Họ và tên',
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  // AuthTextField(
                  //   controller: _passwordController,
                  //   label: 'Mật khẩu',
                  //   obscureText: true,
                  //   validator: (value) {
                  //     if (value?.isEmpty ?? true) {
                  //       return 'Vui lòng nhập mật khẩu';
                  //     }
                  //     if (value!.length < 8) {
                  //       return 'Mật khẩu phải có ít nhất 8 ký tự';
                  //     }
                  //     if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
                  //       return 'Mật khẩu phải có ít nhất 1 chữ thường';
                  //     }
                  //     if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                  //       return 'Mật khẩu phải có ít nhất 1 chữ hoa';
                  //     }
                  //     if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                  //       return 'Mật khẩu phải có ít nhất 1 chữ số';
                  //     }
                  //     if (!RegExp(r'(?=.*[\W_])').hasMatch(value)) {
                  //       // \W là ký tự không phải chữ/số
                  //       return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  SizedBox(height: 16.h),

                  // Gender field
                  Text(
                    'Giới tính',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Nam', style: TextStyle(fontSize: 14.sp)),
                          value: 'Nam',
                          groupValue: _selectedGender,
                          selected: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppTheme.primaryGreen,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Nữ', style: TextStyle(fontSize: 14.sp)),
                          value: 'Nữ',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppTheme.primaryGreen,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title:
                              Text('Khác', style: TextStyle(fontSize: 14.sp)),
                          value: 'Khác',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value!)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Phone field
                  AuthTextField(
                    controller: _phoneController,
                    label: 'Số điện thoại (tùy chọn)',
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16.h),

                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Mật khẩu',
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value!.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Confirm password field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: 'Xác nhận mật khẩu',
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng xác nhận mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),

                  // Register button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: state is AuthLoading ? null : _register,
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Login link
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Đã có tài khoản? ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                          children: const [
                            TextSpan(
                              text: 'Đăng nhập',
                              style: TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              gender: _selectedGender!,
              phone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
            ),
          );
    }
  }
}
