import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ZenDo/models/tag_model.dart';

class TagProvider with ChangeNotifier {
  List<TagModel> _tags = [];
  final String _boxName = 'tags';

  List<TagModel> get tags => List.unmodifiable(_tags);

  TagProvider() {
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final box = await Hive.openBox<TagModel>(_boxName);
      _tags = box.values.toList();
      notifyListeners();
    } catch (e) {
      print('Error loading tags: $e');
    }
  }

  Future<void> addTag(TagModel tag) async {
    try {
      final box = Hive.box<TagModel>(_boxName);
      await box.add(tag);
      _tags.add(tag);
      notifyListeners();
    } catch (e) {
      print('Error adding tag: $e');
      rethrow;
    }
  }

  Future<void> deleteTag(String tagName) async {
    try {
      final box = Hive.box<TagModel>(_boxName);
      final index = _tags.indexWhere((tag) => tag.name == tagName);
      if (index != -1) {
        await box.deleteAt(index);
        _tags.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting tag: $e');
      rethrow;
    }
  }

  Future<void> updateTag(String oldName, TagModel updatedTag) async {
    try {
      final box = Hive.box<TagModel>(_boxName);
      final index = _tags.indexWhere((tag) => tag.name == oldName);
      if (index != -1) {
        await box.putAt(index, updatedTag);
        _tags[index] = updatedTag;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating tag: $e');
      rethrow;
    }
  }

  Future<void> clearTags() async {
    try {
      final box = Hive.box<TagModel>(_boxName);
      await box.clear();
      _tags.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing tags: $e');
      rethrow;
    }
  }

  TagModel? getTagByName(String name) {
    try {
      return _tags.firstWhere((tag) => tag.name == name);
    } catch (e) {
      return null;
    }
  }
}
