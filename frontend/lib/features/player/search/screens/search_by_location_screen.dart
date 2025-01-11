import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/common/widgets/facility_item.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:frontend/features/manager/add_facility/models/detail_address.dart';
import 'package:frontend/features/player/search/services/search_service.dart';
import 'package:frontend/models/active.dart';
import 'package:frontend/models/coordinates.dart';
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/location.dart';
import 'package:frontend/models/manager_info.dart';
import 'package:frontend/providers/sort_provider.dart';
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
  VietmapController? _mapController;
  bool isFacilityItemVisible = false;
  LatLng markerPosition = LatLng(10.762317, 106.654551);
  final _searchController = TextEditingController();
  final _searchService = SearchService();
  String _searchCode = "";
  List<Facility> _facilities = [];

  List<Marker> markers = [];

  DetailAddress _detailAddress = DetailAddress(
    display: '',
    name: '',
    hsNum: '',
    street: '',
    address: '',
    cityId: 0,
    city: '',
    districtId: 0,
    district: '',
    wardId: 0,
    ward: '',
    lat: 0.0,
    lng: 0.0,
  );

  Facility _facility = Facility(
    id: 'default_id',
    userId: 'default_userId',
    name: 'Default Facility Name',
    facebookUrl: 'https://www.facebook.com/default',
    courtsAmount: 1,
    detailAddress: '123 Default Street, Default City',
    province: 'Default Province',
    location: Location(
      type: 'Point',
      coordinates: Coordinates(
        longitude: 0.0,
        latitude: 0.0,
      ),
    ),
    ratingAvg: 4.5,
    totalRating: 100,
    activeAt: Active(schedule: {}),
    registeredAt: DateTime.now().millisecondsSinceEpoch,
    description: 'This is a default facility description.',
    policy: 'Default policy for this facility.',
    maxPrice: 200000,
    minPrice: 100000,
    managerInfo: ManagerInfo(
      fullName: 'Default Manager',
      email: 'manager@example.com',
      phoneNumber: '0123456789',
      citizenId: '123456789',
      citizenImageUrlFront: 'https://via.placeholder.com/150',
      citizenImageUrlBack: 'https://via.placeholder.com/150',
      bankCardUrlFront: 'https://via.placeholder.com/150',
      bankCardUrlBack: 'https://via.placeholder.com/150',
      businessLicenseImageUrls: [
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/200',
      ],
      id: 'default_manager_id',
    ),
    facilityImages: [
      FacilityImage(
        url: 'https://via.placeholder.com/150',
        isMain: true,
        publicId: 'default_image_id_1',
      ),
      FacilityImage(
        url: 'https://via.placeholder.com/200',
        isMain: false,
        publicId: 'default_image_id_2',
      ),
    ],
    isApproved: false,
    approvedAt: 0,
    distance: 0.0,
  );

  void _fetchAllFacilities() async {
    try {
      _facilities = await _searchService.fetchAllFacilities(
        context: context,
        sort: Sort.location_asc,
      );

      print("Fetched facilities: ${_facilities.length}");
      for (var facility in _facilities) {
        print(
            "Facility: ${facility.name}, Latitude: ${facility.location.coordinates.latitude}, Longitude: ${facility.location.coordinates.longitude}");
      }

      setState(() {
        markers = _buildMarkers();
      });
    } catch (e) {
      print("Error fetching facilities: $e");
    }
  }

  Future<void> _performSearch(String value) async {
    if (value.isNotEmpty) {
      try {
        final searchCode = await _searchService.fetchAddressRefId(
          context: context,
          searchText: value,
        );

        if (searchCode != null) {
          setState(() {
            _searchCode = searchCode;
          });

          // Tiếp tục lấy địa chỉ chi tiết
          final detailAddress = await _searchService.fetchDetailAddress(
            refId: _searchCode,
          );

          if (detailAddress != null) {
            setState(() {
              _detailAddress = detailAddress;
              markerPosition = LatLng(_detailAddress.lat, _detailAddress.lng);

              // Cập nhật vị trí camera trên bản đồ
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: markerPosition, zoom: 15),
                ),
              );
            });
          }
        }
      } catch (e) {
        print('Error during search: $e');
      }
    }
  }

  void _pingMarker() async {
    if (_mapController != null) {
      LatLng? currentLocation = await _mapController?.requestMyLocationLatLng();

      if (currentLocation != null) {
        setState(() {
          markerPosition = currentLocation;
        });

        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: markerPosition, zoom: 15),
          ),
        );

        setState(() {});

        Future.delayed(Duration(seconds: 1), () {
          setState(() {});
        });
      }
    }
  }

  List<Marker> _buildMarkers() {
    return _facilities.map((facility) {
      return Marker(
        alignment: Alignment.bottomCenter,
        height: 50,
        width: 50,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _facility = facility;
              isFacilityItemVisible = true;
              _mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(facility.location.coordinates.latitude,
                        facility.location.coordinates.longitude),
                    zoom: 15,
                  ),
                ),
              );
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0.2,
                  blurRadius: 32,
                ),
              ],
            ),
            child: SvgPicture.asset(
              'assets/vectors/vector_location_icon.svg',
              width: 80,
              height: 80,
            ),
          ),
        ),
        latLng: LatLng(
          facility.location.coordinates.latitude,
          facility.location.coordinates.longitude,
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchAllFacilities(); // Fetch dữ liệu và tự động cập nhật markers
  }

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
              myLocationTrackingMode: MyLocationTrackingMode.Tracking,
              myLocationEnabled: true,
              trackCameraPosition: true,
              styleString: dotenv.env['VIETMAP_STRING_KEY']!,
              initialCameraPosition: CameraPosition(
                  target: LatLng(10.762317, 106.654551), zoom: 15),
              onMapCreated: (VietmapController controller) {
                setState(() {
                  _mapController = controller;
                });
              },
            ),
            _mapController == null
                ? SizedBox.shrink()
                : MarkerLayer(
                    markers: markers,
                    mapController: _mapController!,
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
                              onFieldSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _performSearch(value);
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        GestureDetector(
                          onTap: _pingMarker,
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
                if (isFacilityItemVisible)
                  Stack(
                    children: [
                      FacilityItem(
                        facility: _facility,
                      ),
                      Positioned(
                        top: 8,
                        right: 24,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isFacilityItemVisible = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}
