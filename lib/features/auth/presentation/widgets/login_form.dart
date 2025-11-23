import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../bloc/auth_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
  }



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is AuthAuthenticated) {
          // Переходим на главный экран
          _showSuccessAndNavigate(context, state.user);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Логотип
                    Icon(
                      Icons.directions_car,
                      size: 80,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AutoSalon',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Управление автосалоном',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Toggle between login and registration
                    ToggleButtons(
                      isSelected: [_isLogin, !_isLogin],
                      onPressed: (index) {
                        setState(() {
                          _isLogin = index == 0;
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedColor: Colors.white,
                      fillColor: Colors.blue[700],
                      color: Colors.blue[700],
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        minWidth: 120,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Вход'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Регистрация'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Поле имени (только для регистрации)
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!_isLogin) {
                            if (value == null || value.isEmpty) {
                              return 'Введите имя';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Поле email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        if (!value.contains('@')) {
                          return 'Введите корректный email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Поле пароля
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен быть не менее 6 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Кнопка входа/регистрации
                    state is AuthLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_isLogin) {
                              // Вход
                              context.read<AuthBloc>().add(
                                LoginEvent(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              );
                            } else {
                              // Регистрация
                              context.read<AuthBloc>().add(
                                RegisterEvent(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          _isLogin ? 'Войти' : 'Зарегистрироваться',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Тестовые данные (только для входа)
                    if (_isLogin) ...[
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Тестовые доступы:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  void _showSuccessAndNavigate(BuildContext context, UserModel user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Добро пожаловать, ${user.name}!'),
        backgroundColor: Colors.green,
      ),
    );

    // Переходим на главный экран и передаем пользователя
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(user: user),
        ),
      );
    });
  }
}
