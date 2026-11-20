import 'package:flutter/widgets.dart';

import 'package:mobile_onboarding/Screens/sign_in/SignInScreen.dart';
import 'package:mobile_onboarding/screens/account/account_request_screen.dart';
import 'package:mobile_onboarding/screens/newDashboard/alerts_status_screen.dart';
import 'package:mobile_onboarding/screens/blankScreen/blankScreen.dart';
import 'package:mobile_onboarding/screens/contact_us/contact_us_screen.dart';
import 'package:mobile_onboarding/screens/dashboard/dashboard_screen.dart';
import 'package:mobile_onboarding/screens/dynamic_jour_steps/steps_main.dart';
import 'package:mobile_onboarding/screens/home/home_screen.dart';
import 'package:mobile_onboarding/screens/loan/loan_request_screen.dart';
import 'package:mobile_onboarding/screens/newSingINScreen/newSingINMain.dart';
import 'package:mobile_onboarding/screens/newSingUpScreen/newSingupMain.dart';
import 'package:mobile_onboarding/screens/new_product_list/product_list_main.dart';
import 'package:mobile_onboarding/screens/noorcard/noor_card_screen.dart';
import 'package:mobile_onboarding/screens/otp/newSingIn_OTP_Screen/signIn_OTP_Screen.dart';
import 'package:mobile_onboarding/screens/otp/newSingUP_OTP_Screen/signUp_OTP_Screen.dart';

import 'package:mobile_onboarding/screens/product_list/product_list_screen.dart';
import 'package:mobile_onboarding/screens/productdetails/product_detail_screen.dart';
import 'package:mobile_onboarding/screens/products/products_screen.dart';
import 'package:mobile_onboarding/screens/profile/profile_screen.dart';
import 'package:mobile_onboarding/screens/requests/request_status_screen.dart';
import 'package:mobile_onboarding/screens/sign_up/sign_up_screen.dart';
import 'package:mobile_onboarding/screens/splash/splash_screen.dart';
import 'package:mobile_onboarding/screens/welcome/welcome_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  NewSignUpScreen.routeName: (context) => const NewSignUpScreen(),
  NewSignInScreen.routeName: (context) => const NewSignInScreen(),

  HomeScreen.routeName: (context) => HomeScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
  WelcomeScreen.routeName: (context) => WelcomeScreen(),
  // ProductListScreen.routeName: (context) => ProductListScreen(),
  NewProductListScreen.routeName: (context) => NewProductListScreen(),
  AccountScreen.routeName: (context) => AccountScreen(),
  LoanRequestScreen.routeName: (context) => LoanRequestScreen(),
  RequestStatusScreen.routeName: (context) => RequestStatusScreen(),
  ContactScreen.routeName: (context) => ContactScreen(),
  ProductsDetailScreen.routeName: (context) => ProductsDetailScreen(),
  DashboardScreen.routeName: (context) => DashboardScreen(),
  NoorCardScreen.routeName: (context) => NoorCardScreen(),
  BlankScreen.routeName: (context) => BlankScreen(),
  SingUpOtpScreen.routeName: (context) => const SingUpOtpScreen(),
  ProductsScreen.routeName: (context) => ProductsScreen(),
  ProductsScreenMain.routeName: (context) => ProductsScreenMain(),
  AlertsStatusScreen.routeName: (context) => AlertsStatusScreen(),
  SingInOtpScreen.routeName: (context) => SingInOtpScreen(),
};
