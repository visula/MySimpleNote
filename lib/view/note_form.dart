import 'package:flutter/material.dart';
import 'package:MySimpleNote/model/note.dart';
import 'package:MySimpleNote/config/db_helper.dart';

class NoteForm extends StatefulWidget {
	final String appBarTitle;
	final Note note;

	NoteForm(this.note, this.appBarTitle);

	@override
	State<StatefulWidget> createState() {
		return NoteFormState(this.note, this.appBarTitle);
	}
}

class NoteFormState extends State<NoteForm> {
	DbHelper dbHelper = DbHelper();
	String appBarTitle;
	Note note;
	TextEditingController titleController = TextEditingController();
	TextEditingController descriptionController = TextEditingController();
	TextEditingController passwordController = TextEditingController(); // Controller for password

	static var _priorities = ['High', 'Low'];

	NoteFormState(this.note, this.appBarTitle);

	@override
	Widget build(BuildContext context) {
		titleController.text = note.getTitle;
		descriptionController.text = note.getNote;

		return Scaffold(
			appBar: AppBar(
				title: Text(appBarTitle),
				backgroundColor: Colors.teal,
				leading: IconButton(
					icon: Icon(Icons.arrow_back),
					color: Colors.white,
					onPressed: () {
						moveToLastScreen();
					},
				),
				actions: [
					IconButton(
						icon: Icon(Icons.save),
						color: Colors.white,
						onPressed: () {
							setState(() {
								_save();
							});
						},
					),
					if (note.id != null)
						IconButton(
							icon: Icon(Icons.delete),
							color: Colors.white,
							onPressed: () {
								_delete();
							},
						),
					if (note.id != null)
						IconButton(
							icon: Icon(
								note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
								color: Colors.white,
							),
							onPressed: () {
								setState(() {
									note.setPin = !note.isPinned;
									_update();
								});
							},
						),
					if (note.id != null)
						IconButton(
							icon: Icon(
								note.isHidden ? Icons.visibility : Icons.visibility_off,
								color: Colors.white,
							),
							onPressed: () {
								if (!note.isHidden) {
									_showPasswordDialog();
								} else {
									setState(() {
										note.setHideNote = false;
									});
									_update();
								}
							},
						),

				],
			),
			body: Padding(
				padding: EdgeInsets.all(10.0),
				child: Column(
					children: <Widget>[
						ListTile(
							title: DropdownButton<String>(
								items: _priorities.map((String dropDownStringItem) {
									return DropdownMenuItem<String>(
										value: dropDownStringItem,
										child: Text(
											dropDownStringItem,
											style: TextStyle(color: Colors.white),
										),
									);
								}).toList(),
								value: getPriorityAsString(note.getPriority),
								dropdownColor: Color(0xFF26A69A),
								onChanged: (valueSelectedByUser) {
									setState(() {
										updatePriorityAsInt(valueSelectedByUser!);
									});
								},
							),
							tileColor: Color(0xFF26A69A),
						),
						Padding(
							padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
							child: TextField(
								controller: titleController,
								onChanged: (value) {
									updateTitle();
								},
								decoration: InputDecoration(
									labelText: 'Title',
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(5.0),
									),
								),
							),
						),
						Expanded(
							child: Padding(
								padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
								child: TextField(
									controller: descriptionController,
									maxLines: null,
									expands: true,
									textAlignVertical: TextAlignVertical.top,
									onChanged: (value) {
										updateDescription();
									},
									decoration: InputDecoration(
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0),
										),
									),
								),
							),
						),
					],
				),
			),
		);
	}

	void moveToLastScreen() {
		Navigator.pop(context, true);
	}

	String getPriorityAsString(int value) {
		return _priorities[value - 1];
	}

	void updatePriorityAsInt(String value) {
		switch (value) {
			case 'High':
				note.setPriority = 1;
				break;
			case 'Low':
				note.setPriority = 2;
				break;
		}
	}

	void updateTitle() {
		note.setTitle = titleController.text;
	}

	void updateDescription() {
		note.setNote = descriptionController.text;
	}

	void _save() async {
		print('Saving note...');
		moveToLastScreen();
		note.setDate = DateTime.now().toString();

		int result;
		if (note.id != null) {
			print('Updating note...');
			result = await dbHelper.updateNote(note);
		} else {
			print('Inserting new note...');
			result = await dbHelper.insertNote(note);
		}

		if (result != 0) {
			_showAlertDialog('Saved!', 'Note Saved Successfully');
		} else {
			_showAlertDialog('Error!', 'Problem Saving Note');
		}
	}

	void _update() async {
		note.setDate = DateTime.now().toString();

		int result;
		if (note.id != null) {
			print('Updating note...');
			result = await dbHelper.updateNote(note);
		} else {
			print('Inserting new note...');
			result = await dbHelper.insertNote(note);
		}
	}

	void _delete() async {
		if (note.id == null) {
			_showAlertDialog('Status', 'No Note was deleted');
			return;
		}

		bool? deleteConfirmed = await showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text("Delete Note"),
					content: Text("Are you sure you want to delete this note?"),
					actions: <Widget>[
						TextButton(
							child: Text("Cancel"),
							onPressed: () {
								Navigator.of(context).pop(false);
							},
							style: TextButton.styleFrom(
								foregroundColor: Colors.white, backgroundColor: Colors.teal,
							),
						),
						TextButton(
							child: Text("Delete"),
							onPressed: () {
								Navigator.of(context).pop(true);
							},
							style: TextButton.styleFrom(
								foregroundColor: Colors.white, backgroundColor: Colors.teal,
							),
						),
					],
				);
			},
		);

		if (deleteConfirmed == true) {
			moveToLastScreen();

			int result = await dbHelper.deleteNote(note.id!);
			if (result != 0) {
				_showAlertDialog('Deleted!', 'Note Deleted Successfully');
			} else {
				_showAlertDialog('Error!', 'Error Occurred while Deleting Note');
			}
		}
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

	void _showPasswordDialog() {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text("Enter Password to Hide Note"),
					content: TextField(
						controller: passwordController,
						obscureText: true,
						decoration: InputDecoration(
							labelText: 'Password',
							border: OutlineInputBorder(),
						),
					),
					actions: [
						TextButton(
							child: Text("Cancel"),
							onPressed: () {
								Navigator.pop(context);
							},
							style: TextButton.styleFrom(
								foregroundColor: Colors.white, backgroundColor: Colors.teal,
							),
						),
						TextButton(
							child: Text("Hide"),
							onPressed: () {
								setState(() {
									note.setPassword = passwordController.text;
									note.setHideNote = true;
									_update();
									Navigator.of(context).pop();
								});
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
}
