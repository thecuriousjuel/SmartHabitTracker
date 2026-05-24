import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../provider/habits_provider.dart';
import '../models/habit.dart';

class HabitCreationDialog extends StatefulWidget {
  final bool isFirstHabit;
  final Habit? habitToEdit;

  const HabitCreationDialog({
    super.key,
    this.isFirstHabit = false,
    this.habitToEdit,
  });

  @override
  State<HabitCreationDialog> createState() => _HabitCreationDialogState();
}

class _HabitCreationDialogState extends State<HabitCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  late int _selectedIconCode;
  late Color _selectedColor;

  bool _isLifelong = true;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _endDate;

  static const List<IconData> _availableIcons = [
    Icons.directions_run,
    Icons.book,
    Icons.code,
    Icons.fitness_center,
    Icons.local_cafe,
    Icons.water_drop,
    Icons.self_improvement, // Meditation
    Icons.smoke_free,
    Icons.bed,
    Icons.music_note,
    Icons.brush,
    Icons.pets,
    Icons.menu_book,
    Icons.alarm,
    Icons.savings,
  ];

  static const List<Color> _presetColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      final h = widget.habitToEdit!;
      _nameController.text = h.name;
      _descController.text = h.description ?? '';
      _selectedIconCode = h.iconCodePoint;
      _selectedColor = Color(h.colorHex);
      _isLifelong = h.isLifelong;
      _startDate = h.startDate;
      _endDate = h.endDate;
    } else {
      // Auto-assign random icon and color on start
      final rand = Random();
      _selectedIconCode = _availableIcons[rand.nextInt(_availableIcons.length)].codePoint;
      _selectedColor = _presetColors[rand.nextInt(_presetColors.length)];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Habit Icon'),
          content: SizedBox(
            width: 300,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _availableIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIconCode = icon.codePoint;
                    });
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedIconCode == icon.codePoint
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) {
        Color tempColor = _selectedColor;
        return AlertDialog(
          title: const Text('Select Habit Graph Color'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetColors.map((color) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor.toARGB32() == color.toARGB32()
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Divider(height: 24),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Custom Color Picker'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (color) {
                              tempColor = color;
                            },
                            pickerAreaHeightPercent: 0.7,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedColor = tempColor;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('Select'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.palette_outlined),
                label: const Text('Open Custom Color Picker'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<HabitsNotifier>(context, listen: false);

    // Duplicate check
    if (provider.isHabitNameDuplicate(_nameController.text, excludeId: widget.habitToEdit?.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A habit with this name already exists!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (widget.habitToEdit != null) {
      provider.updateHabit(
        id: widget.habitToEdit!.id,
        name: _nameController.text,
        description: _descController.text.isEmpty ? null : _descController.text,
        iconCodePoint: _selectedIconCode,
        colorHex: _selectedColor.toARGB32(),
        isLifelong: _isLifelong,
        startDate: _startDate,
        endDate: _isLifelong ? null : _endDate,
      );
    } else {
      provider.addHabit(
        name: _nameController.text,
        description: _descController.text.isEmpty ? null : _descController.text,
        iconCodePoint: _selectedIconCode,
        colorHex: _selectedColor.toARGB32(),
        isLifelong: _isLifelong,
        startDate: _startDate,
        endDate: _isLifelong ? null : _endDate,
      );
    }

    if (widget.isFirstHabit) {
      provider.completeFirstTimeUser();
      // Dismiss creation dialog and welcome dialog
      Navigator.of(context).pop(); // Pops creation
      Navigator.of(context).pop(); // Pops welcome
    } else {
      Navigator.of(context).pop(); // Pops creation
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = getHabitIcon(_selectedIconCode);

    return PopScope(
      canPop: !widget.isFirstHabit, // First habit dialog is non-dismissible
      child: AlertDialog(
        title: Text(
          widget.habitToEdit != null
              ? 'Edit Habit'
              : (widget.isFirstHabit ? 'Create Your First Habit' : 'Create New Habit'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon & Color Auto-assigned Header
                  Row(
                    children: [
                      // Icon Preview
                      InkWell(
                        onTap: _showIconPicker,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Icon(iconData, size: 32, color: _selectedColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Color Preview
                      InkWell(
                        onTap: _showColorPicker,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _selectedColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _selectedColor, width: 2),
                          ),
                          child: Icon(Icons.color_lens, size: 28, color: _selectedColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Click icon or color box to customize.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Name TextField
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Habit Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a habit name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Description TextField
                  TextFormField(
                    controller: _descController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_outlined),
                      helperText: 'Max 50 characters',
                    ),
                    validator: (val) {
                      if (val != null && val.length > 50) {
                        return 'Description cannot exceed 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  // Duration Picker
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Lifelong Habit', style: TextStyle(fontWeight: FontWeight.w600)),
                              Switch(
                                value: _isLifelong,
                                onChanged: (val) {
                                  setState(() {
                                    _isLifelong = val;
                                    if (_isLifelong) _endDate = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Start Date'),
                            subtitle: Text(
                              '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                            ),
                            trailing: const Icon(Icons.calendar_month),
                            onTap: _selectStartDate,
                          ),
                          if (!_isLifelong) ...[
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('End Date'),
                              subtitle: Text(
                                _endDate == null
                                    ? 'Select end date'
                                    : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                              ),
                              trailing: const Icon(Icons.calendar_month),
                              onTap: _selectEndDate,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          if (!widget.isFirstHabit)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          FilledButton(
            onPressed: _submit,
            child: Text(widget.habitToEdit != null ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
