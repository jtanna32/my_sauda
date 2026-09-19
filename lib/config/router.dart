import 'package:go_router/go_router.dart';
import 'package:my_sauda/config/auth_refresh_listenable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_sauda/features/auth/view/forgot_password_screen.dart';
import 'package:my_sauda/features/auth/view/home_screen.dart';
import 'package:my_sauda/features/auth/view/login_screen.dart';
import 'package:my_sauda/features/auth/view/register_screen.dart';
import 'package:my_sauda/features/bills/model/bill.dart';
import 'package:my_sauda/features/bills/view/bill_preview_screen.dart';
import 'package:my_sauda/features/bills/view/bill_view_screen.dart';
import 'package:my_sauda/features/bills/view/bills_screen.dart';
import 'package:my_sauda/features/bills/view/generate_bill_screen.dart';
import 'package:my_sauda/features/firms/model/firm.dart';
import 'package:my_sauda/features/firms/view/firms_list_screen.dart';
import 'package:my_sauda/features/firms/view/add_edit_firm_screen.dart';
import 'package:my_sauda/features/parties/model/party.dart';
import 'package:my_sauda/features/parties/view/parties_list_screen.dart';
import 'package:my_sauda/features/parties/view/add_edit_party_screen.dart';
import 'package:my_sauda/features/sauda/model/new_sauda_preset.dart';
import 'package:my_sauda/features/sauda/model/sauda.dart';
import 'package:my_sauda/features/sauda/view/saudas_list_screen.dart';
import 'package:my_sauda/features/sauda/view/add_edit_sauda_screen.dart';

const _publicRoutes = {'/login', '/register', '/forgot-password'};

String? authRedirect({required bool hasSession, required String location}) {
  final isPublic = _publicRoutes.contains(location);
  if (!hasSession && !isPublic) return '/login';
  if (hasSession && isPublic) return '/home';
  return null;
}

final router = GoRouter(
  initialLocation: '/home',
  refreshListenable:
      AuthRefreshListenable(Supabase.instance.client.auth.onAuthStateChange),
  redirect: (context, state) => authRedirect(
    hasSession: Supabase.instance.client.auth.currentSession != null,
    location: state.matchedLocation,
  ),
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
        final extra = state.extra;

        return AddEditPartyScreen(
          party: extra is Party ? extra : null,
          initialName: extra is String ? extra : null,
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
        final extra = state.extra;

        return AddEditSaudaScreen(
          sauda: extra is Sauda ? extra : null,
          preset: extra is NewSaudaPreset ? extra : null,
        );
      },
    ),
    GoRoute(
      path: '/bills',
      builder: (context, state) => const BillsScreen(),
    ),
    GoRoute(
      path: '/generate-bill',
      builder: (context, state) => const GenerateBillScreen(),
    ),
    GoRoute(
      path: '/bill-preview',
      builder: (context, state) => const BillPreviewScreen(),
    ),
    GoRoute(
      path: '/bill-view',
      builder: (context, state) => BillViewScreen(bill: state.extra as Bill),
    ),
  ],
);