import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/account/services/account_service.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManagerDrawer extends StatelessWidget {
  const ManagerDrawer({super.key});

  void logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Log out confirm'),
          content: const Text('Are you sure to log out the app?'),
          actions: [
            // The "Yes" button
            TextButton(
              onPressed: () {
                final accountService = AccountService();
                accountService.logOut(context);

                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            // The "No" button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            )
          ],
        );
      },
    );
  }

  void navigateToManagerAccountScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/manager/account');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final username = userProvider.user.username;
    final email = userProvider.user.email;
    final imageUrl = userProvider.user.imageUrl;

    return Drawer(
      backgroundColor: GlobalVariables.green,
      child: Column(
        // padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              username,
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              email,
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl)
                    : Image.asset('assets/images/img_account.png'),
              ),
            ),
            decoration: const BoxDecoration(
              color: GlobalVariables.green,
              image: DecorationImage(
                image: AssetImage('assets/images/demo_facility.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            title: Text(
              'Profile',
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
            ),
            onTap: () => navigateToManagerAccountScreen(context),
          ),
          const Divider(color: GlobalVariables.white),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            title: Text(
              'Settings',
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            title: Text(
              'Sign out',
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
            ),
            onTap: () => logOut(context),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: GlobalVariables.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      'assets/vectors/vector-badcourt.svg',
                      colorFilter: ColorFilter.mode(
                        GlobalVariables.green,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    text: 'BAD',
                    style: GoogleFonts.alfaSlabOne(
                      color: GlobalVariables.yellow,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: 'COURT',
                        style: GoogleFonts.alfaSlabOne(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          )
        ],
      ),
    );
  }
}
