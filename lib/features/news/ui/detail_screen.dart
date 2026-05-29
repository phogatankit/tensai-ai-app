import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tensai/data/models/news_model.dart';

class NewsDetailsScreen extends StatelessWidget {
  final Article article;

  const NewsDetailsScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String rawDate = article.publishedAt;
    String formattedDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: article.urlToImage ?? "",
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 42,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(article.title,
                  style: GoogleFonts.robotoSlab(
                    fontWeight: FontWeight.bold,
                    fontSize: 29,
                    color: const Color(0xFFF2F2F2),
                  ),
                ),
                const SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      article.source.name,
                      style: GoogleFonts.robotoSlab(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: const Color(0xFFF2F2F2),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: GoogleFonts.robotoSlab(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: const Color(0xFFF2F2F2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  article.description ?? article.content ?? "No details available.",
                  style: GoogleFonts.robotoSlab(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: const Color(0xFFBABABA),
                    height: 1.5,
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