import 'package:tensai/data/models/news_model.dart';

abstract class HeadlineState {}

class HeadlineInitial extends HeadlineState {}

class HeadlineLoading extends HeadlineState {}

class HeadlineLoaded extends HeadlineState {
  final List<Article> articles;
  final bool hasMore;
  final bool isOffline;

  HeadlineLoaded({
    required this.articles,
    required this.hasMore,
    required this.isOffline,
  });
}

class HeadlineError extends HeadlineState {}