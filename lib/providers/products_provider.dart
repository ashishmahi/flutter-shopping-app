import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/providers/network_exception.dart';
import 'package:shopping_app/providers/product_provider.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  String authToken;
  String userId;

  ProductsProvider(
    this.authToken,
    this.userId,
    this._items,
  );
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> getProducts([bool filterByValue = false]) async {
    final filterString =
        filterByValue ? '&orderBy="creatorId"&equalTo="$userId"' : "";
    try {
      final url =
          'https://shopping-app-web-server-default-rtdb.firebaseio.com/product.json?auth=$authToken$filterString';

      final reponse = await http.get(Uri.parse(url));
      final decodedData = json.decode(reponse.body) as Map<String, dynamic>;
      final List<Product> itemsLoaded = [];
      decodedData.forEach((productId, value) {
        itemsLoaded.add(Product(
            id: productId,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl']));
      });
      _items = itemsLoaded;
      notifyListeners();
    } catch (e) {
      print("erererer");
      print(e);
      throw e;
    }
  }

  Future<void> addProduct(Product product) {
    final url =
        "https://shopping-app-web-server-default-rtdb.firebaseio.com/product.json?auth=$authToken";
    return http
        .post(Uri.parse(url),
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
              'isFavorite': product.isFavorite,
              'creatorId': userId
            }))
        .then((response) {
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    });
  }

  Product findById(String productId) {
    return items.firstWhere((element) => element.id == productId);
  }

  Future<void> editProduct(Product editedProduct, String id) async {
    final indexOf =
        _items.indexWhere((element) => element.id == editedProduct.id);
    final url =
        "https://shopping-app-web-server-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken";
    final res = await http.patch(Uri.parse(url),
        body: json.encode({
          'title': editedProduct.title,
          'description': editedProduct.description,
          'imageUrl': editedProduct.imageUrl,
          'price': editedProduct.price,
          'isFavorite': editedProduct.isFavorite,
        }));
    _items[indexOf] = editedProduct;
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final url =
        "https://shopping-app-web-server-default-rtdb.firebaseio.com/product/$id.json?auth=$authToken";
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw NetworkException("Delete failed!");
    }
    existingProduct = null;
  }

  void updateUser(String token, String id) {
    this.userId = id;
    this.authToken = token;
    notifyListeners();
  }
}
