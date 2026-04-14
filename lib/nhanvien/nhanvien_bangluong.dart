import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class BangLuongPage extends StatefulWidget {
  final Map user;
  const BangLuongPage({super.key, required this.user});

  @override
  State<BangLuongPage> createState() => _BangLuongPageState();
}

class _BangLuongPageState extends State<BangLuongPage> {
  int thang = DateTime.now().month;
  int nam = DateTime.now().year;
  final _formKey = GlobalKey<FormState>();
  int currentPage = 0;
  int pageSize = 10;

  // Màu sắc chủ đạo
  final Color primaryPink = Colors.pink;
  final Color softPink = const Color(0xFFFCE4EC);

  List get paginatedData {
    int start = currentPage * pageSize;
    int end = start + pageSize;
    if (end > data.length) end = data.length;
    return data.sublist(start, end);
  }

  TextEditingController namController = TextEditingController();
  bool isLoading = false;
  List data = [];
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/lich-su-cham-cong?nhanvien_id=${widget.user['id']}&thang=$thang&nam=$nam",
        ),
      );
      final result = jsonDecode(response.body);
      setState(() {
        data = result['data'] ?? [];
        currentPage = 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    namController.text = nam.toString();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Lịch Sử Chấm Công",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 👤 Phần thông tin nhân viên (Header)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryPink,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Text(
                  "Nhân viên: ${widget.user['ten_nhan_vien']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // 📅 Form chọn tháng năm
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: thang,
                          decoration: _inputDecoration("Tháng"),
                          items: List.generate(12, (i) => i + 1)
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text("Tháng $m"),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => thang = value!);
                            loadData();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: namController,
                          decoration: _inputDecoration("Năm"),
                          keyboardType: TextInputType.number,
                          validator: validateNam,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onFieldSubmitted: (v) => loadData(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isLoading) CircularProgressIndicator(color: primaryPink),

          if (!isLoading && data.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "Không có dữ liệu tháng $thang/$nam",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),

          if (data.isNotEmpty)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: paginatedData.length,
                      itemBuilder: (context, index) {
                        var item = paginatedData[index];
                        return _buildPayrollCard(item);
                      },
                    ),
                  ),

                  // 🔥 Pagination controls (Phân trang)
                  _buildPagination(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget: Thẻ hiển thị từng dòng lương
  Widget _buildPayrollCard(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryPink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: softPink),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: softPink, shape: BoxShape.circle),
          child: Icon(Icons.date_range, color: primaryPink),
        ),
        title: Text(
          "Ngày: ${item['ngay']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Số giờ làm: ${item['so_gio']}h",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Text(
          "+${item['luong']} đ",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Widget: Điều hướng phân trang
  Widget _buildPagination() {
    int totalPages = (data.length / pageSize).ceil();
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageButton(
            Icons.chevron_left,
            currentPage > 0 ? () => setState(() => currentPage--) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Trang ${currentPage + 1} / $totalPages",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _pageButton(
            Icons.chevron_right,
            (currentPage + 1) * pageSize < data.length
                ? () => setState(() => currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _pageButton(IconData icon, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onPressed == null ? Colors.grey.shade200 : primaryPink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryPink),
      filled: true,
      fillColor: softPink.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryPink),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    );
  }
}

// Validator (giữ nguyên logic)
String? validateNam(String? value) {
  if (value == null || value.isEmpty) return "Nhập năm";
  int? n = int.tryParse(value);
  if (n == null) return "Phải là số";
  int currentYear = DateTime.now().year;
  if (n < 2015 || n > currentYear) return "Từ 2015-$currentYear";
  return null;
}
