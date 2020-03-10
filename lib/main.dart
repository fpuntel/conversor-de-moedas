import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance";

void main() async{

  runApp(MaterialApp(
      home:Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
      ),
  ));
}

Future<Map> getData() async{
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final pesoController = TextEditingController();
  
  double dolar, euro, pesoArgentino;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2); // 2 digitos
    euroController.text = (real / euro).toStringAsFixed(2); // 2 digitos
    pesoController.text = (real / pesoArgentino).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2); // 2 digitos
    // converte primeiro para reais e depois para euro
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2); // 2 digitos
    pesoController.text = (dolar * this.dolar / pesoArgentino).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2); // 2 digitos
    // converte primeiro para reais e depois para euro
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2); // 2 digitos
    pesoController.text = (euro * this.euro / pesoArgentino).toStringAsFixed(2);
  }
  void _pesoChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double peso = double.parse(text);
    realController.text = (peso * this.pesoArgentino).toStringAsFixed(2); // 2 digitos
    // converte primeiro para reais e depois para euro
    dolarController.text = (peso * this.pesoArgentino / dolar).toStringAsFixed(2);
    euroController.text = (peso * this.pesoArgentino / euro).toStringAsFixed(2); // 2 digitos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      // FutureBuilder - utilizado para aguardar
      // dados vindos de api
      body: FutureBuilder<Map>( 
        future: getData(), // Future é a função que busca os dados
        builder: (context, snapshot){
          // Switch usa para verificar o status da busca de dados
          // do api
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...", 
                  style: TextStyle(color: Colors.amber,
                  fontSize: 25.0), 
                  textAlign: TextAlign.center,),
              );
              break;
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text("Error ao carregar dados...", 
                    style: TextStyle(color: Colors.amber,
                    fontSize: 25.0), 
                    textAlign: TextAlign.center,),
                );
              }else{
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                pesoArgentino = snapshot.data["results"]["currencies"]["ARS"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, 
                            color: Colors.amber),
                      buildTextField("Reais", "R\$", realController, _realChanged),      
                      Divider(), // Da um espaço
                      buildTextField("Dolares", "U\$", dolarController, _dolarChanged),
                      Divider(), // Da um espaço
                      buildTextField("Euros", "\€", euroController, _euroChanged),
                      Divider(), // Da um espaço
                      buildTextField("Pesos Argentinos", "\$", pesoController, _pesoChanged),
                    ],
                  ),
                );                
              }
              break;
          }
        }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController control,
                      Function fun){
  return TextField(
    controller: control,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
        color: Colors.amber),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
        prefixText: prefix
      ),
      style: TextStyle(
        color: Colors.amber, fontSize: 25.0,
      ),
      onChanged: fun,
      keyboardType: TextInputType.number, // teclado numérico
  );

}

