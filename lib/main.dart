import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

// import 'package:convert/convert.dart';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?json&key=5a2dd493";

void main() async {
//  print(await getData());

  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber),
          ))));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realAlterado(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    double valorEmDolar = real / dolar;
    double valorEmEuro = real / euro;
    dolarController.text = (valorEmDolar).toStringAsFixed(2);
    euroController.text = (valorEmEuro).toStringAsFixed(2);
    print("Reais alterados para $real, valor em dólares US\$ $valorEmDolar, valor em euros €\$ $valorEmEuro");
  }

  void _dolarAlerado(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    double valorEmReais = dolar * this.dolar;
    realController.text = (valorEmReais).toStringAsFixed(2);
    euroController.text = (valorEmReais / euro).toStringAsFixed(2);
  }

  void _euroAlerado(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    double valorEmReais = euro * this.euro;
    realController.text = (valorEmReais / dolar).toStringAsFixed(2);
    dolarController.text = (valorEmReais).toStringAsFixed(2);
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
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text("Carregando dados ...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Erro ao carregar os dados :(",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center));
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(Icons.monetization_on,
                                size: 150.0, color: Colors.amber),
                            Divider(),
                            buildTextField(
                                "Reais", "R\$ ", realController, _realAlterado),
                            Divider(),
                            buildTextField("Dólares", "US\$ ", dolarController,
                                _dolarAlerado),
                            Divider(),
                            buildTextField(
                                "Euros", "€\$ ", euroController, _euroAlerado)
                          ]));

                  //return Container(color: Colors.green);
                }
            }
          }),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);

  //jsonResponse = json.decode(response.body);
  //print(json.decode(response.body)["results"]["currencies"]["USD"]);

  return json.decode(response.body);
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function funcaoController) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0),
    onChanged: funcaoController,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
