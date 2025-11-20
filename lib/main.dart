import 'dart:async';

import 'package:flutter/material.dart';

import 'generated/shortcuts.g.dart';

void main() {
  runApp(const GoBoardLauncherApp());
}

class GoBoardLauncherApp extends StatefulWidget {
  const GoBoardLauncherApp({super.key});

  @override
  State<GoBoardLauncherApp> createState() => _GoBoardLauncherAppState();
}

class _GoBoardLauncherAppState extends State<GoBoardLauncherApp> {
  final ShortcutController _shortcutController = ShortcutController();
  String? _statusMessage;
  String? _highlightedCoordinate;

  Timer? _highlightResetTimer;

  late final Map<String, AppShortcut> _shortcutsByCoordinate;
  late final List<AppShortcut> _shortcuts;

  @override
  void initState() {
    super.initState();
    _shortcuts = generateDefaultShortcuts();
    _shortcutsByCoordinate = {
      for (final shortcut in _shortcuts) shortcut.coordinate: shortcut,
    };
    _shortcutController.addListener(_onShortcutTriggered);
  }

  @override
  void dispose() {
    _shortcutController.removeListener(_onShortcutTriggered);
    _shortcutController.dispose();
    _highlightResetTimer?.cancel();
    super.dispose();
  }

  void _onShortcutTriggered() {
    final command = _shortcutController.lastCommand;
    if (command == null) {
      return;
    }
    final shortcut = _shortcutsByCoordinate[command];
    setState(() {
      _statusMessage = shortcut != null
          ? '座標 $command → ${shortcut.label} を起動'
          : '座標 $command に割り当てられたアプリがありません';
    });
    if (shortcut != null) {
      _highlightCoordinate(shortcut.coordinate);
    }
  }

