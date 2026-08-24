import 'dart:convert';

import '../domain/models/project.dart';
import '../domain/models/project_node.dart';
import '../domain/models/rebar_item.dart';

class ListoferyarFileFormat {
  ListoferyarFileFormat._();

  static const int currentVersion = 1;

  static Map<String, dynamic> encode({
    required ListoferyarProject project,
    required List<ListoferyarProjectNode> nodes,
    required List<ListoferyarRebarItem> rebarItems,
  }) {
    return <String, dynamic>{
      'format': 'listoferyar-project',
      'version': currentVersion,
      'project': project.toMap(),
      'nodes': nodes.map((node) => node.toMap()).toList(growable: false),
      'rebar_items':
          rebarItems.map((item) => item.toMap()).toList(growable: false),
    };
  }

  static String encodeJson({
    required ListoferyarProject project,
    required List<ListoferyarProjectNode> nodes,
    required List<ListoferyarRebarItem> rebarItems,
  }) {
    return const JsonEncoder.withIndent('  ').convert(
      encode(
        project: project,
        nodes: nodes,
        rebarItems: rebarItems,
      ),
    );
  }

  static ListoferyarFileBundle decodeJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('قالب فایل لیستوفر معتبر نیست.');
    }

    return decode(Map<String, dynamic>.from(decoded));
  }

  static ListoferyarFileBundle decode(Map<String, dynamic> data) {
    if (data['format'] != 'listoferyar-project') {
      throw const FormatException('نوع فایل لیستوفر پشتیبانی نمی‌شود.');
    }

    final version = data['version'];
    if (version is! num || version.toInt() > currentVersion) {
      throw const FormatException('نسخه فایل لیستوفر با این برنامه سازگار نیست.');
    }

    final projectMap = _map(data['project']);
    final nodeMaps = _listOfMaps(data['nodes']);
    final rebarMaps = _listOfMaps(data['rebar_items']);

    return ListoferyarFileBundle(
      project: ListoferyarProject.fromMap(projectMap),
      nodes: nodeMaps
          .map(ListoferyarProjectNode.fromMap)
          .toList(growable: false),
      rebarItems: rebarMaps
          .map(ListoferyarRebarItem.fromMap)
          .toList(growable: false),
    );
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is! Map) {
      throw const FormatException('اطلاعات پروژه در فایل ناقص است.');
    }

    return Map<String, Object?>.from(value);
  }

  static List<Map<String, Object?>> _listOfMaps(Object? value) {
    if (value == null) return const <Map<String, Object?>>[];
    if (value is! List) {
      throw const FormatException('ساختار داده‌های فایل ناقص است.');
    }

    return value.map(_map).toList(growable: false);
  }
}

class ListoferyarFileBundle {
  const ListoferyarFileBundle({
    required this.project,
    required this.nodes,
    required this.rebarItems,
  });

  final ListoferyarProject project;
  final List<ListoferyarProjectNode> nodes;
  final List<ListoferyarRebarItem> rebarItems;
}
