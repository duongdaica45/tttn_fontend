import 'package:flutter/material.dart';
import 'full_time_donXinNghi.dart';
import 'package:hr_payyroll/nhanvien/nhanvien_diemdanh.dart';
import 'package:hr_payyroll/nhanvien/nhanvien_bangluong.dart';
import 'package:hr_payyroll/nhanvien/nhanvien_catrongtuan.dart';
import 'package:hr_payyroll/main.dart';

class FullScreen extends StatelessWidget {
  final Map user;
  const FullScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return HomePage(user: user);
  }
}

class HomePage extends StatelessWidget {
  final Map user;
  const HomePage({super.key, required this.user});

  // Widget hiển thị các thẻ thông tin nhanh (Ví dụ: Ngày công, Phép năm...)
  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.indigo, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // Widget phím tắt chức năng
  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget target,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => target),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.indigo.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.indigo, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tenNhanVien = user['ten_nhan_vien'] ?? "Nhân viên";

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFC),
      appBar: AppBar(
        title: const Text(
          "NHÂN VIÊN FULL-TIME",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              accountName: Text(
                tenNhanVien,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user['email'] ?? "Chưa cập nhật"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.indigo, size: 40),
              ),
            ),
            // Các mục Drawer giữ nguyên logic cũ nhưng thêm Icon cho đẹp
            ListTile(
              leading: const Icon(Icons.home, color: Colors.indigo),
              title: const Text("Trang chủ"),
              onTap: () => Navigator.pop(context),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất"),
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
                (route) => false,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header chào mừng
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Xin chào, $tenNhanVien! 👋",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Chúc bạn có một ngày làm việc tuyệt vời",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Thẻ thống kê nhanh bên trong Header
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Phần menu chính
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chức năng chính",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: [
                      _buildMenuCard(
                        context,
                        "Điểm danh",
                        Icons.fingerprint,
                        Diemdanh(user: user),
                      ),
                      _buildMenuCard(
                        context,
                        "Bảng lương",
                        Icons.receipt_long,
                        BangLuongPage(user: user),
                      ),
                      _buildMenuCard(
                        context,
                        "Ca trong tuần",
                        Icons.calendar_view_week,
                        CaTrongTuanPage(user: user),
                      ),
                      _buildMenuCard(
                        context,
                        "Đơn xin nghỉ",
                        Icons.mail_outline,
                        Donxinnghi(user: user),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Thông báo hoặc nhắc nhở
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Đừng quên điểm danh ra về nhé!",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
