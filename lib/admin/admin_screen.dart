import 'package:flutter/material.dart';
import 'admin_listNhanVien.dart';
import 'admin_date.dart';
import 'admin_duyetdon.dart';
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
              decoration: BoxDecoration(color: Color.fromRGBO(233, 30, 99, 1)),
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
              title: Text("Quản lý nhân viên"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NhanVienScreen()),
                );
              },
            ),
            ListTile(
              title: Text("Quản lý ngày làm"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Quanlyngay()),
                );
              },
            ),
            ListTile(
              title: Text("Duyệt đơn xin nghỉ"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DuyetDon()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text("Đây là trang chính")),
    );
  }
}
