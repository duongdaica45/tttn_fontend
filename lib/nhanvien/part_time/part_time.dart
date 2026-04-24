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

  // Widget phím tắt chức năng Grid (Hồng & Trắng)
  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget target, {
    bool highlight = false,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => target),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: highlight ? Colors.indigo : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: highlight
              ? null
              : Border.all(color: Colors.indigo.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: highlight ? Colors.white : Colors.indigo, size: 35),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: highlight ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thẻ thống kê nhanh cho Part-time (Ví dụ: Số giờ làm, Lương tạm tính)
  Widget _buildStatusChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tenNV = user['ten_nhan_vien'] ?? "Nhân viên";

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFC),
      appBar: AppBar(
        title: const Text(
          "PART-TIME DASHBOARD",
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
                tenNV,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user['email'] ?? "Part-time employee"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: Colors.indigo, size: 40),
              ),
            ),
            _buildDrawerItem(
              context,
              "Trang chủ",
              Icons.home_outlined,
              PartScreen(user: user),
            ),
            _buildDrawerItem(
              context,
              "Đăng ký lịch",
              Icons.edit_calendar_outlined,
              NhanVienNgayMo(user: user),
            ),
            _buildDrawerItem(
              context,
              "Lịch làm",
              Icons.date_range,
              NhanVienNgayMo(user: user),
            ),
            _buildDrawerItem(
              context,
              "Điểm danh",
              Icons.fingerprint,
              Diemdanh(user: user),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
                (route) => false,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner Thông tin nổi bật
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chào bạn, $tenNV!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Hôm nay bạn có lịch làm không?",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Grid Menu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Công việc cần làm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.1,
                      children: [
                        _buildMenuCard(
                          context,
                          "Đăng ký lịch làm",
                          Icons.calendar_month,
                          NhanVienNgayMo(user: user),
                          highlight: true,
                        ),
                        _buildMenuCard(
                          context,
                          "Điểm danh ngay",
                          Icons.location_on_outlined,
                          Diemdanh(user: user),
                        ),
                        _buildMenuCard(
                          context,
                          "Xem bảng lương",
                          Icons.account_balance_wallet_outlined,
                          BangLuongPage(user: user),
                        ),
                        _buildMenuCard(
                          context,
                          "Lịch làm của tôi",
                          Icons.history_outlined,
                          CaTrongTuanPage(user: user),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tip nhỏ bên dưới
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.indigo, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Hãy đăng ký lịch làm trước thứ 6 hàng tuần nhé!",
                      style: TextStyle(fontSize: 12, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget target,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => target),
      ),
    );
  }
}
