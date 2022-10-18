import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:sample_app/repositories/product_repository.dart';
import 'package:sample_app/services/api_call_handling.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
            child: Column(
              children: [
                hasLoaded
                    ? Expanded(
                        child: SizedBox(
                          child: FutureBuilder<List<Product>>(
                              future: ProductRepository()
                                  .getMultipleProducts('/products'),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: TextWidget(
                                        text: 'Something went wrong',
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else if (snapshot.data == null) {
                                  return Center(
                                    child: SpinKitCubeGrid(
                                      color: Colors.pink[400],
                                    ),
                                  );
                                } else {
                                  List<Product> products = snapshot.data!;
                                  return AnimationLimiter(
                                    child: ListView.builder(
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        Product product = products[index];
                                        return AnimationConfiguration
                                            .staggeredList(
                                          position: index,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: GestureDetector(
                                                onTap: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  ProductRepository()
                                                      .getSingleProduct(
                                                          product.id);

                                                  await Future.delayed(
                                                      const Duration(
                                                          seconds: 1));
                                                  prefs.setString(
                                                      'product_image_link',
                                                      product.imageLink!);
                                                  prefs.setString(
                                                      'product_name',
                                                      product.name);
                                                  prefs.setString(
                                                      'product_price',
                                                      product.price);

                                                  GoRouter.of(context)
                                                      .push('/product');
                                                },
                                                child: Slidable(
                                                  closeOnScroll: true,
                                                  startActionPane: ActionPane(
                                                    motion:
                                                        const BehindMotion(),
                                                    children: [
                                                      SlidableAction(
                                                        autoClose: true,
                                                        onPressed: (context) {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  ((context) {
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          200],
                                                                  title: TextWidget(
                                                                      text:
                                                                          'Enter Product Description',
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                  content:
                                                                      Column(
                                                                    children: [
                                                                      TextFormFieldWidget(
                                                                          isEmail:
                                                                              false,
                                                                          isPassword:
                                                                              false,
                                                                          inputController:
                                                                              _nameController,
                                                                          label:
                                                                              product.name),
                                                                      TextFormFieldWidget(
                                                                          isEmail:
                                                                              false,
                                                                          isPassword:
                                                                              false,
                                                                          inputController:
                                                                              _priceController,
                                                                          label:
                                                                              product.price),
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    ButtonWidget(
                                                                        onPressed:
                                                                            () async {
                                                                          try {
                                                                            ProductRepository().putProduct(
                                                                                product.id,
                                                                                _nameController.text,
                                                                                _priceController.text,
                                                                                product.imageLink!);
                                                                          } catch (e) {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: ((context) {
                                                                                  return DialogWidget(content: e.toString());
                                                                                }));
                                                                          }
                                                                          GoRouter.of(context)
                                                                              .go('/home');
                                                                        },
                                                                        text:
                                                                            'Add Cake'),
                                                                  ],
                                                                );
                                                              }));
                                                        },
                                                        backgroundColor:
                                                            Colors.blue,
                                                        foregroundColor:
                                                            Colors.white,
                                                        icon: Icons.delete,
                                                        label: 'Update',
                                                      )
                                                    ],
                                                  ),
                                                  endActionPane: ActionPane(
                                                    motion:
                                                        const ScrollMotion(),
                                                    children: [
                                                      SlidableAction(
                                                        onPressed:
                                                            (context) async {
                                                          ProductRepository()
                                                              .deleteProduct(
                                                                  product.id);

                                                          await Future.delayed(
                                                              const Duration(
                                                                  seconds: 5));
                                                          GoRouter.of(context)
                                                              .replace('/home');
                                                        },
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        icon: Icons.delete,
                                                        label: 'Delete',
                                                      )
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        30, 10, 30, 10),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  10,
                                                                  10,
                                                                  10,
                                                                  0),
                                                          child: Banner(
                                                            color: Colors.blue,
                                                            message: 'HOT SALE',
                                                            location:
                                                                BannerLocation
                                                                    .topEnd,
                                                            child: Container(
                                                              height: 300,
                                                              width: 400,
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                      Colors.pink[
                                                                          300]!,
                                                                      Colors.pink[
                                                                          200]!,
                                                                      Colors.pink[
                                                                          200]!,
                                                                      Colors.pink[
                                                                          300]!,
                                                                    ]),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        10,
                                                                        10,
                                                                        10,
                                                                        0),
                                                                child: Uri.parse(product
                                                                            .imageLink!)
                                                                        .isAbsolute
                                                                    ? Image.network(
                                                                        product
                                                                            .imageLink!)
                                                                    : Center(
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            const SpinKitSpinningLines(
                                                                              color: Colors.white,
                                                                              size: 50,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 20,
                                                                            ),
                                                                            TextWidget(
                                                                                text: 'Error Loading Image',
                                                                                color: Colors.white,
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.bold),
                                                                          ],
                                                                        ),
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 60,
                                                          width: 315,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      10,
                                                                      10,
                                                                      0,
                                                                      10),
                                                              child: ListTile(
                                                                title: TextWidget(
                                                                    text: product
                                                                        .name,
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                trailing:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    gradient:
                                                                        LinearGradient(
                                                                            colors: [
                                                                          Colors
                                                                              .pink[500]!,
                                                                          Colors
                                                                              .pink[300]!,
                                                                          Colors
                                                                              .pink[500]!,
                                                                        ]),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        top: 2,
                                                                        bottom:
                                                                            2),
                                                                    child: TextWidget(
                                                                        text: product
                                                                            .price,
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            22,
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
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }
                              }),
                        ),
                      )
                    : SpinKitWave(),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: ListTile(
                      leading: TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          print(prefs.getInt('page')!);
                          print(prefs.getInt('pageLength')!);
                          if (prefs.getInt('page')! <= 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Cannot Procceed. This page is the first page'),
                              ),
                            );
                          } else {
                            ProductRepository()
                                .getMultipleProducts('/products');
                            await Future.delayed(const Duration(seconds: 1));

                            setState(() {
                              int newPage = 0;

                              newPage = prefs.getInt('page')! - 1;

                              prefs.setInt('page', newPage);
                            });

                            GoRouter.of(context).replace('/home');
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.pink[200]!,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontFamily: 'QRegular',
                                  color: Colors.pink[400]!,
                                ),
                                child: AnimatedTextKit(
                                  repeatForever: true,
                                  animatedTexts: [
                                    WavyAnimatedText('Go'),
                                    WavyAnimatedText('Back'),
                                  ],
                                  isRepeatingAnimation: true,
                                  onTap: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    print(prefs.getInt('page')!);
                                    print(prefs.getInt('pageLength')!);
                                    if (prefs.getInt('page')! <= 1) {
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
                                          const Duration(seconds: 1));

                                      setState(() {
                                        int newPage = 0;

                                        newPage = prefs.getInt('page')! - 1;

                                        prefs.setInt('page', newPage);
                                      });

                                      GoRouter.of(context).replace('/home');
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          print(prefs.getInt('page')!);
                          print(prefs.getInt('pageLength')!);
                          if (prefs.getInt('page')! >=
                              prefs.getInt('pageLength')!) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Cannot Procceed. This page is the last page'),
                              ),
                            );
                          } else if (prefs.getInt('page')! <=
                              prefs.getInt('pageLength')!) {
                            ProductRepository()
                                .getMultipleProducts('/products');
                            await Future.delayed(const Duration(seconds: 1));

                            setState(() {
                              int newPage = 0;

                              newPage = prefs.getInt('page')! + 1;
                              prefs.setInt('page', newPage);
                            });

                            GoRouter.of(context).replace('/home');
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.pink[200]!,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
                            child: DefaultTextStyle(
                              style: TextStyle(
                                fontSize: 12.0,
                                fontFamily: 'QRegular',
                                color: Colors.pink[400]!,
                              ),
                              child: AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  WavyAnimatedText('View'),
                                  WavyAnimatedText('More'),
                                ],
                                isRepeatingAnimation: true,
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  print(prefs.getInt('page')!);
                                  print(prefs.getInt('pageLength')!);
                                  if (prefs.getInt('page')! >=
                                      prefs.getInt('pageLength')!) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Cannot Procceed. This page is the last page'),
                                      ),
                                    );
                                  } else if (prefs.getInt('page')! <=
                                      prefs.getInt('pageLength')!) {
                                    ProductRepository()
                                        .getMultipleProducts('/products');
                                    await Future.delayed(
                                        const Duration(seconds: 1));

                                    setState(() {
                                      int newPage = 0;

                                      newPage = prefs.getInt('page')! + 1;
                                      prefs.setInt('page', newPage);
                                    });

                                    GoRouter.of(context).replace('/home');
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minWidth: 250,
              color: Colors.pink[200],
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                print(prefs.getString('token'));
                print(prefs.getInt('page'));
                print(prefs.getInt('pageLength'));
                ProductRepository().getMultipleProducts('/products');
                showDialog(
                    context: context,
                    builder: ((context) {
                      return AlertDialog(
                        backgroundColor: Colors.grey[200],
                        title: TextWidget(
                            text: 'Enter Product Description',
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.normal),
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
                                text: 'Add Cake'),
                          )
                        ],
                      );
                    }));
              },
              child: SizedBox(
                width: 250.0,
                child: Center(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'QBold',
                      fontWeight: FontWeight.bold,
                    ),
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        TypewriterAnimatedText('Add Cake'),
                      ],
                      onTap: () {
                        print("Tap Event");
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
