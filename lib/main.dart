import 'package:flutter/material.dart';
import 'models/db_helper.dart';
import 'widgets/new_note_modal_sheet.dart';
import 'widgets/note_update_modal_sheet.dart';
import 'widgets/show_delete__dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo-List',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          scaffoldBackgroundColor: Colors.white),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// ------------------------------------------------------------------------------------------------------------------
class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> notes = [];
  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool loadingIndication = true;

  void alterNoteList() async {
    if (searchController.text.isNotEmpty) {
      final getResults = await DBHelper.searchNote(searchController.text);
      setState(() {
        notes = getResults;
        loadingIndication = false;
        print("Note Searched and refreshed the note list.");
      });
    } else {
      final geAlltNotes = await DBHelper.getNotes();
      setState(() {
        notes = geAlltNotes;
        loadingIndication = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    alterNoteList();
  }

// ---CRUD--------------------------------------------------------------------------------------------------------

// Insert a new note to the database
  Future<void> addNote() async {
    await DBHelper.createNote(titleController.text, descriptionController.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Note Added!')));
    alterNoteList();
    print("Note Added and refreshed the note list.");
  }

  // Update a note
  Future<void> updateNote(int id) async {
    await DBHelper.updateNote(
        id, titleController.text, descriptionController.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Note Updated!')));
    alterNoteList();
    print("Note Updated and refreshed the note list.");
  }

  // Delete a note by id
  void deleteNote(int id) async {
    await DBHelper.deleteNote(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Note Deleted!'),
    ));
    alterNoteList();
    print("Note Deleted and refreshed the note list.");
  }

  // Delete confirmation
  Future<void> showDeleteConfirmation(int id) async {
    return showDeleteDialog(id, context, deleteNote);
  }

  // Search notes
  Future<void> searchNote() async {
    await DBHelper.searchNote(titleController.text);
    alterNoteList();
  }

// ---ModalSheet-----------------------------------------------------------------------------------------------------

  void showUpdateForm(int id) async {
    if (id != null) {
      final existingNotes = notes.firstWhere((element) => element['id'] == id);
      titleController.text = existingNotes['title'];
      descriptionController.text = existingNotes['description'];
    }
    await updateNoteModalSheet(
        context, id, titleController, descriptionController, updateNote);
  }

// -----------------------------------------------------------------------------------------------------------------------
  // NoteList Renderer.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ToDo-List',
          style: TextStyle(
            fontFamily: 'Dancing Script',
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(19.0),
              child: TextField(
                onChanged: (text) {
                  alterNoteList();
                },
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '  Search Keyword',
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            if (notes.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        'assets/images/empty.png',
                        width: 280,
                        fit: BoxFit.scaleDown,
                      ),
                      Text("List is Empty"),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: loadingIndication
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 60),
                        itemCount: notes.length,
                        itemBuilder: (context, index) => Card(
                          color: Colors.white,
                          elevation: 4.5,
                          child: ListTile(
                            title: Text(
                              notes[index]['title'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onTap: () {},
                            subtitle: Text(
                              notes[index]['description'],
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        showUpdateForm(notes[index]['id']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => showDeleteConfirmation(
                                      notes[index]['id'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 20,
        child: const Icon(Icons.mode_edit_outline_outlined),
        onPressed: () => newNoteModalSheet(
            context, titleController, descriptionController, addNote),
      ),
    );
  }
}
