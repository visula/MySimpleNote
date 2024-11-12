import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MySimpleNote/model/note.dart';

class DbHelper {
	static DbHelper? _dbHelper;
	static Database? _database;

	String noteTable = 'note_table';
	String colId = 'id';
	String colTitle = 'title';
	String colNote = 'note';
	String colPriority = 'priority';
	String colDate = 'date';
	String colPin = 'pin';
	String colHideNote = 'hideNote';
	String colPassword = 'password';

	DbHelper._createInstance();

	factory DbHelper() {
		return _dbHelper ??= DbHelper._createInstance();
	}

	Future<Database> get database async {
		return _database ??= await initializeDatabase();
	}

	Future<Database> initializeDatabase() async {
		Directory directory = await getApplicationDocumentsDirectory();
		String path = '${directory.path}notes.db';

		var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
		return notesDatabase;
	}

	void _createDb(Database db, int newVersion) async {
		await db.execute('CREATE TABLE $noteTable('
				'$colId INTEGER PRIMARY KEY AUTOINCREMENT, '
				'$colTitle TEXT, '
				'$colNote TEXT, '
				'$colPriority INTEGER, '
				'$colDate TEXT, '
				'$colPin INTEGER, '
				'$colHideNote INTEGER, '
				'$colPassword TEXT);');
	}

	Future<List<Map<String, dynamic>>> getNoteMapList() async {
		Database db = await this.database;
		var result = await db.query(noteTable, orderBy: '$colPriority ASC');
		return result;
	}

	Future<int> insertNote(Note note) async {
		Database db = await this.database;
		var result = await db.insert(noteTable, note.toMap());
		return result;
	}

	Future<int> updateNote(Note note) async {
		Database db = await this.database;
		var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
		return result;
	}

	Future<int> deleteNote(int id) async {
		Database db = await this.database;
		var result = await db.delete(noteTable, where: '$colId = ?', whereArgs: [id]);
		return result;
	}

	Future<int?> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
		int? result = Sqflite.firstIntValue(x);
		return result;
	}

	Future<List<Note>> getNoteList() async {
		var noteMapList = await getNoteMapList();
		int count = noteMapList.length;

		List<Note> noteList = [];
		for (int i = 0; i < count; i++) {
			noteList.add(Note.fromMap(noteMapList[i]));
		}
		return noteList;
	}
}
