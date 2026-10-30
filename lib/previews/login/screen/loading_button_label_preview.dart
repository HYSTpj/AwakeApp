import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../presentation/views/login/screen/loading_button_label.dart';

@Preview(name: 'LoadingButtonLabel - label')
Widget loadingButtonLabelPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.deepOrange,
      body: const Center(
        child: LoadingButtonLabel(isLoading: false, label: 'CREATE ACCOUNT'),
      ),
    ),
  );
}

@Preview(name: 'LoadingButtonLabel - loading')
Widget loadingButtonLabelLoadingPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.deepOrange,
      body: const Center(
        child: LoadingButtonLabel(isLoading: true, label: 'CREATE ACCOUNT'),
      ),
    ),
  );
}
