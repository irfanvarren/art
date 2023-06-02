import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:art/main.dart';

class SelectBoxWithSearchInput extends StatefulWidget {
  final String labelText;
  final String collectionPath;

  const SelectBoxWithSearchInput({
    required this.labelText,
    required this.collectionPath,
  });

  @override
  _SelectBoxWithSearchInputState createState() =>
      _SelectBoxWithSearchInputState();
}

class _SelectBoxWithSearchInputState extends State<SelectBoxWithSearchInput> {
  String selectedOption = '';
  String searchQuery = '';

  List<String> options = [];
  List<String> filteredOptions = [];

  @override
  void initState() {
    super.initState();
    //fetchOptions();
  }

  Future<void> fetchOptions() async {
    await initializeFirebase();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(widget.collectionPath)
        .get();

    List<String> fetchedOptions =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();

    setState(() {
      options = fetchedOptions;
      filteredOptions = fetchedOptions;
    });
  }

  void filterOptions(String query) {
    List<String> filteredList = options
        .where((option) => option.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      searchQuery = query;
      filteredOptions = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: fetchOptions(),
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: filterOptions,
                decoration: InputDecoration(
                  labelText: 'Search',
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedOption.isNotEmpty &&
                        filteredOptions.contains(selectedOption)
                    ? selectedOption
                    : null,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
                items: filteredOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: widget.labelText,
                ),
              ),
            ],
          );
        });
  }
}
