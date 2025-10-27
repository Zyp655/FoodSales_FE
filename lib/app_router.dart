import 'package:cnpm_ptpm/models/seller.dart';
import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/user/screens/change_password_screen.dart';
import 'features/user/screens/contact_info_screen.dart';
import 'features/user/screens/my_order_screen.dart';
import 'features/user/screens/product_detail_screen.dart';
import 'features/user/screens/profile_screen.dart';
import 'features/user/screens/search_screen.dart';
import 'features/user/screens/seller_detail_screen.dart';
import 'features/user/screens/settings_screen.dart';
import 'features/user/screens/user_home_screen.dart';
import 'features/user/screens/cart_screen.dart';
import 'features/user/screens/transaction_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/manage_users_screen.dart';
import 'features/seller/screens/seller_dashboard_screen.dart';
import 'features/seller/screens/manage_products_screen.dart';
import 'features/delivery/screens/delivery_home_screen.dart';
import 'features/delivery/screens/assigned_orders_screen.dart';
import 'models/user.dart';
import 'models/product.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case SignupScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case UserHomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());
      case SellerDashboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SellerDashboardScreen());
      case CartScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case MyOrdersScreen.routeName:
        return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
      case TransactionScreen.routeName:
        return MaterialPageRoute(builder: (_) => const TransactionScreen());
      case AdminDashboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case ContactInfoScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ContactInfoScreen());
      case ChangePasswordScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case DeliveryHomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const DeliveryHomeScreen());
      case AssignedOrdersScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AssignedOrdersScreen());
      case SettingsScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case ProfileScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case SellerDetailScreen.routeName:
        final seller = settings.arguments;
        if (seller != null && seller is Seller) {
          return MaterialPageRoute(builder: (_) => SellerDetailScreen(seller: seller));
        }
        return _errorRoute('Missing seller argument for SellerDetailScreen');
      case ProductDetailScreen.routeName:
        final product = settings.arguments;
        if (product != null && product is Product) {
          return MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product));
        }
        return _errorRoute('Missing product argument for ProductDetailScreen');
      case ManageUsersScreen.routeName:
        final user = settings.arguments;
        if (user != null && user is User) {
          return MaterialPageRoute(builder: (_) => ManageUsersScreen(user: user));
        }
        return _errorRoute('Missing user argument for ManageUsersScreen');
      case ManageProductsScreen.routeName:
        final product = settings.arguments as Product?;
        return MaterialPageRoute(builder: (_) => ManageProductsScreen(product: product));
      case SearchScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      );
    });
  }
}