import 'package:cnpm_ptpm/constants/backgroundColor.dart';
import 'package:cnpm_ptpm/models/sellers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SellersScreen extends StatelessWidget {
  static const routeName = '/seller_screen';

  const SellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Seller> sellers =
    ModalRoute.of(context)!.settings.arguments as List<Seller>;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 50.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CNPM-PTPM',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 24.0,
                      color: const Color(0xFF4E8489),
                    ),
                  ),
                  Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: sellers.length,
                itemBuilder: (context, index) {
                  final seller = sellers[index];
                  final Color sellerColor =
                  backgroundColor[index % backgroundColor.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10,
                      ),
                      height: 130.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: sellerColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(seller.name!),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                                  child: Text('from: ${seller.address!}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                                  child: const Text('No rating'),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.network(
                              'http://10.0.2.2/CNPM_PTPM/assets/${seller.image!}',
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}