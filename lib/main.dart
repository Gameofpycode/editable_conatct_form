import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DataEntry> dataEntries = [];
  int? selectedTileIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Form'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: dataEntries.length,
        itemBuilder: (context, index) {
          return DataEntryWidget(
            dataEntry: dataEntries[index],
            index: index,
            isEditable: selectedTileIndex == index,
            onEdit: () {
              setState(() {
                selectedTileIndex = index;
              });
            },
            onDelete: (index) {
              setState(() {
                dataEntries.removeAt(index);
                selectedTileIndex = null; // Deselect after deletion
              });
            },
            onSave: (index) {
              if (validateDataEntry(dataEntries[index])) {
                setState(() {
                  selectedTileIndex = null; // Deselect after saving edits
                });
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Deselect the current selected tile if any
            selectedTileIndex = null;

            // Add a new entry
            dataEntries.add(DataEntry());
            selectedTileIndex = dataEntries.length - 1;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  bool validateDataEntry(DataEntry dataEntry) {
    return dataEntry.name.isNotEmpty &&
        dataEntry.designation.isNotEmpty &&
        dataEntry.contactNumber.isNotEmpty &&
        isValidEmail(dataEntry.email);
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }
}

class DataEntry {
  String name = '';
  String designation = '';
  String contactNumber = '';
  String email = '';
}

class DataEntryWidget extends StatefulWidget {
  final DataEntry dataEntry;
  final int index;
  final bool isEditable;
  final VoidCallback onEdit;
  final Function(int) onDelete;
  final Function(int) onSave;

  const DataEntryWidget({
    required this.dataEntry,
    required this.index,
    required this.isEditable,
    required this.onEdit,
    required this.onDelete,
    required this.onSave,
  });

  @override
  _DataEntryWidgetState createState() => _DataEntryWidgetState();
}

class _DataEntryWidgetState extends State<DataEntryWidget> {
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.blue[100],
        child: ListTile(
          title: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled, // Initial value
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextFormField(
                  label: 'Name:',
                  initialValue: widget.dataEntry.name,
                  onChanged: (value) {
                    setState(() {
                      widget.dataEntry.name = value!;
                    });
                  },
                  enabled: widget.isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    setState(() {
                      _formKey.currentState?.validate(); // This line triggers validation
                    });
                  },
                ),
                buildTextFormField(
                  label: 'Designation:',
                  initialValue: widget.dataEntry.designation,
                  onChanged: (value) {
                    setState(() {
                      widget.dataEntry.designation = value!;
                    });
                  },
                  enabled: widget.isEditable,
                  validator: (value) {
                    // Your validation logic here
                    return null;
                  },
                ),
                buildTextFormField(
                  label: 'Contact Number:',
                  initialValue: widget.dataEntry.contactNumber,
                  onChanged: (value) {
                    setState(() {
                      widget.dataEntry.contactNumber = value!;
                    });
                  },
                  enabled: widget.isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Contact Number is required';
                    }
                    return null;
                  },
                ),
                buildTextFormField(
                  label: 'Email:',
                  initialValue: widget.dataEntry.email,
                  onChanged: (value) {
                    setState(() {
                      widget.dataEntry.email = value!;
                    });
                  },
                  enabled: widget.isEditable,
                  validator: (value) {
                    if (value != null && !emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: widget.isEditable ? null : widget.onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  widget.onDelete(widget.index);
                },
              ),
              if (widget.isEditable)
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Save the changes and notify the parent
                      widget.onSave(widget.index);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required String label,
    required String? initialValue,
    required Function(String?) onChanged,
    required bool enabled,
    required String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return Row(
      children: [
        Text(label),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: onChanged,
            enabled: enabled,
            validator: validator,
            onFieldSubmitted: onFieldSubmitted,
          ),
        ),
      ],
    );
  }
}
