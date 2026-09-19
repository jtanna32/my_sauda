import 'package:go_router/go_router.dart';
import 'package:my_sauda/features/auth/view/forgot_password_screen.dart';
import 'package:my_sauda/features/auth/view/home_screen.dart';
import 'package:my_sauda/features/auth/view/login_screen.dart';
import 'package:my_sauda/features/auth/view/register_screen.dart';
import 'package:my_sauda/features/firms/model/firm.dart';
import 'package:my_sauda/features/firms/view/firms_list_screen.dart';
import 'package:my_sauda/features/firms/view/add_edit_firm_screen.dart';
import 'package:my_sauda/features/parties/model/party.dart';
import 'package:my_sauda/features/parties/view/parties_list_screen.dart';
import 'package:my_sauda/features/parties/view/add_edit_party_screen.dart';
import 'package:my_sauda/features/sauda/model/sauda.dart';
import 'package:my_sauda/features/sauda/view/saudas_list_screen.dart';
import 'package:my_sauda/features/sauda/view/add_edit_sauda_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/parties',
      builder: (context, state) => const PartiesListScreen(),
    ),
    GoRoute(
      path: '/add-party',
      builder: (context, state) {
        final extra = state.extra as Party?;

        return AddEditPartyScreen(
          party: extra,
        );
      },
    ),
    GoRoute(
      path: '/firms',
      builder: (context, state) => const FirmsListScreen(),
    ),
    GoRoute(
      path: '/add-firm',
      builder: (context, state) {
        final extra = state.extra as Firm?;

        return AddEditFirmScreen(
          firm: extra,
        );
      },
    ),
    GoRoute(
      path: '/saudas',
      builder: (context, state) => const SaudasListScreen(),
    ),
    GoRoute(
      path: '/add-sauda',
      builder: (context, state) {
        final extra = state.extra as Sauda?;

        return AddEditSaudaScreen(
          sauda: extra,
        );
      },
    ),
  ],
);