import 'dart:io';
import 'dart:math' show Random;
import 'package:expenses/components/list_total.dart';
import 'package:expenses/components/transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'components/transaction_form.dart';
import 'components/transaction_list.dart';
import 'models/transaction.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

main() => runApp(ExpensesApp());

class ExpensesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt'),
      ],
      home: MyHomePage(),
      theme: ThemeData(
        accentColor: Colors.blue,
        primarySwatch: Colors.green,
        fontFamily: 'Quicksand',
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 19,
                  fontWeight: FontWeight.bold),
              button: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  /* SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, //Orientação da Tela Fixa.
    ]);*/
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transaction = [];
  bool _onChart = false;

  List<Transaction> get _recentTransactions {
    return _transaction.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );

    setState(() {
      _transaction.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  _removeTransaction(String id) {
    setState(() {
      _transaction.removeWhere((tr) {
        return tr.id == id;
      });
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.blue[500],
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    bool isLandScape = mediaQuery.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Controle de gastos'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
            ),
          )
        : AppBar(
            title: Text('Controle de gastos'),
            centerTitle: true,
          );

    final alturaTotal = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    final bodyPage = SafeArea(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_onChart || !isLandScape)
            Container(
              height: alturaTotal * (isLandScape ? 0.3 : 0.15),
              child: ListTotal(_transaction),
            ),
          if (!_onChart || !isLandScape)
            Container(
              height: alturaTotal * (isLandScape ? 0.7 : 0.85),
              child: TransactionList(_transaction, _removeTransaction),
            ),
        ],
      ),
    ));

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: appBar,
            child: bodyPage,
          )
        : Scaffold(
            appBar: appBar,
            body: bodyPage,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _openTransactionFormModal(context),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
