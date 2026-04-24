import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CaTrongTuanPage extends StatefulWidget {
  final Map user;

  const CaTrongTuanPage({super.key, required this.user});

  @override
  State<CaTrongTuanPage> createState() => _CaTrongTuanPageState();
}

class _CaTrongTuanPageState extends State<CaTrongTuanPage> {
  bool isLoading = false;
  List tuanNay = [];
  List tuanSau = [];
  
  //final String baseUrl = "http://127.0.0.1:8000/api";
  final String baseUrl = "https://tttn-1-ujfk.onrender.com/api";
  // Hệ màu chủ đạo
  final Color primaryPink = Colors.indigo;
  final Color softPink = const Color(0xFFE8EAF6);

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/ca-trong-tuan?nhanvien_id=${widget.user['id']}"),
      );
      final result = jsonDecode(response.body);

      setState(() {
        List allData = result['data'] ?? [];

        // Logic lọc tuần (Giữ nguyên logic của bạn)
        tuanNay = _filterByDate(
          allData,
          result['tuan_nay']['tu'],
          result['tuan_nay']['den'],
        );
        tuanSau = _filterByDate(
          allData,
          result['tuan_sau']['tu'],
          result['tuan_sau']['den'],
        );

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List _filterByDate(List data, String from, String to) {
    DateTime tu = DateTime.parse(from);
    DateTime den = DateTime.parse(to);
    return data.where((item) {
      DateTime ngay = DateTime.parse(item['ngay']);
      return ngay.isAfter(tu.subtract(const Duration(days: 1))) &&
          ngay.isBefore(den.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Widget build danh sách ca làm việc cải tiến
  Widget buildList(String title, List data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryPink,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 20),
            child: Text(
              "Không có ca làm việc",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ...data.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryPink.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: softPink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: primaryPink,
                  size: 22,
                ),
              ),
              title: Text(
                item['ngay'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text("Ca làm việc trong ngày"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['ten_ca'] ?? item['ca_lam_id'].toString() ?? '---',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Lịch Làm Trong Tuần",
          style: TextStyle(fontWeight: FontWeight.bold),
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
          ? Center(child: CircularProgressIndicator(color: primaryPink))
          : RefreshIndicator(
              color: primaryPink,
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner chào hỏi nhân viên
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: softPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            color: primaryPink,
                            size: 30,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Xin chào,",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  widget.user['ten_nhan_vien'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    buildList("Tuần này", tuanNay),
                    const SizedBox(height: 10),
                    buildList("Tuần sau", tuanSau),
                  ],
                ),
              ),
            ),
    );
  }
}
