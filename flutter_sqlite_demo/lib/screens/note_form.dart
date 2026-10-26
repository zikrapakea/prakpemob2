import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/note.dart';
import '../utils/note_style.dart';

class NoteForm extends StatefulWidget {
  final Note? note;
  const NoteForm({super.key, this.note});

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String category = noteCategories.first;
  int colorIndex = 0;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    if (n != null) {
      titleController.text = n.title;
      contentController.text = n.content;
      category = n.category;
      colorIndex = n.color;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    final db = DatabaseHelper.instance;
    final newNote = Note(
      id: widget.note?.id,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      createdAt: widget.note?.createdAt ?? DateTime.now().toIso8601String(),
      category: category,
      color: colorIndex,
    );

    if (widget.note == null) {
      await db.insert(newNote);
    } else {
      await db.update(newNote);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Tambah Catatan' : 'Edit Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Isi catatan tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text('Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in noteCategories)
                    ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Warna Catatan',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (int i = 0; i < noteColors.length; i++)
                    GestureDetector(
                      onTap: () => setState(() => colorIndex = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: noteColors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorIndex == i
                                ? Colors.indigo
                                : Colors.black26,
                            width: colorIndex == i ? 3 : 1,
                          ),
                        ),
                        child: colorIndex == i
                            ? const Icon(Icons.check,
                                size: 18, color: Colors.indigo)
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
