import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/portfolio_controller.dart';
import 'controllers/admin_controller.dart';
import 'screens/home_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'theme/portfolio_theme.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inject AdminController permanently
  Get.put(AdminController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject PortfolioController
    final portfolioController = Get.put(PortfolioController());

    return Obx(() {
      final isDark = portfolioController.isDarkMode.value;

      return GetMaterialApp(
        title: 'Sakil Hossen | Flutter Mobile Application Developer',
        debugShowCheckedModeBanner: false,
        theme: PortfolioTheme.lightTheme,
        darkTheme: PortfolioTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        getPages: [
          GetPage(
            name: '/',
            page: () => const HomeScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/admin',
            page: () => const AdminLoginScreen(),
            transition: Transition.rightToLeftWithFade,
          ),
          GetPage(
            name: '/admin/dashboard',
            page: () => const AdminDashboardScreen(),
            transition: Transition.zoom,
          ),
        ],
      );
    });
  }
}
