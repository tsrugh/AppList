import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _toDoList = [];
  Map<String, dynamic> _lastRemove;
  int _lastRemovedPos;

  final _toDoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        hintText: "Nova Tarefa",
                        hintStyle: TextStyle(color: Colors.deepPurple)),
                  ),
                ),
                RaisedButton(
                  color: Colors.deepPurple,
                  child: Text("Add"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: _toDoList.length,
                    itemBuilder: buildItem),
                onRefresh: refresh,
              )
          )
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return e.toString();
    }
  }

  void _addToDo() {




    setState(() {

      Map<String, dynamic> newToDo = Map();

      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;

      _toDoList.add(newToDo);

      _saveData();

    });
  }

  @override
  void initState()  {
    super.initState();

    setState(() {

      _readData().then((data) {

        _toDoList = json.decode(data);

      });

    });


  }

  Widget buildItem (BuildContext context, int index) {


      return Slidable(

        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigoAccent,
              child: Text('3'),
              foregroundColor: Colors.white,
            ),
            title: Text(_toDoList[index]['title']),
            subtitle: Text('SlidableDrawerDelegate'),
          ),
        ),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Archive',
            color: Colors.blue,
            icon: Icons.archive,
            //onTap: () => _showSnackBar('Archive'),
          ),
          IconSlideAction(
            caption: 'Share',
            color: Colors.indigo,
            icon: Icons.access_time
            //onTap: () => _showSnackBar('Share'),
          ),
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            //caption: 'Editar',
            color: Colors.blue,
            icon: Icons.star,

            //onTap: () => _showSnackBar('More'),
          ),

          IconSlideAction(
            //caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              setState(() {
                _lastRemove = Map.from(_toDoList[index]);

                _lastRemovedPos = index;

                _toDoList.removeAt(index);

                _saveData();

                final snack = SnackBar(
                  content: Text("Tarefa \"${_lastRemove['title']}\" removida"),
                  action: SnackBarAction(label: 'Desfazer',
                    onPressed: () {
                      setState(() {
                        _toDoList.insert(_lastRemovedPos, _lastRemove);
                        _saveData();
                      });
                    },
                  ),
                  duration: Duration(seconds: 2),
                );

                Scaffold.of(context).showSnackBar(snack);
              }
              );},
          ),
        ],

      );


/*    return Dismissible(

      //crossAxisEndOffset: 0.7,
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(0.9, 0),
          child: Icon(Icons.delete),
        ),
      ),
      direction: DismissDirection.endToStart,
      child:   CheckboxListTile(
        onChanged: (c) {
          setState(() {
            _toDoList[index]['ok'] = c;
            _saveData();
          });
        },
        title: Text(_toDoList[index]['title']),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(
              _toDoList[index]['ok'] ? Icons.check : Icons.error),
        ),

      ),
      onDismissed: (direction) {
          setState(() {
            _lastRemove = Map.from(_toDoList[index]);

            _lastRemovedPos = index;

            _toDoList.removeAt(index);

            _saveData();

            final snack = SnackBar(
              content: Text("Tarefa \"${_lastRemove['title']}\" removida"),
              action: SnackBarAction(label: 'Desfazer',
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemove);
                    _saveData();
                  });
                  },
              ),
              duration: Duration(seconds: 2),
            );

            Scaffold.of(context).showSnackBar(snack);
          });
      },
    );*/

  }
  

  Future<Null>refresh() async{
    await Future.delayed(Duration(seconds: 1));


    setState(() {
      _toDoList.sort((a, b) {

        /**
         * 1 se a > b
         * 0 se a == b
         * -1 se b > a
         */
        if(a['ok'] && !b['ok']) return 1;
        else if(!a['ok'] && b['ok']) return -1;
        else return 0;

      });

      _saveData();

    });

    return null;

  }

}
