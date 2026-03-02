import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/repositories/auth_repository_interface.dart';
import 'core/usecases/check_auth_usecase.dart';
import 'core/usecases/login_usecase.dart';
import 'core/usecases/logout_usecase.dart';
import 'core/usecases/register_usecase.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/services/api_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/tmdb_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/movies_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(WishMoviesApp(sharedPreferences: sharedPreferences));
}

class WishMoviesApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const WishMoviesApp({
    super.key,
    required this.sharedPreferences,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize services and repositories
    final apiService = ApiService();
    final tmdbService = TmdbService();
    final storageService = StorageService(prefs: sharedPreferences);
    final IAuthRepository authRepository = AuthRepositoryImpl(
      apiService: apiService,
      storageService: storageService,
    );

    // Initialize use cases
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final checkAuthUseCase = CheckAuthUseCase(authRepository);

    // Initialize AuthProvider with use cases
    final authProvider = AuthProvider(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      logoutUseCase: logoutUseCase,
      checkAuthUseCase: checkAuthUseCase,
    );

    // Initialize MoviesProvider
    final moviesProvider = MoviesProvider(
      tmdbService: tmdbService,
      apiService: apiService,
    );

    // Initialize ProfileProvider
    final profileProvider = ProfileProvider(
      apiService: apiService,
      tmdbService: tmdbService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<MoviesProvider>.value(value: moviesProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          final router = AppRouter.router(authProvider);

          return MaterialApp.router(
            title: 'WishMovies',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
