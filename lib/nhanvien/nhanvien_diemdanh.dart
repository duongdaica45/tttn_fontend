import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Diemdanh extends StatefulWidget {
  final Map user;

  const Diemdanh({super.key, required this.user});

  @override
  State<Diemdanh> createState() => _DiemdanhState();
}

class _DiemdanhState extends State<Diemdanh> {
  String message = "";
  bool isLoading = false;
  //final String baseUrl = "http://localhost:8000/api";
  final String baseUrl = "https://tttn-1-ujfk.onrender.com/api";
  final Color primaryPink = Colors.indigo;
  final Color softPink = const Color(0xFFE8EAF6);

  // =====================
  // CỬA SỔ XÁC NHẬN
  // =====================
  void _showConfirmDialog(String type, Function onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Xác nhận $type",
          style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold),
        ),
        content: Text("Bạn có chắc chắn muốn thực hiện $type ngay bây giờ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // API Check-in/Out giữ nguyên logic, chỉ cập nhật message
  Future<void> checkIn() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/check-in"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nhanvien_id": widget.user['id']}),
      );
      final data = jsonDecode(response.body);
      setState(() => message = data['message']);
    } catch (e) {
      setState(() => message = "Lỗi kết nối");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> checkOut() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/check-out"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nhanvien_id": widget.user['id']}),
      );
      final data = jsonDecode(response.body);
      setState(() {
        message =
            data['message'] +
            (data['so_gio'] != null ? " (${data['so_gio']} giờ)" : "");
      });
    } catch (e) {
      setState(() => message = "Lỗi kết nối");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Điểm Danh",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header trang trí
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: primaryPink,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: primaryPink),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Text(
                    "Xin chào, ${widget.user['ten_nhan_vien']}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryPink,
                    ),
                  ),
                  const Text(
                    "Chúc bạn một ngày làm việc vui vẻ!",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 40),

                  // Nút Check-in
                  _buildActionButton(
                    title: "BẮT ĐẦU CA (CHECK-IN)",
                    icon: Icons.login_rounded,
                    color: const Color(0xFF7986CB ),
                    onTap: () => _showConfirmDialog("Check-in", checkIn),
                  ),

                  const SizedBox(height: 20),

                  // Nút Check-out
                  _buildActionButton(
                    title: "KẾT THÚC CA (CHECK-OUT)",
                    icon: Icons.logout_rounded,
                    color: const Color(0xFFE8EAF6),
                    onTap: () => _showConfirmDialog("Check-out", checkOut),
                  ),

                  const SizedBox(height: 40),

                  if (isLoading)
                    CircularProgressIndicator(color: primaryPink)
                  else if (message.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: softPink,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryPink.withOpacity(0.3)),
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryPink,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget dùng chung cho 2 nút bấm
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: Icon(icon, size: 28),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
