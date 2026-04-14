import 'package:flutter/material.dart';
import 'full_time_donXinNghi.dart';
import 'package:hr_payyroll/nhanvien/nhanvien_diemdanh.dart';
import 'package:hr_payyroll/nhanvien/nhanvien_bangluong.dart';
class FullScreen extends StatelessWidget {
  final Map user;

  const FullScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return HomePage(user: user); // ✅ truyền xuống
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
                  MaterialPageRoute(
                    builder: (context) => FullScreen(user: user),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Đơn xin nghỉ"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Donxinnghi(user: user),
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
          ],
        ),
      ),
      body: Center(child: Text("Đây là trang chính")),
    );
  }
}
