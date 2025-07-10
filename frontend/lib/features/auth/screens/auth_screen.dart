import 'package:flutter/material.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = '/-auth';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    
    // Ensure we start with login form when entering auth screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if we should reset to login form
      if (authProvider.shouldShowLoginForm()) {
        authProvider.forceResetToLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: GlobalVariables.green,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, authProvider),
              
              // Main content
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  child: authProvider.authForm,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              // Reset auth state when going back
              authProvider.resetAuthState();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    authProvider.isPlayer ? 'Player' : 'Manager',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Authentication',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Role indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  authProvider.isPlayer ? Icons.sports_tennis : Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  authProvider.isPlayer ? 'Player' : 'Manager',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
