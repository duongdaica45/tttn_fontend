import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_xacNhanDonXinNghi.dart';

class DuyetDon extends StatelessWidget {
  const DuyetDon({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List donList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDon();
  }

  Future<void> fetchDon() async {
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/don-cho-duyet");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          donList = data['data'];
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

  // Cải thiện màu sắc trạng thái cho dịu nhẹ hơn phù hợp tông hồng
  Color getStatusColor(String status) {
    switch (status) {
      case 'cho_duyet':
        return Colors.orangeAccent;
      case 'chap_nhan':
        return Colors.green.shade400;
      case 'tu_choi':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'cho_duyet':
        return "Chờ duyệt";
      case 'chap_nhan':
        return "Đã duyệt";
      case 'tu_choi':
        return "Từ chối";
      default:
        return "Không rõ";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFC), // Trắng hồng cực nhẹ
      appBar: AppBar(
        title: const Text(
          "Duyệt Đơn Xin Nghỉ",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 233, 30, 99),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: fetchDon, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : donList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: donList.length,
              itemBuilder: (context, index) {
                final item = donList[index];
                return _buildDonCard(item);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_motion,
            size: 80,
            color: Colors.pink.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            "Hiện không có đơn nào cần duyệt",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDonCard(Map item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChiTietDuyetDonScreen(don: item),
                ),
              ).then((_) => fetchDon()); // Reload sau khi quay lại
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.pink.shade50,
                            child: const Icon(Icons.person, color: Colors.pink),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['ten_nhan_vien'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                item['chuc_vu'],
                                style: TextStyle(
                                  color: Colors.pink.shade300,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildStatusBadge(item['trang_thai']),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    "Thời gian:",
                    "${item['tu_ngay']} → ${item['den_ngay']}",
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.chat_bubble_outline_rounded,
                    "Lý do:",
                    item['ly_do'],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Xem chi tiết >",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: getStatusColor(status).withOpacity(0.5)),
      ),
      child: Text(
        getStatusText(status),
        style: TextStyle(
          color: getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
