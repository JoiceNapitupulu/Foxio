import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/todo_entity.dart';
import '../providers/todo_provider.dart';
import 'cozy_button.dart';
import 'cozy_text_field.dart';

class TodoFormSheet extends ConsumerStatefulWidget {
  final TodoEntity? existingTodo;

  const TodoFormSheet({super.key, this.existingTodo});

  static Future<void> show(
    BuildContext context, {
    TodoEntity? existingTodo,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TodoFormSheet(existingTodo: existingTodo),
    );
  }

  @override
  ConsumerState<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends ConsumerState<TodoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  DateTime? _deadline;
  bool _isSaving = false;

  bool get _isEditing => widget.existingTodo != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingTodo?.title ?? '');
    _descController =
        TextEditingController(text: widget.existingTodo?.description ?? '');
    _deadline = widget.existingTodo?.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initialDate = _deadline ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(DateTime(2020)) ? now : initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _deadline != null
          ? TimeOfDay.fromDateTime(_deadline!)
          : const TimeOfDay(hour: 23, minute: 59),
    );

    if (!mounted) return;

    final time = pickedTime ?? const TimeOfDay(hour: 23, minute: 59);
    setState(() {
      _deadline = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);
    final notifier = ref.read(todoProvider.notifier);

    final bool ok;
    if (_isEditing) {
      ok = await notifier.editTodo(
        id: widget.existingTodo!.id,
        title: _titleController.text,
        description: _descController.text,
        deadline: _deadline,
      );
    } else {
      ok = await notifier.addTodo(
        title: _titleController.text,
        description: _descController.text,
        deadline: _deadline,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet handle bar
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? 'Edit Task' : 'Tambah Task Baru',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 18),

              // Title Field
              CozyTextField(
                controller: _titleController,
                label: 'Judul Task',
                hintText: 'Contoh: Kumpulkan Tugas Kalkulus',
                prefixIcon: Icons.task_alt_rounded,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Judul task wajib diisi';
                  }
                  if (text.length > 200) {
                    return 'Maksimal 200 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Optional Multi-line Description
              Text(
                'Catatan (Opsional)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                maxLength: 1000,
                textInputAction: TextInputAction.newline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                    ),
                decoration: const InputDecoration(
                  hintText: 'Tambahkan detail atau referensi materi...',
                  counterText: '',
                ),
                validator: (val) {
                  if (val != null && val.length > 1000) {
                    return 'Maksimal 1000 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deadline Selector Row
              Text(
                'Deadline (Opsional)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _deadline == null
                              ? 'Pilih tanggal & jam deadline'
                              : DateFormat('EEEE, d MMM yyyy • HH:mm')
                                  .format(_deadline!),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _deadline == null
                                        ? AppColors.textMuted
                                        : AppColors.textPrimary,
                                    fontWeight: _deadline == null
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                        ),
                      ),
                      if (_deadline != null)
                        GestureDetector(
                          onTap: () => setState(() => _deadline = null),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              CozyButton(
                label: _isEditing ? 'Simpan Perubahan' : 'Tambah Task',
                isLoading: _isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
