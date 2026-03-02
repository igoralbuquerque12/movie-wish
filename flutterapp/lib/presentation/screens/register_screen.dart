import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/models/genre_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/genre_chip.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // MUDANÇA 1: agora Set<int>
  final Set<int> _selectedGenres = {};

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // MUDANÇA 2: recebe int
  void _toggleGenre(int genreId) {
    setState(() {
      if (_selectedGenres.contains(genreId)) {
        _selectedGenres.remove(genreId);
      } else {
        _selectedGenres.add(genreId);
      }

      // limpa erro ao selecionar algo
      if (_selectedGenres.isNotEmpty) {
        _errorMessage = null;
      }
    });
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGenres.isEmpty) {
      setState(() {
        _errorMessage = 'Selecione pelo menos 1 gênero favorito';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      favoriteGenres: _selectedGenres.toList(), // lista de int
    );

    setState(() {
      _isLoading = false;
    });

    if (!success && mounted) {
      setState(() {
        _errorMessage = authProvider.errorMessage;
      });
    }

    // Navegação é automática pelo GoRouter após login
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter no mínimo 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading
              ? null
              : () {
            context.go('/login');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Criar Conta',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),

                Text(
                  'Preencha os dados abaixo',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                CustomTextField(
                  controller: _nameController,
                  label: 'Nome',
                  hint: 'Seu nome completo',
                  prefixIcon: Icons.person_outline,
                  validator: _validateName,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'seu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateEmail,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Mínimo 6 caracteres',
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: _validatePassword,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),

                Text(
                  'Gêneros Favoritos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                Text(
                  'Selecione pelo menos 1 gênero',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // MUDANÇA 3: GenreChip usando int
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GenreModel.allGenres.map((genre) {
                    return GenreChip(
                      genre: genre,
                      isSelected: _selectedGenres.contains(genre.id),
                      onTap: () => _toggleGenre(genre.id),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Criar Conta',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem uma conta? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        context.go('/login');
                      },
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
