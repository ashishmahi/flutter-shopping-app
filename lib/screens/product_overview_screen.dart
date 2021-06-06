import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/cart_provider.dart';
import 'package:shopping_app/providers/products_provider.dart';
import 'package:shopping_app/screens/cart_screen.dart';
import 'package:shopping_app/widgets/app_drawer.dart';
import 'package:shopping_app/widgets/badge.dart';
import 'package:shopping_app/widgets/product_view_grid.dart';

enum FavoriteOptions { All, FavoriteItems }

class ProductOverviewScreen extends StatefulWidget {
  static const routeName = '/productOverview';
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isInit = true;
  Future _itemsFuture;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _itemsFuture = Provider.of<ProductsProvider>(
        context,
      ).getProducts();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  bool _showFavorites = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My shop'),
        actions: [
          PopupMenuButton(
              onSelected: (FavoriteOptions value) {
                setState(() {
                  if (value == FavoriteOptions.FavoriteItems) {
                    _showFavorites = true;
                  } else {
                    _showFavorites = false;
                  }
                });
              },
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Only favortes'),
                      value: FavoriteOptions.FavoriteItems,
                    ),
                    PopupMenuItem(
                      child: Text('Show all'),
                      value: FavoriteOptions.All,
                    )
                  ]),
          Consumer<CartProvider>(
            builder: (_, value, ch) =>
                Badge(child: ch, value: value.itemCount.toString()),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if ((snapshot.connectionState == ConnectionState.waiting)) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Failed to fetch products'),
              );
            }
            return ProductGridView(showFavorites: _showFavorites);
          }),
    );
  }
}
