import 'package:flutter/material.dart';
import 'package:hr_payyroll/nhanvien/part_time/part_time_dangki.dart';
import 'package:hr_payyroll/nhanvien/nhanvien_diemdanh.dart';
import 'package:hr_payyroll/nhanvien/nhanvien_bangluong.dart';
import 'package:hr_payyroll/nhanvien/nhanvien_catrongtuan.dart';
import 'package:hr_payyroll/main.dart';
class PartScreen extends StatelessWidget {
  const PartScreen({super.key, required this.user});
  final Map user;

  @override
  Widget build(BuildContext context) {
    return HomePage(user: user);
  }
}

class HomePage extends StatelessWidget {
  final Map user;
  const HomePage({super.key, required this.user});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trang chính")),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 233, 30, 99),
              ),
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
                  MaterialPageRoute(
                    builder: (context) => PartScreen(user: user),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Đăng kí lịch làm"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NhanVienNgayMo(user: user),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Điểm danh"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Diemdanh(user: user)),
                );
              },
            ),
            ListTile(
              title: Text("Bảng lương"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BangLuongPage(user: user),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Ca trong tuần"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaTrongTuanPage(user: user),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Đăng xuất"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
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
