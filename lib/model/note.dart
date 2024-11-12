class Note {
	int? id;
	String title;
	String note;
	String date;
	int priority;
	bool pin;
	bool hideNote;
	String? password;

	Note({
		this.id,
		required this.title,
		required this.note,
		required this.date,
		required this.priority,
		this.pin = false,
		this.hideNote = false,
		this.password,
	});

	String get getTitle => title;
	String get getNote => note;
	String get getDate => date;
	int get getPriority => priority;
	bool get isPinned => pin;
	bool get isHidden => hideNote;
	String? get getPassword => password;

	set setTitle(String value) {
		this.title = value;
	}

	set setNote(String value) {
		this.note = value;
	}

	set setDate(String value) {
		this.date = value;
	}

	set setPriority(int value) {
		this.priority = value;
	}

	set setPin(bool value) {
		this.pin = value;
	}

	set setHideNote(bool value) {
		this.hideNote = value;
	}

	set setPassword(String? value) {
		this.password = value;
	}

	@override
	String toString() {
		return 'Note{id: $id, title: $title, note: $note, date: $date, priority: $priority, pin: $pin, hideNote: $hideNote, password: $password}';
	}

	Map<String, dynamic> toMap() {
		var map = <String, dynamic>{
			'title': title,
			'note': note,
			'date': date,
			'priority': priority,
			'pin': pin ? 1 : 0,
			'hideNote': hideNote ? 1 : 0,
			'password': password,
		};
		if (id != null) {
			map['id'] = id;
		}
		return map;
	}

	static Note fromMap(Map<String, dynamic> map) {
		return Note(
			id: map['id'],
			title: map['title'],
			note: map['note'],
			date: map['date'],
			priority: map['priority'],
			pin: map['pin'] == 1,
			hideNote: map['hideNote'] == 1,
			password: map['password'],
		);
	}
}
