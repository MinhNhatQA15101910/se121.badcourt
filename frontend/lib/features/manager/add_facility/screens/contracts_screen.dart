import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/custom_buttom.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class ContractScreen extends StatefulWidget {
  static const String routeName = '/contracts';
  const ContractScreen({Key? key}) : super(key: key);

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  bool _checkBoxValue = false; // Di chuyển biến vào _FacilityInfoState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terms and contracts',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  color: GlobalVariables.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: GlobalVariables.white,
                child: _InterRegular16(
                  'ARTICLE 1: INTERPRETATION In this Agreement, the following terms will be interpreted as: 1.1. Terms of Service: means terms and conditions which are applicable to Seller, Buyer as making a transaction on Bad Court Platform.1.2. Order: means confirmation of transaction between Buyer and the parties of making order of Products on Bad Court Platform. 1.3. Cash Merchant: means a Seller who only receives payment in cash. 1.4. Bad Court Policy: means criteria, policies, rules, regulations, standards and/or any other provisions which Bad Court may issue from time to time to control the management, operation of Bad Court Platform and/or provide E-commerce service for Seller and/or Buyer. 1.5. Agreement: means this Agreement includes all Appendices, guidelines, regulations and all amendments or additions to relevant instruments. 1.6. Working day: means days (excluding Saturday and Sunday) that Banks open to work in Viet Nam. 1.7. Buyers or Users: means person, individual who buys Product on Bad Court Platform. 1.8. Bad Court Merchant: means Seller who uses Bad Court Merchant Wallet account to manage, control and request payment of Purchase amount from Bad Court.',
                  GlobalVariables.darkGrey,
                  1000,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: GlobalVariables.lightGrey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value:
                          _checkBoxValue, // Sử dụng giá trị từ _FacilityInfoState
                      onChanged: (newValue) {
                        setState(() {
                          _checkBoxValue = newValue ??
                              false; // Cập nhật giá trị của checkbox
                        });
                      },
                      activeColor: GlobalVariables
                          .green, // Màu của checkbox khi được chọn
                      checkColor: GlobalVariables
                          .white, // Màu của checkbox khi không được chọn
                    ),
                    Expanded(
                      child: _InterRegular16(
                        'I acknowledge that I have thoroughly read and consent to all the terms and conditions outlined above. I hereby agree to enter into a contract with Bad Court with the following fees to become an official partner: Commission Fee of 10%: Bad Court will deduct a commission fee of 10% for each successfully booking and pay the remaining amount to the Partner. Within 7 days from the successful registration of the store on the system, the Partner needs to complete the signing of the cooperation agreement with Bad Court. If the deadline is missed, the registration request will be canceled. In this case, the Partner please send an email to merchantsupport@badcourt.vn for assistance. By continuing with the registration, the Partner agrees to bear all legal responsibilities related to listing prohibited items on Bad Court',
                        GlobalVariables.darkGrey,
                        1000,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: GlobalVariables.lightGrey,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: CustomButton(
                  onTap: () => {},
                  buttonText: 'Confirm registration',
                  borderColor: GlobalVariables.green,
                  fillColor: GlobalVariables.green,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _InterRegular16(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 8,
        top: 12,
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
