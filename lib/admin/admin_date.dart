import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_taocalam.dart';

class Quanlyngay extends StatefulWidget {
  const Quanlyngay({super.key});

  @override
  State<Quanlyngay> createState() => _QuanLyNgay();
}

class _QuanLyNgay extends State<Quanlyngay> {
  List<dynamic> danhSachNgay = [];
  bool isLoading = true; // Thêm biến để quản lý trạng thái tải dữ liệu
  final String baseUrl = "https://tttn-1-ujfk.onrender.com/api";

  @override
  void initState() {
    super.initState();
    fetchNextWeek();
  }

  Future<void> fetchNextWeek() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/next-week"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ngay": "2026-04-12"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          danhSachNgay = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Lỗi kết nối: $e");
    }
  }

  Future<void> toggleNgay(String ngay, bool value, int index) async {
    final response = await http.post(
      Uri.parse("$baseUrl/toggle-ngay"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"ngay": ngay, "mo_tao_ca": value}),
    );

    if (response.statusCode == 200) {
      setState(() {
        danhSachNgay[index]["mo_tao_ca"] = value;
      });
      // Hiển thị thông báo nhẹ nhàng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${value ? 'Đã mở' : 'Đã đóng'} tạo ca cho ngày $ngay"),
          backgroundColor: Colors.pink[300],
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50]?.withOpacity(0.3), // Nền hồng trắng nhạt
      appBar: AppBar(
        title: const Text(
          "Quản lý ngày",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      // Nút nổi nhấn mạnh việc Tạo Ca
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("TẠO CA MỚI"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaoCaScreen()),
          );
        },
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : Column(
              children: [
                // Header trang trí
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.pink,
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white70),
                      SizedBox(width: 10),
                      Text(
                        "Lịch trình tuần tới",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 80),
                    itemCount: danhSachNgay.length,
                    itemBuilder: (context, index) {
                      var item = danhSachNgay[index];
                      bool isOpen = item["mo_tao_ca"] ?? false;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isOpen
                                ? Colors.pink[100]
                                : Colors.grey[200],
                            child: Icon(
                              Icons.event,
                              color: isOpen ? Colors.pink : Colors.grey,
                            ),
                          ),
                          title: Text(
                            item["ngay"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            item["thu"],
                            style: TextStyle(color: Colors.pink[300]),
                          ),
                          trailing: Switch(
                            activeColor: Colors.pink,
                            activeTrackColor: Colors.pink[100],
                            value: isOpen,
                            onChanged: (value) {
                              toggleNgay(item["ngay"], value, index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
