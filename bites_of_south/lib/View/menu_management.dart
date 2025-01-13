import 'package:flutter/material.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  int itount = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[300],
        onPressed: () {
          setState(() {
            itount += 1;
          });
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: itount,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  color: Colors.grey[300],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14.0)),
                        child: Container(
                          height: MediaQuery.sizeOf(context).height / 8,
                          width: double.maxFinite,
                          child: Image.network(
                            "https://www.cubesnjuliennes.com/wp-content/uploads/2023/10/Best-Crispy-Plain-Dosa-Recipe.jpg",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "Dosa",
                          style: TextStyle(
                              fontSize: MediaQuery.sizeOf(context).height / 45,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Price : 140",
                        style: TextStyle(
                            fontSize: MediaQuery.sizeOf(context).height / 60,
                            fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
