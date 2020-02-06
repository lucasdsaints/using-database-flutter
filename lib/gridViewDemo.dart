import 'package:dbstorage_example/gridCell.dart';
import 'package:flutter/material.dart';

import 'dbHelper.dart';
import 'models/index.dart';
import 'services.dart';

class GridViewDemo extends StatefulWidget {
  final String title = 'Photos';

  @override
  _GridViewDemoState createState() => _GridViewDemoState();
}

class _GridViewDemoState extends State<GridViewDemo> {
  int counter;
  static Albums albums;
  DBHelper dbHelper;
  bool albumsLoaded;
  String title;
  double percent;
  GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    super.initState();
    counter = 0;
    title = widget.title;
    scaffoldKey = GlobalKey();
    dbHelper = DBHelper();
  }

  getPhotos() {
    setState(() {
      counter = 0;
      albumsLoaded = false;
    });
    Services.getPhotos().then((allAlbums) {
      albums = allAlbums;

      dbHelper.truncateTable().then((val) {
        if (albums.albums.length > 0) {
          insert(albums.albums[0]);
        }
      });
    });
  }

  insert(Album album) {
    dbHelper.save(album).then((val) {
      counter += 1;
      percent = ((counter / albums.albums.length) * 100) / 100;
      if (counter >= albums.albums.length) {
        setState(() {
          albumsLoaded = true;
          percent = 0.0;
          title = '${widget.title} [$counter]';
        });
        return;
      }
      setState(() {
        title = 'Inserting...$counter';
      });
      Album a = albums.albums[counter];
      insert(a);
    });
  }

  gridview(AsyncSnapshot<Albums> snapshot) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: snapshot.data.albums.map((album) {
          return GridTile(
            child: AlbumCell(album, update, delete),
          );
        }).toList(),
      ),
    );
  }

  // Update function
  update(Album album) {
    dbHelper.update(album).then((updtVal) {
      // showSnackBar('Updated ${album.id}');
      refresh();
    });
  }

  // Delete
  delete(int id) {
    dbHelper.delete(id).then((delVal) {
      // showSnackBar('Deleted $id');
      refresh();
    });
  }

  // Method to refresh the List after the DB operations
  refresh() {
    dbHelper.getAlbums().then((allAlbums) {
      setState(() {
        albums = allAlbums;
        counter = albums.albums.length;
        title = '${widget.title} [$counter]';
      });
    });
  }

  // showSnackBar(String message) {
  //   scaffoldKey.currentState.showSnackBar(SnackBar(
  //     content: Text(message),
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {
              getPhotos();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: FutureBuilder<Albums>(
              future: dbHelper.getAlbums(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  return gridview(snapshot);
                }
                return CircularProgressIndicator();
              },
            ),
          )
        ],
      ),
    );
  }
}
