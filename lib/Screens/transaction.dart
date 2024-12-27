import 'package:flutter/material.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  const Color.fromARGB(255, 2, 41, 73),
        title: const Text
        (
          'Inbox',
                style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications,color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Find using Transcation Number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                TransactionTile(
                  icon: Icons.shopping_bag,
                  title: 'EK PAY',
                  amount: '- ৳100.00',
                  time: '12:29am 26/12/24',
                  trxId: 'BLQ4DBPPWS',
                ),
                TransactionTile(
                  icon: Icons.verified,
                  title: 'NID Service',
                  amount: '- ৳345.00',
                  time: '07:51pm 23/12/24',
                  trxId: 'BLN2BDMLP0',
                ),
                TransactionTile(
                  icon: Icons.phone_android,
                  title: '01522108316',
                  amount: '- ৳20.00',
                  time: '07:34am 22/12/24',
                  trxId: 'BLM79T2ID1',
                ),
                TransactionTile(
                  icon: Icons.electrical_services,
                  title: 'Palli Bidyut (Postpaid)',
                  amount: '- ৳216.00',
                  time: '06:53pm 19/12/24',
                  trxId: 'BLJ67WM1EA',
                ),
                TransactionTile(
                  icon: Icons.electrical_services,
                  title: 'Palli Bidyut (Prepaid)',
                  amount: '- ৳1,000.00',
                  time: '02:16pm 17/12/24',
                  trxId: 'BLH95UCD6D',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 2, 41, 73),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'QR Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Inbox',
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;
  final String time;
  final String trxId;

  const TransactionTile({
    required this.icon,
    required this.title,
    required this.amount,
    required this.time,
    required this.trxId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TrxID: $trxId'),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
      trailing: Text(amount, style: const TextStyle(color:  Color.fromARGB(255, 2, 41, 73) ,fontWeight: FontWeight.bold)),
    );
  }
}
