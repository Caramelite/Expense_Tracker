import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Chart extends StatelessWidget {
  final List<Transaction> recentTrans;
  const Chart(this.recentTrans, {Key? key}) : super(key: key);

  List<Map<String, dynamic>> get transactionValues {
    return List.generate(7, (index) {
      final wDay = DateTime.now().subtract(Duration(days: index));

      var total = 0.0;
      for (var i = 0; i < recentTrans.length; i++) {
        if (wDay.day == recentTrans[i].date.day &&
            wDay.month == recentTrans[i].date.month &&
            wDay.year == recentTrans[i].date.year) {
          total += recentTrans[i].amount;
        }
      }

      return {
        'day': DateFormat.E().format(wDay).substring(0, 3),
        'amount': total
      };
    }).reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    // print(transactionValues);

    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: transactionValues.map((txt) {
            return Flexible(
                fit: FlexFit.tight,
                child: Bar(
                    day: txt['day'],
                    amount: txt['amount'],
                    percent: spending == 0.0
                        ? 0.0
                        : (txt['amount'] as double) / spending));
          }).toList(),
        ),
      ),
    );
  }

  double get spending {
    return transactionValues.fold(0.0, (sum, item) {
      return sum + item['amount'];
    });
  }
}

class Bar extends StatelessWidget {
  final String day;
  final double amount;
  final double percent;

  const Bar({Key? key, required this.day, required this.amount, required this.percent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FittedBox(child: Text('₱${amount.toStringAsFixed(0)}')),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 10,
          height: 100,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 1.0),
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FractionallySizedBox(
                  heightFactor: percent,
                  child: Container(
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(day)
      ],
    );
  }
}

class TransList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function deleteTrans;

  const TransList(this.transactions, this.deleteTrans, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700.0,
      child: transactions.isEmpty
          ? Column(
        children: const <Widget>[
          Text(
            "No Transactions Added Yet",
          ),
          SizedBox(
            height: 10,
          ),
        ],
      )
          : ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            elevation: 5.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal,
                radius: 30,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FittedBox(
                    child: Text('₱ ${transactions[index].amount}'),
                  ),
                ),
              ),
              title: Text(
                transactions[index].title,
              ),
              subtitle: Text(
                DateFormat.yMMMd().format(transactions[index].date),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () => deleteTrans(transactions[index].id),
              ),
            ),
          );
        },
        itemCount: transactions.length,
      ),
    );
  }
}
