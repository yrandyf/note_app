import 'package:flutter/material.dart';

updateNoteModalSheet(
    context, int id, titleController, descriptionController, updateNote) async {
  final maxLines = 5;
  final formKey = GlobalKey<FormState>();
  showModalBottomSheet(
    enableDrag: true,
    isScrollControlled: true,
    context: context,
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.5)),
    builder: (_) => Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 325,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Update Note",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                        labelText: 'Title',
                        suffixIcon: IconButton(
                          onPressed: titleController.clear,
                          icon: Icon(Icons.clear),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    maxLines: maxLines,
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      filled: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: IconButton(
                          onPressed: descriptionController.clear,
                          icon: Icon(Icons.clear),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await updateNote(id);

                          titleController.clear;
                          descriptionController.clear;

                          Navigator.of(context).pop();
                        },
                        child: Text("Update Note"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
