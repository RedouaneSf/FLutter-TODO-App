import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:to_do_app/screens/add_page.dart';
import 'package:http/http.dart' as http ;
import 'package:to_do_app/services/todo_service.dart';

class TodoListPage extends StatefulWidget{
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();

}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading=true;
  List items=[];
  void initState()
  {
    super.initState();
    fetchTodo();
  }
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(

        title: Text('Todo List'),
      ),
      body:Visibility(
        visible: isLoading,
         child: Center(child: CircularProgressIndicator()),
        replacement:RefreshIndicator(
        onRefresh: fetchTodo,
        child: Visibility(
          visible: items.isNotEmpty,
          replacement: Center(
            child: Text(
              'No Todo Item',
          style: Theme.of(context).textTheme.bodyLarge,
          ),
          ),
          child: ListView.builder(
          itemCount: items.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (context,index){
             final item= items[index] as Map;
             final id=item['_id'] as String;
             return Card(
               child: ListTile(
                 leading: CircleAvatar(child:Text('${index+1}')),
                 title: Text(item['title']),
                 subtitle: Text(item['description']),
                 trailing: PopupMenuButton(
                   onSelected: (value){
                     if(value=='edit'){
                       //Open Edit Page
                       navigateToEditPage(item);

                     }else
                       if(value=='delete'){
                         //Delete and refrech and remove the item
                         deleteById(id);
                       }
                   },
                   itemBuilder: (context){
                     return[
                       PopupMenuItem(child: Text('Edit'),
                         value: 'edit',
                       ),
                       PopupMenuItem(child: Text('Delete'),
                         value: 'delete',
                       ),
                     ];
                   },
                 ),

               ),
             );
      },),
        ),),),
      floatingActionButton: FloatingActionButton.extended(
          onPressed:navigateToAddPage,
          label: Text('Add Todo')
      ),
    );
  }

  Future<void>navigateToEditPage(Map item) async
  {
    final route = MaterialPageRoute(
      builder:(context) =>AddTodoPage(todo:item ),
    );

    await Navigator.push(context, route);
    setState(() {
      isLoading=true;
    });
    fetchTodo();
  }
  /////////////////////////////
  Future<void> navigateToAddPage() async
  {
    final route = MaterialPageRoute(
       builder:(context) =>AddTodoPage(),
    );
     await Navigator.push(context, route);
     setState(() {
       isLoading=true;
     });
     fetchTodo();
  }
  ////////////////////////////
  Future<void>deleteById(String id)async{
    //Delete the item

    final url='https://api.nstack.in/v1/todos/$id';
    final uri =Uri.parse(url);
    final response=  await http.delete(uri);


    if(response.statusCode ==200){
      //Remove the item from the list
      final filtred = items.where((element)=>element['_id']!=id).toList();
      setState(() {
        items=filtred;
        showSuccessMessage('Deleted with success');

      });

    }else
      {
             showErrorMessage('Error');

      }




  }
  Future<void>fetchTodo()async{

    final url ='https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri=Uri.parse(url);
    final response= await http.get(uri);
    if(response.statusCode==200)
      {
        print(response.statusCode);
        print(response.body);
        final json = jsonDecode(response.body)as Map;
        final result =json['items'] as List;


        setState(() {
          items=result;
        });

      }else
        {
          print(response.statusCode==404);
        }
      setState(() {
        isLoading=false;
      });

    
  }
  void showSuccessMessage(String message)
  {
    final snackBar= SnackBar(content: Text(message,style:TextStyle(color:Colors.white)),backgroundColor: Colors.green,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message)
  {
    final snackBar= SnackBar(content: Text(message,style:TextStyle(color:Colors.white)),backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}