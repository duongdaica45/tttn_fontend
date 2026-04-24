import 'package:flutter/material.dart';
import 'admin_listNhanVien.dart';
import 'admin_date.dart';
import 'admin_duyetdon.dart';
import 'admin_QuanLyBangLuong.dart';
import 'package:hr_payyroll/main.dart'; // Đảm bảo đường dẫn này đúng với trang Login của bạn

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Hàm tiện ích để tạo các thẻ thống kê nhanh
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  // Hàm tạo nút menu ở giữa màn hình
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.indigo.shade50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo.shade50,
              radius: 25,
              child: Icon(icon, color: Colors.indigo, size: 28),
            ),
            const SizedBox(height: 10),
            Text(title, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFC),
      appBar: AppBar(
        title: const Text("ADMIN DASHBOARD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              accountName: Text("Quản trị viên", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text("admin@company.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.indigo, size: 40),
              ),
            ),
            _buildDrawerItem(context, "Bảng điều khiển", Icons.dashboard, const HomePage()),
            _buildDrawerItem(context, "Quản lý nhân viên", Icons.people, const NhanVienScreen()),
            _buildDrawerItem(context, "Quản lý ngày làm", Icons.calendar_today, const Quanlyngay()),
            _buildDrawerItem(context, "Duyệt đơn nghỉ", Icons.assignment_turned_in, const DuyetDon()),
            _buildDrawerItem(context, "Quản lý lương", Icons.monetization_on, const DanhSachNhanVien()),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Chào mừng trở lại ! 👋", 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Hệ thống quản lý lương đang hoạt động ổn định", 
              style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 25),                
            const SizedBox(height: 30),
            const Text("Chức năng quản lý", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Grid Menu Chức năng
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMenuItem(context, "Nhân viên", Icons.people_outline, const NhanVienScreen()),
                _buildMenuItem(context, "Ngày làm", Icons.date_range_outlined, const Quanlyngay()),
                _buildMenuItem(context, "Duyệt đơn", Icons.verified_user_outlined, const DuyetDon()),
                _buildMenuItem(context, "Bảng lương", Icons.receipt_long_outlined, const DanhSachNhanVien()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
    );
  }
}