import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movies/src/models/actors_models.dart';

import 'package:movies/src/models/movie_models.dart';

class MovieProvider {
  String _apikey = 'd250be5a1a30616e7cbb7b4adee6183c';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _popularPage = 0;

  bool _loadingPage = false;

  List<Movie> _popular = new List();

  final _popularStreamController = StreamController<List<Movie>>.broadcast();

  Function(List<Movie>) get popularSink => _popularStreamController.sink.add;
  Stream<List<Movie>> get popularStream => _popularStreamController.stream;

  void diposeStreams() {
    _popularStreamController?.close();
  }

  Future<List<Movie>> _loadingRequest(Uri url) async {
    final res = await http.get(url);

    final decodedData = json.decode(res.body);

    final movies = new Movies.fromJsonList(decodedData['results']);

    return movies.items;
  }

  Future<List<Movie>> getMoviesNowPlayer() async {
    final url = Uri.https(_url, '3/movie/now_playing',
        {'api_key': _apikey, 'language': _language});

    return await _loadingRequest(url);
  }

  Future<List<Movie>> getPopularMovies() async {
    if (_loadingPage) return [];
    _loadingPage = true;
    _popularPage++;

    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apikey,
      'language': _language,
      'page': _popularPage.toString()
    });
    final resp = await _loadingRequest(url);

    _popular.addAll(resp);
    popularSink(_popular);
    _loadingPage = false;
    return resp;
  }

  Future<List<Actor>> getCast(String moviId) async {
    final url = Uri.https(_url, '3/movie/$moviId/credits', {
      'api_key': _apikey,
      'language': _language,
    });

    final resp = await http.get(url);

    final decodedData = json.decode(resp.body);
    final cast = new Cast.fromJsonList(decodedData['cast']);

    return cast.actors;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_url, '3/search/movie', {
      'api_key': _apikey,
      'language': _language,
      'query': query,
    });

    return await _loadingRequest(url);
  }
}
