import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tensai/features/news/bloc/headline_bloc.dart';
import 'package:tensai/features/news/bloc/headline_event.dart';
import 'package:tensai/features/news/bloc/headline_state.dart';
import 'package:tensai/features/news/ui/detail_screen.dart';
import 'package:tensai/features/news/ui/widgets/headline_card.dart';

class HeadlinePage extends StatefulWidget {
  @override
  State<HeadlinePage> createState() => _HeadlinePageState();
}

class _HeadlinePageState extends State<HeadlinePage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HeadlineBloc>().add(FetchHeadlines());
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent ) {
        context.read<HeadlineBloc>().add(LoadMoreHeadlines());
      }
    });
  }

  Future<void> refreshNews() async {
    context.read<HeadlineBloc>().add( FetchHeadlines());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff464646),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "HEADLINES",
          style: GoogleFonts.robotoSlab(
            fontWeight: FontWeight.bold,
            fontSize: 29,
            color: const Color(0xffffffff),
            letterSpacing: 2,
          ),
        ),
      ),
      body: BlocBuilder<HeadlineBloc, HeadlineState>(
        builder: (context, state) {
          if (state is HeadlineLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white,));
          }

          if (state is HeadlineLoaded) {
            if (state.isOffline && state.articles.isEmpty) {
              return RefreshIndicator(
                onRefresh: refreshNews,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.white, size: 60,),
                            const SizedBox(height: 20),
                            const Text("No Internet Connection", style: TextStyle(color: Colors.white, fontSize: 18,)),
                            const SizedBox(height: 10),
                            const Text("Or List is Empty ", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14,)),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                context.read<HeadlineBloc>().add(FetchHeadlines());
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: refreshNews,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: state.articles.length,
                itemBuilder: (context, index) {
                  final article = state.articles[index];
                  String rawDate = article.publishedAt;
                  String formattedDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;

                  return HeadlineCard(
                    imageUrl: article.urlToImage ?? "",
                    title: article.title,
                    source: article.source.name,
                    date: formattedDate,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailsScreen(article: article),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          if (state is HeadlineError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Something went wrong", style: TextStyle(color: Colors.white),),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: () {
                    context.read<HeadlineBloc>().add( FetchHeadlines());
                  },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}