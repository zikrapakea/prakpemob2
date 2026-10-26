import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/note.dart';
import '../utils/note_style.dart';
import 'note_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper.instance;
  final searchController = TextEditingController();
  List<Note> notes = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final data = await db.getNotes(
      keyword: searchController.text,
      category: selectedCategory,
    );
    if (!mounted) return;
    setState(() => notes = data);
  }

  Future<void> _openForm({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteForm(note: note)),
    );
    if (result == true) _loadNotes();
  }

  Future<void> _confirmDelete(Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan ini?'),
        content: Text('Catatan "${note.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await db.delete(note.id!);
    await _loadNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan dihapus')),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtering =
        searchController.text.isNotEmpty || selectedCategory != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan SQLite')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: searchController,
              onChanged: (_) => _loadNotes(),
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _loadNotes();
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                for (final c in <String?>[null, ...noteCategories])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c ?? 'Semua'),
                      selected: selectedCategory == c,
                      onSelected: (_) {
                        setState(() => selectedCategory = c);
                        _loadNotes();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Text(filtering
                        ? 'Catatan tidak ditemukan.'
                        : 'Belum ada catatan.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: notes.length,
                    itemBuilder: (context, i) {
                      final note = notes[i];
                      return Card(
                        color: noteColor(note.color),
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 8, 8, 8),
                          title: Text(
                            note.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  _info(Icons.folder_outlined, note.category),
                                  _info(Icons.schedule,
                                      formatTanggal(note.createdAt)),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => _openForm(note: note),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () => _confirmDelete(note),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
