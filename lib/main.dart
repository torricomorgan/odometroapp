import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:pedometer/pedometer.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

    TextEditingController nombre = TextEditingController();
    TextEditingController correo = TextEditingController();

    Future<String> sendData(String n, String e) async{
    DateTime fechahora = DateTime.now();
    String fechaformato = DateFormat('yyyy-MM-ddTHH:mm:ss').format(fechahora);
    log(fechahora.toString());
    var response = await http.post(
      Uri.encodeFull("https://apicolectormatias.azurewebsites.net/api/odometro"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode(<String, dynamic>{
        "Email":e,
        "Name":n,
        "DateTime":fechaformato,
        "Step":int.parse(_steps)
        })
      );
      print(response.body);
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Odometro Matias'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Pasos:',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _steps,
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),

              TextField(
                controller: nombre,
                decoration: InputDecoration(
                  labelText: "Nombre",
                ),
                keyboardType: TextInputType.name,
              ),
               TextField(
                controller: correo,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              new ElevatedButton(
                onPressed: (){
                  var lnombre = nombre.text;
                  var lcorreo = correo.text;
                  sendData(lnombre, lcorreo); 
                },
                child: new Text("Enviar datos")
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}