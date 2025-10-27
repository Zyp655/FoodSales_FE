import 'package:cnpm_ptpm/features/user/screens/seller_detail_screen.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannerSection extends StatelessWidget {
  final Seller seller;
  const BannerSection({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    final bannerImage = seller.image != null
        ? NetworkImage('http://10.0.2.2:8000/storage/${seller.image!}')
        : const NetworkImage('https://via.placeholder.com/600x200/CCCCCC/FFFFFF?text=Featured+Shop') as ImageProvider;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          SellerDetailScreen.routeName,
          arguments: seller,
        );
      },
      child: Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: bannerImage,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
            onError: (exception, stackTrace) {},
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              seller.name ?? 'Featured Seller',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(1.0, 1.0),
                    ),
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}