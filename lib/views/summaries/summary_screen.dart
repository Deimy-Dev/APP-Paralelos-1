import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final Map<String, List<String>> resumenMensual = {
    'Enero 2025': ['1984', 'Cien años de soledad'],
    'Febrero 2025': ['El principito'],
    'Marzo 2025': ['Clean Code', 'The Pragmatic Programmer'],
  };

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: resumenMensual.length,
      itemBuilder: (context, index) {
        final mes = resumenMensual.keys.elementAt(index);
        final libros = resumenMensual[mes]!;

        return ExpansionTile(
          title: Text(mes, style: TextStyle(fontWeight: FontWeight.bold)),
          children: libros
              .map((libro) => ListTile(
                    title: Text(libro),
                    leading: Icon(Icons.book),
                  ))
              .toList(),
        );
      },
    );
  }
}
