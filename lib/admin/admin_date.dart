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
  bool isNextWeek = true;
  List<dynamic> danhSachNgay = [];
  bool isLoading = true;

  // Bạn có thể đổi sang IP máy của mình nếu chạy trên thiết bị thật

  final String baseUrl = "https://tttn-1-ujfk.onrender.com/api";

  //final String baseUrl = "http://localhost:8000/api";
  final Color primaryPink = Colors.indigo;
  final Color softPink = const Color(0xFF7986CB);

  // ======================
  // GỌI API & LÀM MỚI
  // ======================
  Future<void> fetchWeek() async {
    try {
      // Khi dùng RefreshIndicator, chúng ta không set isLoading = true
      // để tránh hiện 2 vòng xoay cùng lúc
      String today = DateTime.now().toString().split(' ')[0];
      String url = isNextWeek ? "$baseUrl/next-week" : "$baseUrl/current-week";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"ngay": today}),
      );

      if (response.statusCode == 200) {
        setState(() {
          danhSachNgay = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Lỗi: $e");
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${value ? 'Đã mở' : 'Đã đóng'} tạo ca ngày $ngay"),
          backgroundColor: primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Quản Lý Ngày",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          // Nút chuyển tuần nhanh trên AppBar
          IconButton(
            icon: const Icon(Icons.swap_calls),
            onPressed: () {
              setState(() => isNextWeek = !isNextWeek);
              fetchWeek();
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("TẠO CA MỚI"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaoCaScreen()),
          );
        },
      ),

      body: Column(
        children: [
          // Header hiển thị thông tin tuần
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: primaryPink,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNextWeek ? "LỊCH TRÌNH TUẦN TỚI" : "LỊCH TUẦN HIỆN TẠI",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFCE4EC),
                          foregroundColor: Colors.black,
                        ),
                        icon: Icon(Icons.swap_horiz),
                        label: Text(
                          isNextWeek ? "Xem tuần hiện tại" : "Xem tuần tới",
                        ),
                        onPressed: () {
                          setState(() {
                            isNextWeek = !isNextWeek;
                          });

                          fetchWeek(); // 🔥 reload lại
                        },
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white24,
                  size: 40,
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryPink))
                : RefreshIndicator(
                    color: primaryPink,
                    onRefresh: fetchWeek, // 🔥 Tính năng kéo để làm mới
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
                      itemCount: danhSachNgay.length,
                      itemBuilder: (context, index) {
                        var item = danhSachNgay[index];
                        bool isOpen = item["mo_tao_ca"] ?? false;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isOpen
                                  ? primaryPink.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isOpen ? softPink : Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event_available,
                                color: isOpen ? primaryPink : Colors.grey,
                              ),
                            ),
                            title: Text(
                              item["ngay"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            subtitle: Text(
                              item["thu"],
                              style: TextStyle(
                                color: primaryPink.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Switch(
                              activeColor: primaryPink,
                              value: isOpen,
                              onChanged: (value) =>
                                  toggleNgay(item["ngay"], value, index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
