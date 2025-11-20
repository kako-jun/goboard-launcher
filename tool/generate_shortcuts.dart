import 'dart:io';

import 'package:yaml/yaml.dart';

const int _gridSize = 9;
const String _generatedPath = 'lib/generated/shortcuts.g.dart';

class ShortcutConfig {
  ShortcutConfig({required this.tengenLabel, required this.categories});

  final String tengenLabel;
  final List<String> categories;

  factory ShortcutConfig.fromYaml(String yamlContent) {
    final data = loadYaml(yamlContent) as YamlMap;
    final tengenLabel = data['tengen_label']?.toString() ?? '天元アプリ';
    final categoriesRaw = data['categories'];
    final categories = categoriesRaw is YamlList
        ? categoriesRaw.map((e) => e.toString()).toList(growable: false)
        : <String>[];
    if (categories.isEmpty) {
      throw const FormatException('categories が 1 件以上必要です');
    }
    return ShortcutConfig(tengenLabel: tengenLabel, categories: categories);
  }
}

class ShortcutSeed {
  const ShortcutSeed({
    required this.coordinate,
    required this.label,
    required this.category,
  });

  final String coordinate;
  final String label;
  final String category;
}

void main(List<String> args) {
  final configFile = File('tool/shortcuts.yaml');
  if (!configFile.existsSync()) {
    stderr.writeln('tool/shortcuts.yaml が見つかりません');
    exit(1);
  }

  final config = ShortcutConfig.fromYaml(configFile.readAsStringSync());
  final seeds = _generateSeeds(config);
  final output = _buildOutput(seeds);

  File(_generatedPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(output);

  stdout.writeln('Generated ${seeds.length} shortcuts → $_generatedPath');
}

List<ShortcutSeed> _generateSeeds(ShortcutConfig config) {
  final seeds = <ShortcutSeed>[];
  for (int index = 0; index < _gridSize * _gridSize; index++) {
    final row = (index ~/ _gridSize) + 1;
    final column = (index % _gridSize) + 1;
    final coordinate = '$row$column';
    final isTengen = coordinate == '55';
    final label = isTengen ? config.tengenLabel : 'アプリ ${index + 1}';
    final category = isTengen
        ? '必須'
        : config.categories[index % config.categories.length];
    seeds.add(
      ShortcutSeed(
        coordinate: coordinate,
        label: label,
        category: category,
      ),
    );
  }
  return seeds;
}

String _buildOutput(List<ShortcutSeed> seeds) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// ignore_for_file: type=lint')
    ..writeln()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln()
    ..writeln('class ShortcutSeed {')
    ..writeln('  const ShortcutSeed({')
    ..writeln('    required this.coordinate,')
    ..writeln('    required this.label,')
    ..writeln('    required this.category,')
    ..writeln('  });')
    ..writeln()
    ..writeln('  final String coordinate;')
    ..writeln('  final String label;')
    ..writeln('  final String category;')
    ..writeln('}')
    ..writeln()
    ..writeln('const List<ShortcutSeed> generatedShortcutSeeds = <ShortcutSeed>[');

  for (final seed in seeds) {
    buffer
      ..writeln('  ShortcutSeed(')
      ..writeln("    coordinate: '${seed.coordinate}',")
      ..writeln("    label: '${seed.label}',")
      ..writeln("    category: '${seed.category}',")
      ..writeln('  ),');
  }

  buffer
    ..writeln('];')
    ..writeln()
    ..writeln('IconData iconForCoordinate(int index) {')
    ..writeln('  const iconPool = <IconData>[')
    ..writeln('    Icons.public,')
    ..writeln('    Icons.mail,')
    ..writeln('    Icons.code,')
    ..writeln('    Icons.edit,')
    ..writeln('    Icons.map,')
    ..writeln('    Icons.music_note,')
    ..writeln('    Icons.photo,')
    ..writeln('    Icons.pie_chart,')
    ..writeln('    Icons.settings,')
    ..writeln('  ];')
    ..writeln('  if (index == 40) {')
    ..writeln('    return Icons.star;')
    ..writeln('  }')
    ..writeln('  return iconPool[index % iconPool.length];')
    ..writeln('}')
    ..writeln();

  return buffer.toString();
}
