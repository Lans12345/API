import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:sample_app/repositories/product_repository.dart';
import 'package:sample_app/services/api_call_handling.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/products_model.dart';

import '../../widgets/button_widget.dart';
import '../../widgets/dialog_widget.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/textformfield_widget.dart';

class ViewProductList extends StatefulWidget {
  const ViewProductList({super.key});

  @override
  State<ViewProductList> createState() => _ViewProductListState();
}

class _ViewProductListState extends State<ViewProductList> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  final _addNameController = TextEditingController();
  final _addDescriptionController = TextEditingController();
  final _addPriceController = TextEditingController();
  final _addImageUrlController = TextEditingController();

  bool hasLoaded = true;

  List<ProductModel?> products = [];

  @override
  void dispose() {
    _addDescriptionController.dispose();
    _addImageUrlController.dispose();
    _addNameController.dispose();
    _addPriceController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    ProductRepository().getMultipleProducts('/products');
    getJsonData();
  }

  bool isNotHidden = true;

  late List<dynamic> jsonData = [];

  late int pageLength = 0;
  late int page = 0;

  getJsonData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jsonData = prefs.getStringList('jsonData')!;
      pageLength = prefs.getInt('pageLength')!;
      page = prefs.getInt('page')!;
      hasLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            child: Center(
                child: hasLoaded
                    ? ListView(
                        children: [
                          for (int i = 0; i < jsonData.length; i++)
                            GestureDetector(
                              onTap: () async {
                                ProductRepository()
                                    .getSingleProduct(jsonData[i]['id']);

                                await Future.delayed(
                                    const Duration(seconds: 3));

                                GoRouter.of(context).replace('/product');
                              },
                              child: Slidable(
                                closeOnScroll: true,
                                startActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  children: [
                                    SlidableAction(
                                      autoClose: true,
                                      onPressed: (context) {
                                        showDialog(
                                            context: context,
                                            builder: ((context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.grey,
                                                title: const Text(
                                                    'Enter Product Description'),
                                                content: Column(
                                                  children: [
                                                    TextFormFieldWidget(
                                                        isEmail: false,
                                                        isPassword: false,
                                                        inputController:
                                                            _nameController,
                                                        label: jsonData[i]
                                                            ['name']),
                                                    TextFormFieldWidget(
                                                        isEmail: false,
                                                        isPassword: false,
                                                        inputController:
                                                            _priceController,
                                                        label: jsonData[i]
                                                            ['price']),
                                                  ],
                                                ),
                                                actions: [
                                                  ButtonWidget(
                                                      onPressed: () async {
                                                        try {
                                                          ProductRepository()
                                                              .putProduct(
                                                                  jsonData[i]
                                                                      ['id'],
                                                                  _nameController
                                                                      .text,
                                                                  _priceController
                                                                      .text,
                                                                  jsonData[i][
                                                                      'image_link']);

                                                          await Future.delayed(
                                                              const Duration(
                                                                  seconds: 5));
                                                          GoRouter.of(context)
                                                              .go('/home');
                                                        } catch (e) {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  ((context) {
                                                                return DialogWidget(
                                                                    content: e
                                                                        .toString());
                                                              }));
                                                        }
                                                      },
                                                      text: 'Add Product'),
                                                ],
                                              );
                                            }));
                                      },
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Update',
                                    )
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) async {
                                        ProductRepository()
                                            .deleteProduct(jsonData[i]['id']);

                                        await Future.delayed(
                                            const Duration(seconds: 5));
                                        GoRouter.of(context).replace('/home');
                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 10, 30, 10),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 10, 10, 0),
                                        child: Banner(
                                          color: Colors.blue,
                                          message: 'HOT SALE',
                                          location: BannerLocation.topEnd,
                                          child: Container(
                                            height: 300,
                                            width: 400,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [
                                                Colors.pink[300]!,
                                                Colors.pink[200]!,
                                                Colors.pink[200]!,
                                                Colors.pink[300]!,
                                              ]),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 10, 0),
                                              child: jsonData[i]['image_link']
                                                      .toString()
                                                      .contains('http')
                                                  ? Image.network(
                                                      jsonData[i]['image_link'])
                                                  : TextWidget(
                                                      text: 'Image Cannot Load',
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 60,
                                        width: 315,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 0, 10),
                                            child: ListTile(
                                              title: TextWidget(
                                                  text: jsonData[i]['name'],
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                              trailing: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  gradient:
                                                      LinearGradient(colors: [
                                                    Colors.pink[500]!,
                                                    Colors.pink[300]!,
                                                    Colors.pink[500]!,
                                                  ]),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 2,
                                                          bottom: 2),
                                                  child: TextWidget(
                                                      text: jsonData[i]
                                                          ['price'],
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: ListTile(
                                leading: TextButton(
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (page <= 1) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Cannot Procceed. This page is the first page'),
                                        ),
                                      );
                                    } else {
                                      ProductRepository()
                                          .getMultipleProducts('/products');

                                      await Future.delayed(
                                          const Duration(seconds: 5));

                                      int newPage = 0;

                                      newPage = page - 1;

                                      prefs.setInt('page', newPage);

                                      GoRouter.of(context).replace('/home');
                                    }
                                  },
                                  child: TextWidget(
                                      text: 'Go back',
                                      color: Colors.pink[200]!,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: TextButton(
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (page >= pageLength) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Cannot Procceed. This page is the last page'),
                                        ),
                                      );
                                    } else {
                                      ProductRepository()
                                          .getMultipleProducts('/products');

                                      await Future.delayed(
                                          const Duration(seconds: 5));

                                      int newPage = 0;

                                      newPage = page + 1;

                                      prefs.setInt('page', newPage);

                                      GoRouter.of(context).replace('/home');
                                    }
                                  },
                                  child: TextWidget(
                                      text: 'View more',
                                      color: Colors.pink[200]!,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator()),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            minWidth: 250,
            color: Colors.pink[200],
            onPressed: () {
              showDialog(
                  context: context,
                  builder: ((context) {
                    return AlertDialog(
                      backgroundColor: Colors.grey[200],
                      title: const Text('Enter Product Description'),
                      content: Column(
                        children: [
                          TextFormFieldWidget(
                              isEmail: false,
                              isPassword: false,
                              inputController: _addNameController,
                              label: 'Product Name'),
                          TextFormFieldWidget(
                              isEmail: false,
                              isPassword: false,
                              inputController: _addDescriptionController,
                              label: 'Product Description'),
                          TextFormFieldWidget(
                              isEmail: false,
                              isPassword: false,
                              inputController: _addPriceController,
                              label: 'Product Price'),
                          TextFormFieldWidget(
                              isEmail: false,
                              isPassword: false,
                              inputController: _addImageUrlController,
                              label: 'Product Image URL'),
                        ],
                      ),
                      actions: [
                        Visibility(
                          visible: isNotHidden,
                          child: ButtonWidget(
                              onPressed: () async {
                                ProductRepository().addProduct(
                                    _addNameController.text,
                                    _addImageUrlController.text,
                                    _addDescriptionController.text,
                                    int.parse(_addPriceController.text),
                                    true);
                                setState(() {
                                  isNotHidden = false;
                                });
                                ApiCallHandling().putDelay(isNotHidden);
                                GoRouter.of(context).replace('/home');
                              },
                              text: 'Add Product'),
                        )
                      ],
                    );
                  }));
            },
            child: TextWidget(
                text: 'Add Product',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
