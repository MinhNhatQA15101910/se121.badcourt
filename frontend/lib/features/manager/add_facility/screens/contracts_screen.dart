import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/providers/new_facility_provider.dart';
import 'package:frontend/features/manager/add_facility/services/add_facility_service.dart';
import 'package:frontend/features/manager/intro_manager/screens/intro_manager_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContractScreen extends StatefulWidget {
  static const String routeName = '/manager/contracts';
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen>
    with TickerProviderStateMixin {
  final _addFacilityService = AddFacilityService();
  final ScrollController _scrollController = ScrollController();

  bool _checkBoxValue = false;
  bool _isLoading = false;
  bool _hasScrolledToBottom = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  void _navigateToIntroManagerScreen() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      IntroManagerScreen.routeName,
      (route) => false,
    );
  }

  Future<void> _submitFacility() async {
    if (!_checkBoxValue) {
      _showValidationSnackBar('Please accept the terms and conditions to continue.');
      return;
    }

    if (!_hasScrolledToBottom) {
      _showValidationSnackBar('Please read through all terms and conditions.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<NewFacilityProvider>(context, listen: false);
      
      if (provider.isEditMode && provider.originalFacility != null) {
        // Update existing facility
        await _addFacilityService.updateFacility(
          context: context,
          facility: provider.originalFacility!,
        );
      } else {
        // Create new facility
        await _addFacilityService.registerFacility(context: context);
      }
      
      _navigateToIntroManagerScreen();
    } catch (e) {
      _showValidationSnackBar('Operation failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showValidationSnackBar(String message) {
    IconSnackBar.show(
      context,
      label: message,
      snackBarType: SnackBarType.fail,
    );
  }

  Widget _buildHeader() {
    final provider = Provider.of<NewFacilityProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GlobalVariables.green,
            GlobalVariables.green.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.isEditMode 
                        ? 'Review terms for facility update'
                        : 'Please read carefully before proceeding',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            _hasScrolledToBottom ? Icons.check_circle : Icons.info_outline,
            color: _hasScrolledToBottom ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _hasScrolledToBottom 
                ? 'You have read all terms' 
                : 'Please scroll to read all terms',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _hasScrolledToBottom ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Article 1
          _buildTermsSection(
            'ARTICLE 1: INTERPRETATION',
            'In this Agreement, the following terms will be interpreted as:\n\n'
            '1.1. Terms of Service: means terms and conditions which are applicable to Seller, Buyer as making a transaction on Bad Court Platform.\n\n'
            '1.2. Order: means confirmation of transaction between Buyer and the parties of making order of Products on Bad Court Platform.\n\n'
            '1.3. Cash Merchant: means a Seller who only receives payment in cash.\n\n'
            '1.4. Bad Court Policy: means criteria, policies, rules, regulations, standards and/or any other provisions which Bad Court may issue from time to time to control the management, operation of Bad Court Platform and/or provide E-commerce service for Seller and/or Buyer.\n\n'
            '1.5. Agreement: means this Agreement includes all Appendices, guidelines, regulations and all amendments or additions to relevant instruments.\n\n'
            '1.6. Working day: means days (excluding Saturday and Sunday) that Banks open to work in Viet Nam.\n\n'
            '1.7. Buyers or Users: means person, individual who buys Product on Bad Court Platform.\n\n'
            '1.8. Bad Court Merchant: means Seller who uses Bad Court Merchant Wallet account to manage, control and request payment of Purchase amount from Bad Court.',
            Icons.article_outlined,
          ),
          
          const Divider(height: 1),
          
          // Partnership Terms
          _buildTermsSection(
            'PARTNERSHIP TERMS',
            'I acknowledge that I have thoroughly read and consent to all the terms and conditions outlined above. I hereby agree to enter into a contract with Bad Court with the following fees to become an official partner:\n\n'
            '• Commission Fee of 10%: Bad Court will deduct a commission fee of 10% for each successful booking and pay the remaining amount to the Partner.\n\n'
            '• Within 7 days from the successful registration of the store on the system, the Partner needs to complete the signing of the cooperation agreement with Bad Court.\n\n'
            '• If the deadline is missed, the registration request will be canceled. In this case, the Partner please send an email to merchantsupport@badcourt.vn for assistance.\n\n'
            '• By continuing with the registration, the Partner agrees to bear all legal responsibilities related to listing prohibited items on Bad Court.',
            Icons.handshake_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GlobalVariables.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: GlobalVariables.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GlobalVariables.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _checkBoxValue ? GlobalVariables.green : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: _checkBoxValue,
                  onChanged: _hasScrolledToBottom ? (newValue) {
                    setState(() {
                      _checkBoxValue = newValue ?? false;
                    });
                  } : null,
                  activeColor: GlobalVariables.green,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agreement Confirmation',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'I have read and agree to all terms and conditions, including the 10% commission fee and partnership requirements.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_hasScrolledToBottom)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please scroll through all terms before accepting',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final provider = Provider.of<NewFacilityProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _checkBoxValue && _hasScrolledToBottom ? [
            BoxShadow(
              color: GlobalVariables.green.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ] : [],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: (_checkBoxValue && _hasScrolledToBottom && !_isLoading) 
                ? _submitFacility 
                : null,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle_outline, size: 24),
            label: Text(
              _isLoading 
                  ? 'Processing...' 
                  : provider.isEditMode 
                      ? 'Confirm Update'
                      : 'Confirm Registration',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: (_checkBoxValue && _hasScrolledToBottom) 
                  ? GlobalVariables.green 
                  : Colors.grey.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildTermsContent(),
                    _buildAgreementSection(),
                    const SizedBox(height: 80), // Space for button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }
}
