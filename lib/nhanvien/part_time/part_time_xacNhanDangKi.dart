import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DangKyCaScreen extends StatefulWidget {
  final Map lichLam;
  final Map user;

  const DangKyCaScreen({super.key, required this.lichLam, required this.user});

  @override
  State<DangKyCaScreen> createState() => _DangKyCaScreenState();
}

class _DangKyCaScreenState extends State<DangKyCaScreen> {
  bool isLoading = false;
  bool daDangKy = false;
  bool daDay = false;
  bool isLoadingTrangThai = true;
  Future<void> loadTrangThai() async {
    final url = Uri.parse(
      "https://tttn-1-ujfk.onrender.com/api/check-dang-ky"
      "?nhanvien_id=${widget.user['id']}"
      "&lich_lam_id=${widget.lichLam['id']}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          daDangKy = data['da_dang_ky'];
          daDay = data['da_day'];
          isLoadingTrangThai = false;
        });
      }
    } catch (e) {
      print("Lỗi load trạng thái: $e");
    }
  }

  Future<void> dangKyCa() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "https://tttn-1-ujfk.onrender.com/api/dang-ky-ca-part",
    );
    // ⚠️ Android emulator dùng 10.0.2.2

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "nhanvien_id": widget.user['id'], // ✅ lấy từ user
          "lich_lam_id": widget.lichLam['id'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));

        Navigator.pop(context); // quay lại danh sách
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Lỗi")));
      }
    } catch (e) {
      print("Lỗi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không kết nối được server")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> huyDangKyCa() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "https://tttn-1-ujfk.onrender.com/api/huy-dang-ky-ca",
    );

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "nhanvien_id": widget.user['id'],
          "lich_lam_id": widget.lichLam['id'],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Lỗi")));
      }
    } catch (e) {
      print(e);
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    loadTrangThai();
  }

  @override
  Widget build(BuildContext context) {
    // Định nghĩa màu hồng chủ đạo để dễ thay đổi sau này
    const Color primaryPink = Colors.pink;
    const Color lightPink = Color(0xFFFCE4EC); // Colors.pink[50]

    final lich = widget.lichLam;
    final nv = widget.user;

    return Scaffold(
      // 1. Cập nhật nền toàn màn hình màu trắng
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Xác nhận đăng ký",
          // Chữ trên AppBar màu hồng
          style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        // Nền AppBar màu trắng
        backgroundColor: Colors.white,
        // Màu của nút Back (trở về) là màu hồng
        iconTheme: const IconThemeData(color: primaryPink),
        // Thêm một đường kẻ mảnh dưới AppBar để phân chia với body
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // Phần thông tin nhân viên
            Card(
              elevation: 0, // Tắt bóng đổ để hợp với phong cách trắng tối giản
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                // Thêm viền màu hồng nhạt mảnh quanh Card
                side: BorderSide(color: primaryPink.withOpacity(0.2), width: 1),
              ),
              // Nền Card màu hồng cực nhạt hoặc trắng
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Viền hồng đậm quanh Avatar
                        border: Border.all(color: primaryPink, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        // Nền Avatar hồng nhạt
                        backgroundColor: lightPink,
                        // Icon màu hồng đậm
                        child: Icon(Icons.person, size: 45, color: primaryPink),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      nv['ten_nhan_vien'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        // Tên nhân viên màu đen hoặc xám đậm để dễ đọc
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lightPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${nv['chuc_vu'] ?? 'Nhân viên'}",
                        style: const TextStyle(
                          color: primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Phần chi tiết ca làm
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    // Icon màu hồng
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      color: primaryPink,
                    ),
                    title: Text(
                      "Ngày làm việc",
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    subtitle: Text(
                      lich['ngay'] ?? 'Chưa xác định',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey[200],
                  ),
                  ListTile(
                    // Icon màu hồng
                    leading: const Icon(
                      Icons.access_time_rounded,
                      color: Color.fromARGB(255, 233, 30, 99),
                    ),
                    title: Text(
                      "Ca làm",
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    subtitle: Text(
                      lich['ten_ca'] ?? 'Chưa xác định',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Nút xác nhận - Màu Hồng
            const SizedBox(height: 30),

            // 🔥 HIỂN THỊ THEO TRẠNG THÁI
            if (isLoadingTrangThai)
              const Center(child: CircularProgressIndicator())
            else if (daDay)
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "CA ĐÃ ĐỦ NGƯỜI",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else if (daDangKy)
              SizedBox(
                height: 55,
                child: OutlinedButton(
                  onPressed: isLoading ? null : huyDangKyCa,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 233, 30, 99),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.red)
                      : const Text(
                          "HỦY ĐĂNG KÝ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              )
            else
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : dangKyCa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ĐĂNG KÝ CA",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
