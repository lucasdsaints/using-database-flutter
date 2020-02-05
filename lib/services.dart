import 'dart:convert';
import 'package:http/http.dart' as http;
import './models/album.dart';
import './models/albums.dart';

class Services {
  static List<Album> albums;
  static const String url = 'https://jsonplaceholder.typicode.com/photos';

  static Future<Albums> getPhotos() async {
    try {
      final response = await http.get(url);
      if (200 == response.statusCode) {
        Albums albums = parsePhotos(response.body);
        return albums;
      } else {
        Albums albums = Albums();
        albums.albums = [];
        return albums;
      }
    } catch (e) {
      Albums albums = Albums();
      albums.albums = [];
      return albums;
    }
  }
}
