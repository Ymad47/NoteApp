import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/service/firestore.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

// Textcontroller

final TextEditingController textControlller = TextEditingController();

class _homeState extends State<home> {
  // FireStore
  final FirestoreService firestoreService = FirestoreService();
  // Open a dialogue
  void OpenNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(controller: textControlller),
            actions: [
              // button to save
              ElevatedButton(
                onPressed: () {
                  // add new note
                  if (docID == null) {
                    firestoreService.addNote(textControlller.text);
                  } else {
                    firestoreService.updateNotes(docID, textControlller.text);
                  }

                  // clear the text controller

                  textControlller.clear();
                  // close the box

                  Navigator.pop(context);
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NoteAPP"), backgroundColor: Colors.amber),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // on teste si il y a de la data ou pas
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;

            //affichage de la liste

            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                // get each indvidual doc
                DocumentSnapshot document = noteList[index];
                String docID = document.id;
                // get note from doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // display as a list tile

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // update button
                      IconButton(
                        onPressed: () => OpenNoteBox(docID: docID),
                        icon: Icon(Icons.settings),
                      ),

                      // delete button
                      IconButton(
                        onPressed: () => firestoreService.deleteNotes(docID),
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            // if there no data

            return const Text("no note braaa");
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: OpenNoteBox,
        child: const Icon(Icons.add),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
