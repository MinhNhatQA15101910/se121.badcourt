import 'package:flutter/material.dart';
import 'package:frontend/common/widgets/single_facility_card.dart';
import 'package:frontend/constants/global_variables.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: GlobalVariables.green,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'FAVORITE',
                  style: GoogleFonts.alfaSlabOne(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: GlobalVariables.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => {},
                iconSize: 24,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: GlobalVariables.white,
                ),
              ),
              IconButton(
                onPressed: () => {},
                iconSize: 24,
                icon: const Icon(
                  Icons.message_outlined,
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Center(
                      child: Container(
                        height: 240,
                        width: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1000),
                          color: GlobalVariables.lightGreen,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.favorite,
                            color: GlobalVariables.green,
                            size: 180,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              _InterBold24(
                'No favorites yet!',
                GlobalVariables.blackGrey,
                1,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: _InterRegular16(
                  'Let’s add some badminton courts to your favorite list.',
                  GlobalVariables.darkGrey,
                  3,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                height: 12,
                color: GlobalVariables.defaultColor,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended for you',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                'View more',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: GlobalVariables.green,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_outlined,
                                color: GlobalVariables.green,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GridView.builder(
                      itemCount: 10,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3 / 5,
                      ),
                      itemBuilder: (context, index) {
                        return const SingleFacilityCard();
                      },
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ],
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
        top: 4,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
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

  Widget _InterBold24(String text, Color color, int maxLines) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
