import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../screens/public/home_screen.dart';
import '../screens/public/about_screen.dart';
import '../screens/public/services_screen.dart';
import '../screens/public/requirements_screen.dart';
import '../screens/public/news_screen.dart';
import '../screens/public/contact_screen.dart';
import '../screens/public/complaint_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/portal/portal_dashboard_screen.dart';
import '../screens/portal/application_form_screen.dart';
import '../screens/portal/application_detail_screen.dart';
import '../screens/portal/my_applications_screen.dart';
import '../screens/portal/facility_profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_facilities_screen.dart';
import '../screens/admin/admin_applications_screen.dart';
import '../screens/admin/admin_application_detail_screen.dart';
import '../screens/admin/admin_inspections_screen.dart';
import '../screens/admin/admin_notifications_screen.dart';
import '../screens/admin/admin_licenses_screen.dart';
import '../screens/admin/admin_violations_screen.dart';
import '../screens/admin/admin_payments_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/medical_staff_screen.dart';
import '../screens/admin/admin_inspection_checklist_screen.dart';
import '../screens/admin/admin_employees_screen.dart';
import '../screens/admin/media_management_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/public/public_license_search_screen.dart';


GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    routes: [
      // ===== Public Website =====
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
      GoRoute(path: '/services', builder: (_, __) => const ServicesScreen()),
      GoRoute(path: '/requirements', builder: (_, __) => const RequirementsScreen()),
      GoRoute(path: '/news', builder: (_, __) => const NewsScreen()),
      GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
      GoRoute(path: '/complaints', builder: (_, __) => const ComplaintScreen()),
      GoRoute(path: '/license-lookup', builder: (_, __) => PublicLicenseSearchScreen()),

      // ===== Auth =====
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),


      // ===== Portal (Facility Users) =====
      GoRoute(path: '/portal', builder: (_, __) => const PortalDashboardScreen()),
      GoRoute(
        path: '/portal/facilities/:id',
        builder: (_, state) => FacilityProfileScreen(
          facilityId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/portal/applications', builder: (_, __) => const MyApplicationsScreen()),
      GoRoute(
        path: '/portal/applications/new',
        builder: (_, state) {
          final fid = state.uri.queryParameters['facilityId'];
          return ApplicationFormScreen(
            preselectedFacilityId: fid != null && fid.isNotEmpty ? int.tryParse(fid) : null,
          );
        },
      ),
      GoRoute(
        path: '/portal/applications/:id',
        builder: (_, state) => ApplicationDetailScreen(
          applicationId: int.parse(state.pathParameters['id']!),
        ),
      ),

      // ===== Admin Dashboard =====
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/facilities', builder: (_, __) => const AdminFacilitiesScreen()),
      GoRoute(path: '/admin/applications', builder: (_, __) => const AdminApplicationsScreen()),
      GoRoute(
        path: '/admin/applications/:id',
        builder: (_, state) => AdminApplicationDetailScreen(
          applicationId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/admin/inspections', builder: (_, __) => const AdminInspectionsScreen()),
      GoRoute(
        path: '/admin/inspections/:id/checklist',
        builder: (_, state) => AdminInspectionChecklistScreen(
          inspectionId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/admin/medical-staff', builder: (_, __) => MedicalStaffScreen()),
      GoRoute(path: '/admin/notifications', builder: (_, __) => const AdminNotificationsScreen()),
      GoRoute(path: '/admin/licenses', builder: (_, __) => const AdminLicensesScreen()),
      GoRoute(path: '/admin/violations', builder: (_, __) => const AdminViolationsScreen()),
      GoRoute(path: '/admin/payments', builder: (_, __) => const AdminPaymentsScreen()),
      GoRoute(path: '/admin/settings', builder: (_, __) => const AdminSettingsScreen()),
      GoRoute(path: '/admin/employees', builder: (_, __) => const AdminEmployeesScreen()),
      GoRoute(path: '/admin/media', builder: (_, __) => const MediaManagementScreen()),
      GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersScreen()),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToPortal = state.matchedLocation.startsWith('/portal');
      final isGoingToAdmin = state.matchedLocation.startsWith('/admin');

      if ((isGoingToPortal || isGoingToAdmin) && !isLoggedIn) {
        return '/login';
      }

      if (isGoingToLogin && isLoggedIn) {
        return authProvider.isAdmin ? '/admin' : '/portal';
      }

      if (isGoingToAdmin && isLoggedIn && !authProvider.isAdmin) {
        return '/portal';
      }

      if (isGoingToPortal && isLoggedIn && authProvider.isAdmin) {
        return '/admin';
      }

      return null;
    },
  );
}
