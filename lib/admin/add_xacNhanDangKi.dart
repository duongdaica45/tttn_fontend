import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class XacNhanDangKyScreen extends StatefulWidget {
  final Map lichLam;
  final Map nhanVien;

  const XacNhanDangKyScreen({
    super.key,
    required this.lichLam,
    required this.nhanVien,
  });

  @override
  State<XacNhanDangKyScreen> createState() => _XacNhanDangKyScreenState();
}

class _XacNhanDangKyScreenState extends State<XacNhanDangKyScreen> {
  bool isLoading = false;
  bool daDangKy = false;
  bool daDay = false;
  bool isLoadingTrangThai = true;

  // --- Theme Colors ---
  static const Color primaryPink = Colors.indigo;
  static const Color accentPink = Color(0xFF7986CB);
  static const Color softPink = Color(0xFFFFF1F4); // Hồng trắng cực nhẹ cho nền

  @override
  void initState() {
    super.initState();
    loadTrangThai();
  }

  Future<void> loadTrangThai() async {
    final url = Uri.parse(
      "https://tttn-1-ujfk.onrender.com/api/check-dang-ky"
      "?nhanvien_id=${widget.nhanVien['id']}"
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
      debugPrint("Lỗi load trạng thái: $e");
    }
  }

  Future<void> handleAction(String type) async {
    setState(() => isLoading = true);
    final endpoint = type == "dangky" ? "dang-ky-ca" : "huy-dang-ky-ca";
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nhanvien_id": widget.nhanVien['id'],
          "lich_lam_id": widget.lichLam['id'],
        }),
      );

      final data = jsonDecode(response.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Thành công"),
            backgroundColor: type == "dangky" ? Colors.indigo : Colors.redAccent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Xác Nhận Đăng Ký",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoadingTrangThai
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header trang trí
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Card Nhân Viên
                          _buildMainCard(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: softPink,
                                  child: const Icon(
                                    Icons.person,
                                    size: 55,
                                    color: primaryPink,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  widget.nhanVien['ten_nhan_vien'] ??
                                      'Nhân viên',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: softPink,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.nhanVien['chuc_vu'] ?? 'Vị trí',
                                    style: const TextStyle(
                                      color: primaryPink,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Card Thông tin ca làm
                          _buildMainCard(
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  Icons.calendar_today_rounded,
                                  "Ngày làm",
                                  widget.lichLam['ngay'],
                                ),
                                const Divider(height: 30),
                                _buildInfoRow(
                                  Icons.access_time_filled_rounded,
                                  "Ca làm việc",
                                  widget.lichLam['ten_ca'],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Phần Button Logic
                          _buildActionButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMainCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: accentPink, size: 28),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (daDay && !daDangKy) {
      return _largeButton(
        label: "CA ĐÃ ĐỦ NGƯỜI",
        color: Colors.grey[400]!,
        onPressed: null,
      );
    }

    if (daDangKy) {
      return _largeButton(
        label: "HỦY ĐĂNG KÝ CA",
        color: Colors.redAccent,
        onPressed: () => handleAction("huy"),
        isOutlined: true,
      );
    }

    return _largeButton(
      label: "XÁC NHẬN ĐĂNG KÝ",
      color: primaryPink,
      onPressed: () => handleAction("dangky"),
    );
  }

  Widget _largeButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 5,
                shadowColor: color.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
    );
  }
}