  void _highlightCoordinate(String coordinate) {
    _highlightResetTimer?.cancel();
    setState(() {
      _highlightedCoordinate = coordinate;
    });
    _highlightResetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _highlightedCoordinate = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _shortcutController.focusNode,
      autofocus: true,
      onKey: _shortcutController.handleKeyEvent,
      child: MaterialApp(
        title: 'GoBoard Launcher',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('GoBoard Launcher'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'ショートカット: ggg11〜ggg99',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              ValueListenableBuilder<ShortcutInputStatus>(
                valueListenable: _shortcutController.statusNotifier,
                builder: (context, status, _) {
                  return ShortcutCommandPanel(
                    status: status,
                    statusMessage: _statusMessage,
                  );
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GoBoardGrid(
                        shortcuts: _shortcuts,
                        highlightedCoordinate: _highlightedCoordinate,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoBoardGrid extends StatelessWidget {
  const GoBoardGrid({
    super.key,
    required this.shortcuts,
    this.highlightedCoordinate,
  });

  final List<AppShortcut> shortcuts;
  final String? highlightedCoordinate;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) {
        final shortcut = shortcuts[index];
        return GoBoardCell(
          shortcut: shortcut,
          isHighlighted: shortcut.coordinate == highlightedCoordinate,
        );
      },
    );
  }
}

class GoBoardCell extends StatelessWidget {
  const GoBoardCell({
    super.key,
    required this.shortcut,
    this.isHighlighted = false,
  });

  final AppShortcut shortcut;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final isTengen = shortcut.coordinate == '55';
    final baseColor = isTengen ? Colors.amber.shade200 : Colors.white;
    final highlightColor = isHighlighted ? Colors.greenAccent.shade100 : baseColor;
    final borderColor = isHighlighted
        ? Colors.green
        : (isTengen ? Colors.deepOrange : Colors.brown.shade200);
    final elevation = isHighlighted ? 6 : (isTengen ? 4 : 1);

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isHighlighted ? 1.03 : 1.0,
      child: Card(
        color: highlightColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTengen ? 12 : 6),
          side: BorderSide(
            color: borderColor,
            width: isHighlighted ? 2.5 : (isTengen ? 2 : 1),
          ),
        ),
        elevation: elevation,
        child: InkWell(
          onTap: () {
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(
              SnackBar(content: Text('${shortcut.label} (${shortcut.coordinate})')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  shortcut.icon,
                  size: isTengen ? 32 : 26,
                  color: isHighlighted ? Colors.green.shade900 : null,
                ),
                const SizedBox(height: 6),
                Text(
                  shortcut.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (shortcut.category != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    shortcut.category!,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                          color: Colors.brown.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  shortcut.coordinate,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShortcutCommandPanel extends StatelessWidget {
  const ShortcutCommandPanel({
    super.key,
    required this.status,
    required this.statusMessage,
  });

  final ShortcutInputStatus status;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sequence = status.displaySequence;
    final slots = List<String>.filled(5, '·');
    for (var i = 0; i < sequence.length && i < slots.length; i++) {
      slots[i] = sequence[i].toUpperCase();
    }

    final Color containerColor;
    switch (status.stage) {
      case ShortcutInputStage.invalid:
        containerColor = Colors.red.shade50;
        break;
      case ShortcutInputStage.dispatched:
        containerColor = Colors.green.shade50;
        break;
      default:
        containerColor = Colors.grey.shade100;
    }

    return Container(
      width: double.infinity,
      color: containerColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: slots
                .map(
                  (slot) => Chip(
                    label: Text(slot),
                    backgroundColor: slot == '·'
                        ? Colors.white
                        : theme.colorScheme.primary.withOpacity(0.1),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            status.helperText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: status.stage == ShortcutInputStage.invalid
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
            ),
          ),
          if (statusMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              statusMessage!,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class AppShortcut {
  const AppShortcut({
    required this.coordinate,
    required this.label,
    required this.icon,
    this.category,
  });

  final String coordinate;
  final String label;
  final IconData icon;
  final String? category;
}

List<AppShortcut> generateDefaultShortcuts() {
  return List<AppShortcut>.generate(generatedShortcutSeeds.length, (index) {
    final seed = generatedShortcutSeeds[index];
    final icon = iconForCoordinate(index);

    return AppShortcut(
      coordinate: seed.coordinate,
      label: seed.label,
      icon: icon,
      category: seed.category,
    );
  });
}

class ShortcutController extends ChangeNotifier {
  final FocusNode focusNode = FocusNode();
  final StringBuffer _buffer = StringBuffer();
  final ValueNotifier<ShortcutInputStatus> statusNotifier =
      ValueNotifier<ShortcutInputStatus>(ShortcutInputStatus.empty());
  String? lastCommand;

  void handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) {
      return;
    }
    final keyLabel = event.logicalKey.keyLabel.toLowerCase();
    if (keyLabel == 'g') {
      _appendCharacter('g');
    } else if (_isDigit(keyLabel)) {
      _appendCharacter(keyLabel);
    } else {
      _reset();
    }
  }

  bool _isDigit(String value) {
    return value.length == 1 && RegExp(r'^[1-9]$').hasMatch(value);
  }

  void _appendCharacter(String character) {
    if (_buffer.isEmpty && character != 'g') {
      return;
    }

    _buffer.write(character);
    final sequence = _buffer.toString();

    if (!_isValidProgress(sequence)) {
      if (character == 'g') {
        _buffer
          ..clear()
          ..write('g');
        _updateStatus();
      } else {
        _reset(overrideStatus: ShortcutInputStatus.invalid(sequence));
      }
      return;
    }

    if (sequence.length == 5 && sequence.startsWith('ggg')) {
      final coordinate = sequence.substring(3);
      if (_isValidCoordinate(coordinate)) {
        lastCommand = coordinate;
        notifyListeners();
        _reset(overrideStatus: ShortcutInputStatus.dispatched(coordinate));
        return;
      }
      _reset(overrideStatus: ShortcutInputStatus.invalid(sequence));
      return;
    }

    _updateStatus();
  }

  bool _isValidCoordinate(String value) {
    return RegExp(r'^[1-9]{2}$').hasMatch(value);
  }

  bool _isValidProgress(String sequence) {
    if (sequence.isEmpty) {
      return true;
    }
    if (sequence.length <= 3) {
      return 'ggg'.startsWith(sequence);
    }
    if (!sequence.startsWith('ggg')) {
      return false;
    }
    final suffix = sequence.substring(3);
    return RegExp(r'^[1-9]{0,2}$').hasMatch(suffix);
  }

  void _reset({ShortcutInputStatus? overrideStatus}) {
    _buffer.clear();
    _updateStatus(overrideStatus: overrideStatus);
  }

  void _updateStatus({ShortcutInputStatus? overrideStatus}) {
    statusNotifier.value =
        overrideStatus ?? ShortcutInputStatus.fromBuffer(_buffer.toString());
  }

  @override
  void dispose() {
    focusNode.dispose();
    statusNotifier.dispose();
    super.dispose();
  }
}

enum ShortcutInputStage {
  idle,
  awaitingPrefix,
  awaitingCoordinate,
  ready,
  dispatched,
  invalid,
}

class ShortcutInputStatus {
  const ShortcutInputStatus({
    required this.rawSequence,
    required this.stage,
    this.dispatchedCommand,
    this.invalidSequence,
  });

  final String rawSequence;
  final ShortcutInputStage stage;
  final String? dispatchedCommand;
  final String? invalidSequence;

  factory ShortcutInputStatus.empty() {
    return const ShortcutInputStatus(
      rawSequence: '',
      stage: ShortcutInputStage.idle,
    );
  }

  factory ShortcutInputStatus.dispatched(String command) {
    return ShortcutInputStatus(
      rawSequence: '',
      stage: ShortcutInputStage.dispatched,
      dispatchedCommand: command,
    );
  }

  factory ShortcutInputStatus.invalid(String sequence) {
    return ShortcutInputStatus(
      rawSequence: '',
      stage: ShortcutInputStage.invalid,
      invalidSequence: sequence,
    );
  }

  factory ShortcutInputStatus.fromBuffer(String buffer) {
    if (buffer.isEmpty) {
      return ShortcutInputStatus.empty();
    }

    if (buffer.length < 3) {
      return ShortcutInputStatus(
        rawSequence: buffer,
        stage: ShortcutInputStage.awaitingPrefix,
      );
    }

    if (buffer.length == 3 && buffer == 'ggg') {
      return ShortcutInputStatus(
        rawSequence: buffer,
        stage: ShortcutInputStage.awaitingCoordinate,
      );
    }

    if (buffer.startsWith('ggg')) {
      if (buffer.length < 5) {
        return ShortcutInputStatus(
          rawSequence: buffer,
          stage: ShortcutInputStage.awaitingCoordinate,
        );
      }
      if (buffer.length == 5) {
        return ShortcutInputStatus(
          rawSequence: buffer,
          stage: ShortcutInputStage.ready,
        );
      }
    }

    return ShortcutInputStatus.invalid(buffer);
  }

  String get displaySequence {
    if (stage == ShortcutInputStage.dispatched && dispatchedCommand != null) {
      return 'ggg$dispatchedCommand';
    }
    if (stage == ShortcutInputStage.invalid && invalidSequence != null) {
      return invalidSequence!;
    }
    return rawSequence;
  }

  String get helperText {
    switch (stage) {
      case ShortcutInputStage.idle:
        return 'ggg でランチャーを呼び出し';
      case ShortcutInputStage.awaitingPrefix:
        final remaining = (3 - rawSequence.length).clamp(0, 3);
        return 'ggg をタイプしてください（あと $remaining 文字）';
      case ShortcutInputStage.awaitingCoordinate:
        return '座標 11〜99 を入力するとアプリを呼び出します';
      case ShortcutInputStage.ready:
        final preview = rawSequence.substring(3);
        return '座標 $preview を実行します';
      case ShortcutInputStage.dispatched:
        return dispatchedCommand != null
            ? '座標 $dispatchedCommand を処理しました'
            : 'ショートカットを処理しました';
      case ShortcutInputStage.invalid:
        return '入力が無効なためリセットされました';
    }
  }
}
