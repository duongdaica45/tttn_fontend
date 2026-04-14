import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_duyetdon.dart';

class ChiTietDuyetDonScreen extends StatefulWidget {
  final Map don;

  const ChiTietDuyetDonScreen({super.key, required this.don});

  @override
  State<ChiTietDuyetDonScreen> createState() => _ChiTietDuyetDonScreenState();
}

class _ChiTietDuyetDonScreenState extends State<ChiTietDuyetDonScreen> {
  TextEditingController ghiChuController = TextEditingController();
  bool isLoading = false;

  Future<void> xuLyDon(String trangThai) async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/duyet-don-xin-nghi");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "id": widget.don['id'],
          "trang_thai": trangThai,
          "ghi_chu_admin": ghiChuController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.pink,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DuyetDon()),
          );
        }
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.don;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền xám cực nhẹ để nổi bật Card trắng
      appBar: AppBar(
        title: const Text(
          "Chi tiết Duyệt đơn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- CARD THÔNG TIN ---
            Card(
              elevation: 2,
              shadowColor: Colors.pink.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment_ind, color: Colors.pink),
                        const SizedBox(width: 10),
                        Text(
                          "THÔNG TIN NHÂN VIÊN",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[700],
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildInfoItem(
                      Icons.person_outline,
                      "Họ tên",
                      item['ten_nhan_vien'],
                    ),
                    _buildInfoItem(
                      Icons.badge_outlined,
                      "Chức vụ",
                      item['chuc_vu'],
                    ),
                    _buildInfoItem(
                      Icons.calendar_month_outlined,
                      "Thời gian",
                      "${item['tu_ngay']} → ${item['den_ngay']}",
                    ),
                    _buildInfoItem(
                      Icons.chat_bubble_outline,
                      "Lý do xin nghỉ",
                      item['ly_do'],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- Ô NHẬP GHI CHÚ ---
            TextField(
              controller: ghiChuController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Ghi chú của Admin",
                labelStyle: const TextStyle(color: Colors.pink),
                hintText: "Nhập nội dung phản hồi...",
                filled: true,
                fillColor: Colors.white,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.pink[100]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.pink[100]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- HÀNG NÚT BẤM ---
            isLoading
                ? const CircularProgressIndicator(color: Colors.pink)
                : Row(
                    children: [
                      // Nút Từ chối

                      // Nút Duyệt
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => xuLyDon("chap_nhan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "DUYỆT ĐƠN",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => xuLyDon("tu_choi"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "TỪ CHỐI",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // Widget con để tạo dòng thông tin
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Text(
                  value ?? "Chưa cập nhật",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
