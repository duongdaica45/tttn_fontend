import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_doasboard.dart';
class DanhSachNhanVien extends StatefulWidget {
  const DanhSachNhanVien({super.key});

  @override
  State<DanhSachNhanVien> createState() => _NhanVienScreenState();
}

class _NhanVienScreenState extends State<DanhSachNhanVien> {
  List nhanVienList = [];
  bool isLoading = true;

  // Hệ màu chủ đạo
  final Color primaryPink = const Color(0xFF7986CB);
  final Color lightPinkBg = const Color(0xFFE8EAF6);

  @override
  void initState() {
    super.initState();
    fetchNhanVien();
  }

  Future<void> fetchNhanVien() async {
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/nhanvien");
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        List all = data['data'];
        List filtered = all
            .where((nv) => nv['chuc_vu'] == 'Full' || nv['chuc_vu'] == 'Part')
            .toList();

        setState(() {
          nhanVienList = filtered;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPinkBg,
      appBar: AppBar(
        title: const Text(
          "Quản Lý Nhân Viên",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPink))
          : RefreshIndicator(
              color: primaryPink,
              onRefresh: fetchNhanVien, // Tính năng vuốt để làm mới
              child: nhanVienList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: nhanVienList.length,
                      itemBuilder: (context, index) {
                        final nv = nhanVienList[index];
                        return _buildNhanVienCard(nv);
                      },
                    ),
            ),
    );
  }

  Widget _buildNhanVienCard(Map nv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPink.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BangLuongPage(user: nv)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar nhân viên
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryPink.withOpacity(0.1),
                      child: Icon(Icons.person, color: primaryPink, size: 30),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          nv['chuc_vu'] == 'Full'
                              ? Icons.flash_on
                              : Icons.timer,
                          size: 12,
                          color: primaryPink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Thông tin chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            nv['ten_nhan_vien'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          _buildBadge(nv['chuc_vu']),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        Icons.email_outlined,
                        nv['email'] ?? "Chưa cập nhật",
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.phone_android_outlined,
                        nv['so_dien_thoai'] ?? "N/A",
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: primaryPink.withOpacity(0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String role) {
    bool isFull = role == 'Full';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFull ? primaryPink : primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: isFull ? Colors.white : primaryPink,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: primaryPink.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              "Không tìm thấy nhân viên",
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              "Vuốt xuống để làm mới",
              style: TextStyle(
                color: primaryPink.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
