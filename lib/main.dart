import 'package:flutter/material.dart';
import '../view/note_list.dart';

void main() {
	runApp(MyApp());
}

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'MySimpleNote',
			debugShowCheckedModeBanner: false,
			theme: ThemeData(
				primarySwatch: Colors.teal,

				scaffoldBackgroundColor: Colors.white,

				appBarTheme: AppBarTheme(
					backgroundColor: Colors.teal,
					titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
				),

				textTheme: TextTheme(
					bodyLarge: TextStyle(color: Colors.black),
					bodyMedium: TextStyle(color: Colors.black87),
					titleLarge: TextStyle(color: Colors.black87, fontSize: 20),
				),

				inputDecorationTheme: InputDecorationTheme(
					labelStyle: TextStyle(color: Colors.teal),
					focusedBorder: OutlineInputBorder(
						borderSide: BorderSide(color: Colors.teal, width: 2.0),
					),
					enabledBorder: OutlineInputBorder(
						borderSide: BorderSide(color: Colors.grey, width: 1.0),
					),
				),

				elevatedButtonTheme: ElevatedButtonThemeData(
					style: ElevatedButton.styleFrom(
						backgroundColor: Colors.teal,
						foregroundColor: Colors.white,
					),
				),

			),
			home: NoteList(),
		);
	}
}
