import 'package:flutter/material.dart';
import 'admin_listNhanVien.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home :HomePage(),
    );
  }
}
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trang chính")),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              title: Text("Trang Menu"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminScreen()),
                );
              },
            ),        
            ListTile(
              title: Text("Trang 1"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NhanVienScreen()),
                );
              },
            ),
            // ListTile(
            //   title: Text("Trang 2"),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => Bai2Page(title: "",)),
            //     );
            //   },
            // ),
            // ListTile(
            //   title: Text("Trang 3"),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => Lab5_3_DatHang(title: "",)),
            //     );
            //   },
            //),
          ],
        ),
      ),
      body: Center(child: Text("Đây là trang chính")),
    );
  }
}
