import 'package:flutter/material.dart';
import 'package:movies/src/models/movie_models.dart';
import 'package:movies/src/provider/movies_provider.dart';

class DataSearch extends SearchDelegate {
  String selected = '';
  final movieProvider = new MovieProvider();

  @override
  List<Widget> buildActions(BuildContext context) {
    //Acciones del AppBar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Icono al inicio del AppBar

    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Crea los resultado que vamos a mostrar
    return Center(
      child: Container(
        height: 100.0,
        width: 100.0,
        color: Colors.blueAccent,
        child: Text(selected),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Sugerencias de Busqueda
    if (query.isEmpty) {
      return Container();
    }
    return FutureBuilder(
      future: movieProvider.searchMovie(query),
      builder: (BuildContext context, AsyncSnapshot<List<Movie>> snapshot) {
        if (snapshot.hasData) {
          final movie = snapshot.data;

          return ListView(
            children: movie
                .map((p) => ListTile(
                      leading: FadeInImage(
                          image: NetworkImage(p.getPosterImg()),
                          placeholder: AssetImage('assets/img/no-image.jpg'),
                          fit: BoxFit.contain),
                      title: Text(p.title),
                      subtitle: Text(p.originalTitle),
                      onTap: () {
                        close(context, null);
                        p.uniqueId = '';
                        Navigator.pushNamed(context, 'detail', arguments: p);
                      },
                    ))
                .toList(),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
