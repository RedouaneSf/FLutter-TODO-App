import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_app/utils/snackbar_helper.dart';

class AddTodoPage extends StatefulWidget{
  final Map? todo;
  const AddTodoPage({super.key,this.todo,});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();

}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEdit= false;

  @override
  void initState() {

    super.initState();
    final todo = widget.todo;
    if(todo !=null){
       isEdit=true;
       final title = todo['title'];
       final description = todo['description'];
       titleController.text=title;
       descriptionController.text=description;
    }
  }


  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(

        title: Text(
           isEdit?'Edit Todo' : 'Add Todo',

        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration:InputDecoration(
              hintText: 'Title'
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: descriptionController,
           decoration:InputDecoration(hintText: 'Description'),
           keyboardType: TextInputType.multiline,
           minLines: 5,
           maxLines: 8,
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: isEdit?updateData: submitData, child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              isEdit?'Update' :'Submit',
            ),
          ),
          )
      ],
      ),
    );
  }

  Future<void> updateData() async{
    //get data form form
    final todo= widget.todo;

    if(todo==null)
      {
        print('You can not call update widget without todo data');
        return;
      }
    final id= todo['_id'];
    final isCompleted= todo['isCompleted'];
    final title=titleController.text;
    final description=descriptionController.text;
    final body= {
      "title": title,
      "description": description,
      "isCompleted": isCompleted,
    };
    final url='https://api.nstack.in/v1/todos/$id';
    final uri=Uri.parse(url);
    final response= await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    //show success or fail message based on status
    if( response.statusCode ==200)
    {
      print('Updated with Success');
      print(response.body);
      titleController.text='';
      descriptionController.text='';
      showSuccessMessage(context,message: 'Updated with Success');
    }else
    { print('Error');
    showErrorMessage(context,message: 'Error');
    print(response.body);
    }

  }

  Future<void> submitData() async{
    //get data form form
     final title=titleController.text;
     final description=descriptionController.text;
     final body={
       "title":title,
       "description":description,
       "isCompleted":false,
     };
    //Submit data to the server
     final url='https://api.nstack.in/v1/todos';
     final uri=Uri.parse(url);
     final response= await http.post(
         uri,
         body: jsonEncode(body),
         headers: {'Content-Type': 'application/json'},
     );
    //show success or fail message based on status
     if( response.statusCode ==201)
       {
         print('Creation Success');
         print(response.body);
         titleController.text='';
         descriptionController.text='';
         showSuccessMessage(context, message: 'Created with success');

       }else
         { print('Error');
         showErrorMessage(context,message: 'Error');
           print(response.body);
         }


  }

}