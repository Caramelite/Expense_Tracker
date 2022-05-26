import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  Transaction(
      {
        required this.id,
        required this.title,
        required this.amount,
        required this.date});
}

class _HomeState extends State<Home> {
  final List<Transaction> _userTransacs = [];

  List<Transaction> get _getTransactions {
    return _userTransacs.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[900],
        title: const Text(
          "Expense Tracker",
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.add), onPressed: () => newTransaction(context))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: Card(
                  child: Chart(_getTransactions),
                ),
              ),
              TransList(_userTransacs, deleteTrans),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.teal[700],
        onPressed: () => newTransaction(context),
      ),
    );
  }

  void newTransaction(BuildContext contx) {
    showModalBottomSheet(
        context: contx,
        builder: (value) {
          return GestureDetector(
            onTap: () {},
            child: NewTransaction(addNewTransaction),
            behavior: HitTestBehavior.opaque,
          );
        });
  }

  void deleteTrans(String id) {
    setState(() {
      _userTransacs.removeWhere((txt) {
        return ((txt).id == id);
      });
    });
  }

  void addNewTransaction(
      String txtTitle, double txtAmount, DateTime chosenDate) {
    final Transaction newTxt = Transaction(
        title: txtTitle,
        amount: txtAmount,
        date: chosenDate,
        id: DateTime.now().toString());
    setState(() {
      _userTransacs.add(newTxt);
    });
  }
}

//NEW TRANSACTIONS
class NewTransaction extends StatefulWidget {
  final Function addTxt;

  const NewTransaction(this.addTxt, {Key? key}) : super(key: key);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Container(
        padding: const EdgeInsets.only(
            top: 10.0,
            left: 10.0,
            right: 10.0,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              onSubmitted: (_) => _submit(),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Amount'),
              controller: _amountController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submit(),
            ),
            SizedBox(
              height: 70,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No Date Chosen'
                          : 'Picked Date ${DateFormat.yMd().format(_selectedDate!)}',
                    ),
                  ),
                  ElevatedButton (
                    child: const Text('Choose Date'),
                    onPressed: _showDate,
                  ),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(primary: Colors.teal[700]),
              child: const Text('Add Transaction'),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_amountController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0 || _selectedDate == null) {
      return;
    }
    widget.addTxt(enteredTitle, enteredAmount, _selectedDate);

    Navigator.of(context).pop();
  }

  void _showDate() {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2019),
        lastDate: DateTime.now())
        .then((pickDate) {
      if (pickDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickDate;
      });
    });
  }
}
