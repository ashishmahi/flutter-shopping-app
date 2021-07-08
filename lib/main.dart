import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/auth_provider.dart';
import 'package:shopping_app/providers/cart_provider.dart';
import 'package:shopping_app/providers/order_provider.dart';
import 'package:shopping_app/providers/products_provider.dart';
import 'package:shopping_app/screens/auth_screen.dart';
import 'package:shopping_app/screens/cart_screen.dart';
import 'package:shopping_app/screens/edit_product_screen.dart';
import 'package:shopping_app/screens/oder_screen.dart';
import 'package:shopping_app/screens/product_details_screen.dart';
import 'package:shopping_app/screens/product_overview_screen.dart';
import 'package:shopping_app/screens/splash_screen.dart';
import 'package:shopping_app/screens/user_product_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (ctx) => ProductsProvider(null, null, []),
          update: (context, auth, previousProducts) {
            return previousProducts..updateUser(auth.token, auth.userId);
          },
        ),
        ChangeNotifierProvider.value(value: CartProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (ctx) => OrderProvider(null, null, []),
          update: (context, auth, previousOrders) {
            return OrderProvider(
                auth.token, auth.userId, previousOrders.orders);
          },
        )
      ],
      child: Consumer<AuthProvider>(
          builder: (ctx, authData, _) => MaterialApp(
                title: 'Flutter Demo',
                theme: ThemeData(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.deepOrange,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  fontFamily: 'Lato',
                  // textTheme:TextTheme(bodyText1: TextStyle(fontFamily: ))
                ),
                home: authData.isAuthenticate
                    ? ProductOverviewScreen()
                    : FutureBuilder(
                        future: authData.tryAutoLogin(),
                        builder: (ctx, authSnapshot) =>
                            authSnapshot.connectionState ==
                                    ConnectionState.waiting
                                ? SplashScreen()
                                : AuthScreen()),
                routes: {
                  ProductOverviewScreen.routeName: (ctx) =>
                      ProductOverviewScreen(),
                  ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                  CartScreen.routeName: (ctx) => CartScreen(),
                  OrderScreen.routeName: (ctx) => OrderScreen(),
                  UserProductScreen.routeName: (ctx) => UserProductScreen(),
                  EditProductScreen.routeName: (ctx) => EditProductScreen(),
                },
              )),
    );
  }
}
