import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final Function(int) onTap;

  CustomBottomNavigationBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFFDCFED7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 1,
            child: Container(
              color: Colors.grey,
            ),
          ),
          PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {
                      onTap(0);
                    },
                    color: Colors.black,
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      onTap(1);
                    },
                    color: Colors.black,
                  ),
                  IconButton(
                    icon: Icon(Icons.group),
                    onPressed: () {
                      onTap(2);
                    },
                    color: Colors.black,
                  ),
                  IconButton(
                    icon: Icon(Icons.person),
                    onPressed: () {
                      onTap(3);
                    },
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
}
