import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'part_time_xacNhanDangKi.dart';

class NhanVienNgayMo extends StatefulWidget {
  final Map user;
  const NhanVienNgayMo({super.key, required this.user});

  @override
  State<NhanVienNgayMo> createState() => _NhanVienNgayMoState();
}

class _NhanVienNgayMoState extends State<NhanVienNgayMo> {
  List lichLamList = [];
  bool isLoading = true;

  // Định nghĩa mã màu chủ đạo
  final Color primaryPink = Colors.pink;
  final Color softPink = const Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    fetchLichLam();
  }

  Future<void> fetchLichLam() async {
    final url = Uri.parse("http://localhost:8000/api/lich-lam");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          lichLamList = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Lỗi API: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Nền màn hình trắng tinh khiết
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Lịch Làm Trống",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        centerTitle: true,
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : lichLamList.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: fetchLichLam,
              color: primaryPink,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: lichLamList.length,
                itemBuilder: (context, index) {
                  final item = lichLamList[index];
                  return _buildLichCard(item);
                },
              ),
            ),
    );
  }

  // Giao diện khi không có dữ liệu
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: softPink),
          const SizedBox(height: 10),
          const Text(
            "Hiện chưa có lịch làm mới",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget thẻ lịch làm được thiết kế lại
  Widget _buildLichCard(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: softPink.withOpacity(0.5), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DangKyCaScreen(lichLam: item, user: widget.user),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon đại diện màu hồng
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: softPink,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: primaryPink,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Thông tin ngày và ca
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['ngay'] ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['ten_ca'] ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.pink.shade300,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Số lượng nhân viên tối đa
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Tối đa",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        Text(
                          "${item['max_nhan_vien']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
