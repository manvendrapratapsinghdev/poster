import 'package:flutter/material.dart';
import 'package:social_post_mobile/screens/template_detail_screen.dart';
import 'package:social_post_mobile/screens/templates/template_list_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/category_list_screen.dart';


class AppRoutes {
  static const splash = SplashScreen.routeName;
  static const onboarding = OnboardingScreen.routeName;
  static const login = LoginScreen.routeName;
  static const signup = SignupScreen.routeName;
  static const home = HomeScreen.routeName;
  static const favorites = FavoritesScreen.routeName;
  static const categories = CategoryListScreen.routeName;

  static const templateDetail = TemplateDetailScreen.routeName;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      // case profile:
      //   return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoryListScreen());

      case templateDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TemplateDetailScreen(templateId: args?['id']),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
