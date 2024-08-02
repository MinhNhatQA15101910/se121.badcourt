import 'package:flutter_svg/svg.dart';
import 'package:frontend/common/widgets/facility_item.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/models/facility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:flutter/material.dart';

class SearchByLocationScreen extends StatefulWidget {
  static const String routeName = '/search-by-location';

  const SearchByLocationScreen({super.key});

  @override
  State<SearchByLocationScreen> createState() => _SearchByLocationScreenState();
}

class _SearchByLocationScreenState extends State<SearchByLocationScreen> {
  final _searchController = TextEditingController();
  final Facility _facility = Facility(
    id: '',
    userId: '',
    name: '',
    facebookUrl: '',
    phoneNumber: '',
    courtsAmount: 0,
    detailAddress: '',
    latitude: 0.0,
    longitude: 0.0,
    ratingAvg: 0.0,
    totalRating: 0,
    activeAt: Active(schedule: {}),
    registeredAt: 0,
    imageUrls: [],
    province: '',
    description: '',
    policy: '',
    maxPrice: 0,
    minPrice: 0,
    managerInfo: ManagerInfo(
      fullName: '',
      email: '',
      citizenId: '',
      citizenImageUrlFront: '',
      citizenImageUrlBack: '',
      bankCardUrlFront: '',
      bankCardUrlBack: '',
      businessLicenseImageUrls: [],
      id: '',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Find by location',
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
      body: Container(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            VietmapGL(
              styleString:
                  'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=506862bb03a3d71632bdeb7674a3625328cb7e5a9b011841',
              initialCameraPosition:
                  CameraPosition(target: LatLng(10.762317, 106.654551)),
              onMapCreated: (VietmapController controller) {
                setState(() {});
              },
            ),
            Column(
              children: [
                Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          child: Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Find badminton facilities',
                                hintStyle: GoogleFonts.inter(
                                  color: GlobalVariables.darkGrey,
                                  fontSize: 16,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: GlobalVariables.lightGreen,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: GlobalVariables.lightGreen,
                                  ),
                                ),
                                fillColor: GlobalVariables.white,
                                filled: true,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: GlobalVariables.darkGrey,
                                ),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 16,
                              ),
                              validator: (facilityName) {
                                if (facilityName == null ||
                                    facilityName.isEmpty) {
                                  return 'Please enter your facility name.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: GlobalVariables.grey,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/vectors/vector_reality_location.svg',
                                width: 32,
                                height: 32,
                                // ignore: deprecated_member_use
                                color: GlobalVariables.green,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                FacilityItem(
                  facility: _facility,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
