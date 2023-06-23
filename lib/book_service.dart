import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:watcha_pedia/main.dart';

import 'book.dart';

class BookService extends ChangeNotifier {
  List<Book> bookList = []; // 책 목록
  List<Book> likedBookList = [];

  BookService() {
    loadBookList();
  }

  void toggleLikeBook({required Book book}) {
    String bookId = book.id;
    if (likedBookList.map((book) => book.id).contains(bookId)) {
      likedBookList.removeWhere((book) => book.id == bookId);
    } else {
      likedBookList.add(book);
    }
    notifyListeners();
    saveBookList();
  }

  void search(String q) async {
    bookList.clear(); // 검색 버튼 누를때 이전 데이터들을 지워주기

    if (q.isNotEmpty) {
      Response res = await Dio().get(
        "https://www.googleapis.com/books/v1/volumes?q=$q&startIndex=0&maxResults=40",
      );
      List items = res.data["items"];

      for (Map<String, dynamic> item in items) {
        Book book = Book(
          id: item['id'],
          title: item['volumeInfo']['title'] ?? "",
          subtitle: item['volumeInfo']['subtitle'] ?? "",
          thumbnail: item['volumeInfo']['imageLinks']?['thumbnail'] ??
              "https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132482953.jpg",
          previewLink: item['volumeInfo']['previewLink'] ?? "",
          authors: item['volumeInfo']['authors'] ?? [""],
          publishedDate: item['volumeInfo']['publishedDate'] ?? "",
        );
        bookList.add(book);
      }
    }
    notifyListeners();
  }

  saveBookList() {
    List bookJsonList = likedBookList.map((book) => book.toJson()).toList();
    String jsonString = jsonEncode(bookJsonList);
    sPref.setString('bookList', jsonString);
  }

  loadBookList() {
    String? jsonString = sPref.getString('bookList');
    if (jsonString == null) return;
    List bookJsonList = jsonDecode(jsonString);
    likedBookList = bookJsonList.map((json) => Book.fromJson(json)).toList();
  }
}
