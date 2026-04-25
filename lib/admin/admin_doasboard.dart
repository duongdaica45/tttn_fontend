import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // thêm thư viện biểu đồ

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
  int pageSize = 5;

  final Color primaryColor = Colors.indigo;
  final Color softColor = const Color(0xFFE8EAF6);

  bool isLoading = false;
  List data = [];
  final String baseUrl = "https://tttn-1-ujfk.onrender.com/api";

  // ================= TỔNG HỢP SỐ LIỆU =================
  double get tongLuong => data.fold(
    0,
    (sum, item) => sum + (double.tryParse(item['luong'].toString()) ?? 0),
  );
  double get tongGio => data.fold(
    0,
    (sum, item) => sum + (double.tryParse(item['so_gio'].toString()) ?? 0),
  );
  int get soNgayCong => data.length;
  double get trungBinhGio => soNgayCong > 0 ? tongGio / soNgayCong : 0;

  List get paginatedData {
    int start = currentPage * pageSize;
    int end = start + pageSize;
    if (end > data.length) end = data.length;
    return data.sublist(start, end);
  }

  // ================= DỮ LIỆU CHO BIỂU ĐỒ =================
  List<Map<String, dynamic>> get _dailyEarnings {
    List<Map<String, dynamic>> list = [];
    for (var item in data) {
      String ngayStr = item['ngay'];
      double luong = double.tryParse(item['luong'].toString()) ?? 0;
      double gio = double.tryParse(item['so_gio'].toString()) ?? 0;
      // Lấy ngày trong tháng (giả sử định dạng dd/MM/yyyy hoặc yyyy-MM-dd)
      int day = _extractDay(ngayStr);
      list.add({'day': day, 'luong': luong, 'gio': gio, 'rawDate': ngayStr});
    }
    // Sắp xếp theo ngày tăng dần
    list.sort((a, b) => a['day'].compareTo(b['day']));
    return list;
  }

  int _extractDay(String dateStr) {
    try {
      // Xử lý định dạng dd/MM/yyyy
      if (dateStr.contains('/')) {
        return int.parse(dateStr.split('/')[0]);
      }
      // Xử lý định dạng yyyy-MM-dd
      else if (dateStr.contains('-')) {
        return DateTime.parse(dateStr).day;
      }
    } catch (e) {
      return 1;
    }
    return 1;
  }

  // ================= TẢI DỮ LIỆU =================
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
    loadData();
  }

  final currencyFormat = NumberFormat("#,###", "vi_VN");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          "Dashboard Thu Nhập",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : data.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⭐ BIỂU ĐỒ DASHBOARD ⭐
                        _buildChartCard(),
                        const SizedBox(height: 20),
                        const Text(
                          "Chi tiết chấm công",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paginatedData.length,
                          itemBuilder: (context, index) {
                            return _buildPayrollCard(paginatedData[index]);
                          },
                        ),

                        _buildPagination(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20, top: 10),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  "${widget.user['ten_nhan_vien']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: pickMonthYear,
                icon: const Icon(Icons.calendar_today, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Tháng $thang năm $nam",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BIỂU ĐỒ CỘT THU NHẬP THEO NGÀY =================
  Widget _buildChartCard() {
    final dailyData = _dailyEarnings;
    if (dailyData.isEmpty) return const SizedBox.shrink();

    // Tìm max lương để set khoảng trục Y
    double maxLuong = dailyData.fold(
      0.0,
      (max, item) => item['luong'] > max ? item['luong'] : max,
    );
    maxLuong = (maxLuong * 1.1).ceilToDouble(); // thêm khoảng cách phía trên

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Biểu đồ thu nhập theo ngày",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: (dailyData.length * 50)
                      .toDouble(), // mỗi cột rộng ~50px
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxLuong,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < dailyData.length) {
                                int dayNumber = dailyData[index]['day'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "$dayNumber",
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                );
                              }
                              return const Text("");
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                currencyFormat.format(value),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxLuong / 4,
                      ),
                      barGroups: List.generate(dailyData.length, (i) {
                        final item = dailyData[i];
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: item['luong'],
                              color: primaryColor,
                              width: 20,
                              borderRadius: BorderRadius.circular(6),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 0,
                                color: softColor,
                              ),
                            ),
                          ],
                          showingTooltipIndicators: [],
                        );
                      }),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final item = dailyData[group.x];
                            return BarTooltipItem(
                              "Ngày ${item['day']}\n${currencyFormat.format(item['luong'])}đ",
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Tổng thu nhập tháng: ${currencyFormat.format(tongLuong)}đ",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ================= THỐNG KÊ DẠNG GRID =================

  // ================= THẺ CHI TIẾT CHẤM CÔNG =================
  Widget _buildPayrollCard(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: softColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: softColor, shape: BoxShape.circle),
          child: Icon(Icons.calendar_month, color: primaryColor, size: 20),
        ),
        title: Text(
          "Ngày ${item['ngay']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${item['so_gio']} giờ làm việc"),
        trailing: Text(
          "+${currencyFormat.format(double.tryParse(item['luong'].toString()) ?? 0)}đ",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
          Text(
            "Không có dữ liệu tháng $thang/$nam",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    int totalPages = (data.length / pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageButton(
            icon: Icons.chevron_left,
            enabled: currentPage > 0,
            onTap: () => setState(() => currentPage--),
          ),
          const SizedBox(width: 20),
          Text(
            "Trang ${currentPage + 1} / $totalPages",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          _pageButton(
            icon: Icons.chevron_right,
            enabled: (currentPage + 1) * pageSize < data.length,
            onTap: () => setState(() => currentPage++),
          ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled ? primaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Future<void> pickMonthYear() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(nam, thang),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        thang = picked.month;
        nam = picked.year;
      });
      loadData();
    }
  }
}
