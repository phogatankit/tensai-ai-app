import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tensai/core/constants/api_endpoints.dart';
import 'package:tensai/core/network/api_client.dart';
import 'package:tensai/data/local/news_database.dart';
import 'package:tensai/data/models/news_model.dart';
import 'headline_event.dart';
import 'headline_state.dart';

class HeadlineBloc extends Bloc<HeadlineEvent, HeadlineState> {
  int page = 1;
  bool hasMore = true;
  List<Article> articles = [];

  HeadlineBloc() : super(HeadlineInitial()) {

    on<FetchHeadlines>((event, emit) async {
      emit(HeadlineLoading());
      try {
        var data = await ApiClient().getApi(url: "${ApiEndpoints.topHeadlinesUrl}?country=us&page=$page&apiKey=${ApiEndpoints.newsApiKey}");
        NewsModel model = NewsModel.fromJson(data);
        articles.addAll(model.articles);
        page++;
        if (model.articles.isEmpty) {hasMore = false;}
        emit(HeadlineLoaded(articles: articles, hasMore: hasMore, isOffline: false));

        if (!kIsWeb) {
          for (var article in model.articles) {
            NewsDBHelper.getInstance().insertNews(
              title: article.title,
              image: article.urlToImage ?? "",
              source: article.source.name,
              date: article.publishedAt,
              url: article.url,
            );
          }
        }
      } catch (e) {
        if (!kIsWeb) {
          var localData = await NewsDBHelper.getInstance().fetchAllNews();
          articles = localData.map((e) {
            return Article(
              title: e[NewsDBHelper.newsTitle] ?? "",
              urlToImage: e[NewsDBHelper.newsImage] ?? "",
              publishedAt: e[NewsDBHelper.newsDate] ?? "",
              source: Source(name: e[NewsDBHelper.newsSource] ?? ""),
              url: e[NewsDBHelper.newsUrl] ?? "",
            );
          }).toList();

          emit(HeadlineLoaded(articles: articles, hasMore: false, isOffline: true));
        } else {
          emit(HeadlineError());
        }
      }
    });

    on<LoadMoreHeadlines>((event, emit) async {
      if (!hasMore) return;
      try {
        var data = await ApiClient().getApi(url: "${ApiEndpoints.topHeadlinesUrl}?country=us&page=$page&apiKey=${ApiEndpoints.newsApiKey}");
        NewsModel model = NewsModel.fromJson(data);

        if (model.articles.isEmpty) {
          hasMore = false;
        } else {
          articles.addAll(model.articles);
          page++;
        }
        emit(HeadlineLoaded(articles: articles, hasMore: hasMore, isOffline: false));
      } catch (e) {
        emit(HeadlineLoaded(articles: articles, hasMore: hasMore, isOffline: false));
      }
    });

    on<RefreshHeadlines>((event, emit) async {
      page = 1;
      hasMore = true;
      articles.clear();
      emit(HeadlineLoading());

      try {
        var data = await ApiClient().getApi(url: "${ApiEndpoints.topHeadlinesUrl}?country=us&page=$page&apiKey=${ApiEndpoints.newsApiKey}");
        NewsModel model = NewsModel.fromJson(data);
        articles.addAll(model.articles);
        page++;

        emit(HeadlineLoaded(articles: articles, hasMore: hasMore, isOffline: false));

        if (!kIsWeb) {
          for (var article in model.articles) {
            NewsDBHelper.getInstance().insertNews(
              title: article.title,
              image: article.urlToImage ?? "",
              source: article.source.name,
              date: article.publishedAt,
              url: article.url,
            );
          }
        }
      } catch (e) {
        emit(HeadlineError());
      }
    });
  }
}