import 'package:flutter/material.dart';

Function errorHandler(BuildContext context) {
  return (Object error) {
    if (!ModalRoute.of(context).isCurrent) return;

    Scaffold.of(context).showSnackBar(SnackBar(content: Text(error)));
  };
}
