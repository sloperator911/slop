import 'package:blowjobboard/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool isRegistering = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BlowJobBoard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    if (isRegistering) ...[
                      TextFormField(
                        controller: nameController,
                        enabled: !auth.isSubmitting,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите имя';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: emailController,
                      enabled: !auth.isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || !value.trim().contains('@')) {
                          return 'Введите корректный e-mail';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      enabled: !auth.isSubmitting,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Минимум 6 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (auth.errorMessage != null) ...[
                      Text(
                        auth.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton(
                      onPressed: auth.isSubmitting
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;

                              await auth.authenticate(
                                emailController.text.trim(),
                                passwordController.text,
                                name: isRegistering
                                    ? nameController.text.trim()
                                    : null,
                              );
                            },
                      child: Text(
                        auth.isSubmitting
                            ? 'Отправка...'
                            : isRegistering
                            ? 'Зарегистрироваться'
                            : 'Войти',
                      ),
                    ),
                    TextButton(
                      onPressed: auth.isSubmitting
                          ? null
                          : () {
                              formKey.currentState!.reset();
                              passwordController.clear();
                              setState(() => isRegistering = !isRegistering);
                            },
                      child: Text(
                        isRegistering
                            ? 'Уже есть аккаунт? Войти'
                            : 'Создать аккаунт',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
