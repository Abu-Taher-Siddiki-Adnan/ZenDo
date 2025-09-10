import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'tag_model.g.dart'; 

@HiveType(typeId: 2)  
class TagModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int colorValue;
  
  TagModel({
    required this.name,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}