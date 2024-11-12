import 'package:flutter/material.dart';
import 'package:MySimpleNote/config/db_helper.dart';
import 'package:MySimpleNote/model/note.dart';
import 'note_form.dart';

class NoteList extends StatefulWidget {
	@override
	_NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
	DbHelper dbHelper = DbHelper();
	List<Note> noteList = [];
	List<Note> _filteredNoteList = [];
	bool _showHiddenNotes = false;
	int count = 0;
	TextEditingController searchController = TextEditingController();

	@override
	void initState() {
		super.initState();
		updateListView(); // Call updateListView() when the page is first loaded
	}

	@override
	Widget build(BuildContext context) {
		if (noteList.isEmpty) {
			updateListView();
		}

		return Scaffold(
			appBar: AppBar(
				title: const Text('Notes'),
				backgroundColor: Colors.teal,
				actions: [
					IconButton(
						icon: Icon(
							_showHiddenNotes ? Icons.visibility : Icons.visibility_off,
							color: Colors.white,
						),
						onPressed: _toggleHiddenNotes,
					),
				],
			),
			body: Column(
				children: [
					Padding(
						padding: const EdgeInsets.all(8.0),
						child: TextField(
							controller: searchController,
							decoration: InputDecoration(
								labelText: 'Search',
								prefixIcon: Icon(Icons.search),
								border: OutlineInputBorder(
									borderRadius: BorderRadius.circular(8.0),
								),
							),
							onChanged: (value) {
								_filterNotes(value);
							},
						),
					),
					Expanded(child: getNoteListView()),
				],
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					navigateToDetail(
						Note(
							title: '',
							note: '',
							priority: 2,
							date: DateTime.now().toString(),
							pin: false,
							hideNote: false,
							password: ''
						),
						'New Note',
					);
				},
				child: Icon(Icons.add),
				backgroundColor: const Color(0xFF00897B),
				foregroundColor: Color(0xFFFFFFFF),
			),
		);
	}

	Widget getNoteListView() {
		if (_filteredNoteList.isEmpty) {
			return Center(
				child: Text(
					'No notes found.',
					style: TextStyle(fontSize: 18, color: Colors.grey),
				),
			);
		}

		return ListView.builder(
			itemCount: _filteredNoteList.length,
			itemBuilder: (BuildContext context, int position) {
				return Card(
					child: ListTile(
						leading: Container(
							width: 5.0,
							height: 60.0,
							color: _getPriorityColor(_filteredNoteList[position].priority),
						),
						title: Text(_filteredNoteList[position].title),
						subtitle: Text(_filteredNoteList[position].date),
						trailing: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								IconButton(
									icon: Icon(
										_filteredNoteList[position].isPinned
												? Icons.push_pin
												: Icons.push_pin_outlined,
										color: Colors.teal,
									),
									onPressed: () {
										_togglePin(_filteredNoteList[position]);
									},
								),
								IconButton(
									icon: Icon(Icons.delete, color: Colors.grey),
									onPressed: () {
										_showDeleteConfirmationDialog(
												context, _filteredNoteList[position]);
									},
								),
							],
						),
						onTap: () async {
							bool canOpen = true;
							if(_filteredNoteList[position].isHidden){
								canOpen = await _checkPassword(_filteredNoteList[position].password);
							}
							if (canOpen) {
								navigateToDetail(_filteredNoteList[position], 'Edit Note');
							}
						},
					),
				);
			},
		);
	}

	Color _getPriorityColor(int priority) {
		switch (priority) {
			case 1:
				return Colors.red;
			case 2:
				return Colors.yellow;
			default:
				return Colors.grey;
		}
	}

	void _showDeleteConfirmationDialog(BuildContext context, Note note) {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text("Delete Note"),
					content: Text("Are you sure you want to delete this note?"),
					actions: <Widget>[
						TextButton(
							child: Text("Cancel"),
							onPressed: () {
								Navigator.of(context).pop();
							},
							style: TextButton.styleFrom(
								foregroundColor: Colors.white, backgroundColor: Colors.teal,
							),
						),
						TextButton(
							child: Text("Delete"),
							onPressed: () async {
								int result = await dbHelper.deleteNote(note.id!);

								Navigator.of(context).pop();

								if (result != 0) {
									_showAlertDialog('Deleted!', 'Note Deleted Successfully');
								} else {
									_showAlertDialog('Error!', 'Error Occurred while Deleting Note');
								}

								updateListView();
							},
							style: TextButton.styleFrom(
								foregroundColor: Colors.white, backgroundColor: Colors.teal,
							),
						),
					],
				);
			},
		);
	}

	void _showAlertDialog(String title, String message) {
		AlertDialog alertDialog = AlertDialog(
			title: Text(title),
			content: Text(message),
		);
		showDialog(
			context: context,
			builder: (_) => alertDialog,
		);
	}

	void navigateToDetail(Note note, String title) async {
		bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
			return NoteForm(note, title);
		}));
		if (result) {
			updateListView();
		}
	}

	void updateListView() async {
		final List<Note> allNotes = await dbHelper.getNoteList();

		allNotes.sort((a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0));

		setState(() {
			noteList = allNotes;
			_filteredNoteList = allNotes.where((note) => _showHiddenNotes || !note.isHidden).toList();
			count = allNotes.length;
		});
	}


	void _filterNotes(String query) {
		setState(() {
			_filteredNoteList = noteList.where((note) =>
			note.title.toLowerCase().contains(query.toLowerCase()) ||
					note.note.toLowerCase().contains(query.toLowerCase())
			).toList();
		});
	}

	void _toggleHiddenNotes() {
		setState(() {
			_showHiddenNotes = !_showHiddenNotes;
			updateListView();
		});
	}

	Future<bool> _checkPassword(String? savedPassword) async {
		String password = '';
		bool isPasswordCorrect = await showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text("Enter Password"),
					content: TextField(
						obscureText: true,
						onChanged: (value) {
							password = value;
						},
						decoration: InputDecoration(hintText: "Password"),
					),
					actions: [
						TextButton(
							onPressed: () {
								Navigator.of(context).pop(password == savedPassword);
							},
							child: Text("OK"),
							style: TextButton.styleFrom(
								foregroundColor: Colors.white, backgroundColor: Colors.teal,
							),
						),
					],
				);
			},
		);
		return isPasswordCorrect;
	}

	void _togglePin(Note note) async {
		note.pin = !note.isPinned;
		await dbHelper.updateNote(note);
		updateListView();
	}
}
