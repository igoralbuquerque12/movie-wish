import 'package:go_router/go_router.dart';
import '../core/models/auth_state.dart';
import '../core/models/movie_model.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/movie_details_screen.dart';
import '../presentation/screens/new_home_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/splash_screen.dart';

/// App Router Configuration with GoRouter
/// Includes route protection based on authentication state
class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = authProvider.authState;
        final isAuthenticated = authState.status == AuthStatus.authenticated;
        final isLoading = authState.status == AuthStatus.loading;

        final isGoingToSplash = state.matchedLocation == '/splash';
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';
        final isGoingToProtectedRoute = state.matchedLocation == '/new-home' ||
            state.matchedLocation == '/home' ||
            state.matchedLocation == '/movie-details';

        // If loading, stay on splash
        if (isLoading && !isGoingToSplash) {
          return '/splash';
        }

        // If authenticated
        if (isAuthenticated) {
          // Redirect to new-home if trying to access login/register/splash
          if (isGoingToLogin || isGoingToRegister || isGoingToSplash) {
            return '/new-home';
          }
        }

        // If not authenticated
        if (!isAuthenticated && !isLoading) {
          // Redirect to login if trying to access protected routes
          if (isGoingToProtectedRoute) {
            return '/login';
          }
          // Redirect from splash to login after auth check
          if (isGoingToSplash) {
            return '/login';
          }
        }

        // No redirect needed
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/new-home',
          name: 'new-home',
          builder: (context, state) => const NewHomeScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/movie-details',
          name: 'movie-details',
          builder: (context, state) {
            final movie = state.extra as MovieModel;
            return MovieDetailsScreen(movie: movie);
          },
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
      refreshListenable: authProvider,
      debugLogDiagnostics: true,
    );
  }
}
