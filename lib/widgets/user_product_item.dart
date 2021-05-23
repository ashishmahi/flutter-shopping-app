import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/product_provider.dart';
import 'package:shopping_app/providers/products_provider.dart';
import 'package:shopping_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final Product product;
  UserProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final scaffoldManager = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,
                    arguments: product.id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  try {
                    await Provider.of<ProductsProvider>(context, listen: false)
                        .deleteItem(product.id);
                  } catch (e) {
                    scaffoldManager.showSnackBar(SnackBar(
                        content: Text("Ops! unable to delete item now")));
                  }
                },
                color: Theme.of(context).errorColor)
          ],
        ),
      ),
    );
  }
}
