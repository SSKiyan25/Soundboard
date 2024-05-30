import 'package:flutter/material.dart';
import 'package:musicplayerv2/consts/colors.dart';

const bold = "bold";
const regular = "regular";

ourStyle({family = "regular", double? size = 14.0, color = whiteColor}) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontFamily: family,
  );
}
