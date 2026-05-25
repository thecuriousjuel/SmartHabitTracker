import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../habit/provider/habits_provider.dart';
import '../models/note.dart';
import 'rich_text_parser.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  String? _selectedNoteId;
  late TabController _tabController;

  final _headingController = TextEditingController();
  final _bodyController = TextEditingController();
  final _bodyFocusNode = FocusNode();
  double _bodyFontSize = 14.0;

  // Preset background colors for notes supporting Light/Dark modes
  static const Map<int, Map<Brightness, Color>> _noteColorsMap = {
    0: {
      Brightness.light: Colors.white,
      Brightness.dark: Color(0xFF1E1E24),
    },
    1: {
      Brightness.light: Color(0xFFFFF0F0),
      Brightness.dark: Color(0xFF3B1E1E),
    },
    2: {
      Brightness.light: Color(0xFFFFFDF0),
      Brightness.dark: Color(0xFF3B381E),
    },
    3: {
      Brightness.light: Color(0xFFF0FFF5),
      Brightness.dark: Color(0xFF1E3B27),
    },
    4: {
      Brightness.light: Color(0xFFF0F8FF),
      Brightness.dark: Color(0xFF1E2E3B),
    },
    5: {
      Brightness.light: Color(0xFFFDF0FF),
      Brightness.dark: Color(0xFF311E3B),
    },
  };

  static const List<Color> _colorPresetDots = [
    Colors.grey,
    Colors.redAccent,
    Colors.amber,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headingController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  void _selectNote(Note note) {
    setState(() {
      _selectedNoteId = note.id;
      _headingController.text = note.heading;
      _bodyController.text = note.body;
      _tabController.index = 0; // Reset to Edit tab when switching notes
    });
  }

  void _createNewNote(BuildContext context) {
    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    provider.addNote(
      heading: 'New Note',
      body: 'Start writing here...',
      colorHex: 0, // default index
    ).then((_) {
      final notes = provider.notes;
      if (notes.isNotEmpty) {
        _selectNote(notes.first);
      }
    });
  }

  void _insertFormatting(String prefix, String suffix) {
    final text = _bodyController.text;
    final selection = _bodyController.selection;

    if (!selection.isValid) {
      final cursor = selection.baseOffset;
      if (cursor < 0) {
        _bodyController.text = text + prefix + suffix;
      } else {
        final newText = text.substring(0, cursor) + prefix + suffix + text.substring(cursor);
        _bodyController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursor + prefix.length),
        );
      }
    } else {
      final selectedText = selection.textInside(text);
      final newText = selection.textBefore(text) + prefix + selectedText + suffix + selection.textAfter(text);

      _bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + prefix.length,
          extentOffset: selection.start + prefix.length + selectedText.length,
        ),
      );
    }
    _bodyFocusNode.requestFocus();
    _onBodyChanged();
  }

  void _onHeadingChanged() {
    if (_selectedNoteId == null) return;
    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    final note = provider.notes.firstWhere((n) => n.id == _selectedNoteId);
    provider.updateNote(note.copyWith(heading: _headingController.text));
  }

  void _onBodyChanged() {
    if (_selectedNoteId == null) return;
    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    final note = provider.notes.firstWhere((n) => n.id == _selectedNoteId);
    provider.updateNote(note.copyWith(body: _bodyController.text));
  }

  void _onColorChanged(int colorIndex) {
    if (_selectedNoteId == null) return;
    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    final note = provider.notes.firstWhere((n) => n.id == _selectedNoteId);
    provider.updateNote(note.copyWith(colorHex: colorIndex));
  }

  Color _getGlassNoteColor(int colorIndex) {
    switch (colorIndex) {
      case 1:
        return const Color(0xFFFF5252).withValues(alpha: 0.12);
      case 2:
        return const Color(0xFFFFD740).withValues(alpha: 0.12);
      case 3:
        return const Color(0xFF69F0AE).withValues(alpha: 0.12);
      case 4:
        return const Color(0xFF40C4FF).withValues(alpha: 0.12);
      case 5:
        return const Color(0xFFE040FB).withValues(alpha: 0.12);
      case 0:
      default:
        return Colors.white.withValues(alpha: 0.05);
    }
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minuteStr $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitsNotifier>(context);
    final theme = Theme.of(context);
    final notes = provider.notes;

    // Resolve currently selected note
    Note? activeNote;
    if (_selectedNoteId != null) {
      final index = notes.indexWhere((n) => n.id == _selectedNoteId);
      if (index != -1) {
        activeNote = notes[index];
      } else {
        // Safe fallback if deleted
        activeNote = null;
      }
    }

    final isGlass = provider.themeMode == 6;

    final activeBgColor = activeNote != null
        ? (isGlass
            ? _getGlassNoteColor(activeNote.colorHex)
            : (_noteColorsMap[activeNote.colorHex]?[theme.brightness] ?? theme.cardTheme.color ?? theme.colorScheme.surface))
        : (isGlass ? Colors.transparent : theme.colorScheme.surface);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace & Notes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Row(
        children: [
          // Left Sidebar Pane
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Column(
              children: [
                // Create Note Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FilledButton.icon(
                    onPressed: () => _createNewNote(context),
                    icon: const Icon(Icons.add),
                    label: const Text('New Note'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
                Expanded(
                  child: notes.isEmpty
                      ? Center(
                          child: Text(
                            'No notes yet.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        )
                      : ListView.separated(
                          itemCount: notes.length,
                          separatorBuilder: (ctx, idx) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          itemBuilder: (ctx, idx) {
                            final note = notes[idx];
                            final isSelected = note.id == _selectedNoteId;
                            final dotColor = _colorPresetDots[note.colorHex];

                            // Truncate note heading to 20 characters
                            final displayName = note.heading.trim().isEmpty
                                ? 'Untitled Note'
                                : (note.heading.length > 20
                                    ? '${note.heading.substring(0, 20)}...'
                                    : note.heading);

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                              leading: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(
                                displayName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                'Updated ${_formatDateTime(note.updatedAt)}',
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectNote(note),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Right Workspace Content Area
          Expanded(
            child: activeNote == null
                ? Container(
                    color: isGlass ? Colors.transparent : theme.scaffoldBackgroundColor,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Select a note or create a new one to begin editing.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: activeBgColor,
                      border: isGlass ? Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.08))) : null,
                    ),
                    child: isGlass
                        ? ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildNoteWorkspaceContent(context, activeNote, theme),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildNoteWorkspaceContent(context, activeNote, theme),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNoteWorkspaceContent(BuildContext context, Note activeNote, ThemeData theme) {
    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    return [
      // Meta Row: Timestamps and Delete Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Created: ${_formatDateTime(activeNote.createdAt)}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Updated: ${_formatDateTime(activeNote.updatedAt)}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: 'Delete Note',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Note'),
                                    content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          provider.deleteNote(activeNote.id);
                                          setState(() {
                                            _selectedNoteId = null;
                                          });
                                          Navigator.of(ctx).pop();
                                        },
                                        style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                        const Divider(height: 24),

                        // Heading Editable TextField
                        TextField(
                          controller: _headingController,
                          onChanged: (_) => _onHeadingChanged(),
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: 'Untitled Note',
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Styling Toolbar and Color Presets Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Format Actions Toolbar
                            Row(
                              children: [
                                _buildToolbarButton(
                                  icon: Icons.format_bold,
                                  tooltip: 'Bold (Select text or click)',
                                  onPressed: () => _insertFormatting('**', '**'),
                                ),
                                _buildToolbarButton(
                                  icon: Icons.format_italic,
                                  tooltip: 'Italic (Select text or click)',
                                  onPressed: () => _insertFormatting('*', '*'),
                                ),
                                _buildToolbarButton(
                                  icon: Icons.format_underlined,
                                  tooltip: 'Underline (Select text or click)',
                                  onPressed: () => _insertFormatting('<u>', '</u>'),
                                ),
                                _buildToolbarButton(
                                  icon: Icons.border_color,
                                  tooltip: 'Highlight (Select text or click)',
                                  onPressed: () => _insertFormatting('==', '=='),
                                ),
                                _buildToolbarButton(
                                  icon: Icons.format_list_bulleted,
                                  tooltip: 'Unstructured List',
                                  onPressed: () => _insertFormatting('- ', ''),
                                ),
                                _buildToolbarButton(
                                  icon: Icons.format_list_numbered,
                                  tooltip: 'Structured List',
                                  onPressed: () => _insertFormatting('1. ', ''),
                                ),
                                const SizedBox(
                                  height: 20,
                                  child: VerticalDivider(width: 16, thickness: 1),
                                ),
                                _buildToolbarButton(
                                  icon: Icons.text_decrease,
                                  tooltip: 'Decrease Font Size',
                                  onPressed: () {
                                    setState(() {
                                      if (_bodyFontSize > 10.0) _bodyFontSize -= 1.0;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Text(
                                    '${_bodyFontSize.toInt()}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                _buildToolbarButton(
                                  icon: Icons.text_increase,
                                  tooltip: 'Increase Font Size',
                                  onPressed: () {
                                    setState(() {
                                      if (_bodyFontSize < 32.0) _bodyFontSize += 1.0;
                                    });
                                  },
                                ),
                              ],
                            ),
                            // Color Presets Dots
                            Row(
                              children: List.generate(_colorPresetDots.length, (index) {
                                final color = _colorPresetDots[index];
                                final isSelected = activeNote.colorHex == index;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: () => _onColorChanged(index),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(color: theme.colorScheme.onSurface, width: 2)
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tab Bar: Edit vs Preview Mode
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                            tabs: const [
                              Tab(text: 'Edit Note'),
                              Tab(text: 'Preview Render'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tab Views
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Edit View
                              TextField(
                                controller: _bodyController,
                                focusNode: _bodyFocusNode,
                                onChanged: (_) => _onBodyChanged(),
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  hintText: 'Start typing here...',
                                  border: InputBorder.none,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: _bodyFontSize,
                                  height: 1.5,
                                ),
                              ),
                              // Preview View
                              SingleChildScrollView(
                                child: RichTextParser(
                                  text: _bodyController.text,
                                  style: TextStyle(
                                    fontSize: _bodyFontSize,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
