import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/product_provider.dart';
import 'package:shopping_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _urlRegexMatcher = new RegExp(
      r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?",
      caseSensitive: false);
  Product _editedProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLController.dispose();
    _imageURLFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }

  @override
  void initState() {
    _imageURLFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  var _isInit = true;
  var _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageURLController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (_imageURLFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() async {
    final isValid = _form.currentState.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _form.currentState.save();
      final provider = Provider.of<ProductsProvider>(context, listen: false);
      if (_editedProduct.id != null) {
        await provider.editProduct(_editedProduct, _editedProduct.id);
        // setState(() {
        //   _isLoading = false;
        // });
        Navigator.of(context).pop();
      } else {
        provider.addProduct(_editedProduct).catchError((error) {
          return showDialog<Null>(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('Opps error'),
                    content: Text(error.toString()),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text('Close'))
                    ],
                  ));
        }).then((_) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: ListView(
                padding: EdgeInsets.all(10),
                children: [
                  TextFormField(
                    initialValue: _initValues['title'],
                    validator: (value) {
                      return value.isEmpty ? "Please provide a title" : null;
                    },
                    onSaved: (newValue) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: newValue,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl);
                    },
                    decoration: InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: InputDecoration(labelText: 'Price'),
                    validator: (value) {
                      if (value.isEmpty) return "Please provide a price";
                      if (double.tryParse(value) == null)
                        return "Please enter a valid number";
                      if (double.parse(value) <= 0)
                        return "Please enter a value greater than 0";

                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    onSaved: (newValue) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(newValue),
                          imageUrl: _editedProduct.imageUrl);
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    focusNode: _priceFocusNode,
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    initialValue: _initValues['description'],
                    validator: (value) {
                      return value.isEmpty
                          ? "Please provide a description"
                          : null;
                    },
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onSaved: (newValue) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: newValue,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl);
                    },
                    focusNode: _descriptionFocusNode,
                    keyboardType: TextInputType.multiline,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageURLController.text.isEmpty
                              ? Text('Enter a url')
                              : FittedBox(
                                  child: Image.network(
                                    _imageURLController.text,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please provide an Image url";
                            }
                            if (_urlRegexMatcher.firstMatch(value) == null) {
                              return "Please enter a valid url";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: newValue);
                          },
                          textInputAction: TextInputAction.done,
                          controller: _imageURLController,
                          focusNode: _imageURLFocusNode,
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
