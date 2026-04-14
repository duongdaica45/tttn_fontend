import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Donxinnghi extends StatefulWidget {
  final Map user;
  const Donxinnghi({super.key, required this.user});

  @override
  State<Donxinnghi> createState() => _DonxinnghiState();
}

class _DonxinnghiState extends State<Donxinnghi> {
  DateTime? tuNgay;
  DateTime? denNgay;
  TextEditingController lyDoController = TextEditingController();
  List donList = [];
  int soLanNghi = 0;
  bool isLoadingList = true;
  bool isLoading = false;

  // Theme Colors
  final Color primaryPink = Colors.pink;
  final Color softPink = const Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    fetchDon();
  }

  // Giữ nguyên các hàm Logic API của bạn
  Future<void> huyDon(int id) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/huy-don-xin-nghi");

    try {
      final response = await http.post(
        url,

        headers: {
          "Content-Type": "application/json",

          "Accept": "application/json",
        },

        body: jsonEncode({"id": id}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));

        fetchDon(); // 🔥 reload lại danh sách
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Lỗi")));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchDon() async {
    final url = Uri.parse(
      "http://127.0.0.1:8000/api/don-xin-nghi/${widget.user['id']}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          donList = data['data']; // 🔥 QUAN TRỌNG

          soLanNghi = data['tong_so_ngay_nghi']; // 🔥 thêm dòng này

          isLoadingList = false;
        });
      } else {
        setState(() => isLoadingList = false);
      }
    } catch (e) {
      print("Lỗi API: $e");

      setState(() => isLoadingList = false);
    }
  }

  Future<void> taoDon() async {
    if (tuNgay == null || denNgay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn đầy đủ ngày")),
      );

      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("http://127.0.0.1:8000/api/don-xin-nghi");

    try {
      final response = await http.post(
        url,

        headers: {
          "Content-Type": "application/json",

          "Accept": "application/json",
        },

        body: jsonEncode({
          "nhan_vien_id": widget.user['id'],

          "tu_ngay": tuNgay.toString().split(" ")[0],

          "den_ngay": denNgay.toString().split(" ")[0],

          "ly_do": lyDoController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));

        // 🔥 RESET FORM

        setState(() {
          tuNgay = null;

          denNgay = null;

          lyDoController.clear();
        });

        // 🔥 LOAD LẠI DANH SÁCH

        fetchDon();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Lỗi")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi kết nối server")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Đơn Xin Nghỉ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Phần Form tạo đơn (Nằm trong một Container màu hồng nhạt để phân biệt)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: softPink.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDateTile("Từ ngày", tuNgay, true)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildDateTile("Đến ngày", denNgay, false)),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: lyDoController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Lý do xin nghỉ",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: primaryPink),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : taoDon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "GỬI ĐƠN NGAY",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Thống kê số lần nghỉ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryPink.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics_outlined, color: primaryPink),
                  const SizedBox(width: 10),
                  const Text(
                    "Thống kê tháng này:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    "$soLanNghi / 3 lần",
                    style: TextStyle(
                      color: primaryPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lịch sử gửi đơn",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Danh sách đơn
          Expanded(
            child: isLoadingList
                ? Center(child: CircularProgressIndicator(color: primaryPink))
                : donList.isEmpty
                ? const Center(child: Text("Chưa có đơn nghỉ nào"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: donList.length,
                    itemBuilder: (context, index) {
                      final item = donList[index];
                      return _buildHistoryCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget chọn ngày kiểu Box
  Widget _buildDateTile(String label, DateTime? date, bool isStart) {
    return GestureDetector(
      onTap: () => pickDate(isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null ? "Chọn ngày" : date.toString().split(" ")[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_month, size: 18, color: primaryPink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card lịch sử được thiết kế lại
  Widget _buildHistoryCard(Map item) {
    Color statusColor = getColor(item['trang_thai']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          "${item['tu_ngay']} → ${item['den_ngay']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              "Lý do: ${item['ly_do'] ?? '...'}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item['ghi_chu_admin'] != null)
              Text(
                "Admin: ${item['ghi_chu_admin']}",
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.5)),
          ),
          child: Text(
            getText(item['trang_thai']),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => confirmDelete(item),
      ),
    );
  }

  // --- Giữ nguyên hàm pickDate và confirmDelete của bạn ở dưới ---
  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(), // ❌ không cho chọn quá khứ

      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          tuNgay = picked;
        } else {
          denNgay = picked;
        }
      });
    }
  }

  void confirmDelete(Map item) {
    if (item['trang_thai'] != 'cho_duyet') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chỉ được hủy đơn đang chờ duyệt")),
      );

      return;
    }

    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),

        content: const Text("Bạn có chắc muốn hủy đơn này không?"),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text("Không"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              huyDon(item['id']); // 🔥 gọi API
            },

            child: const Text("Đồng ý"),
          ),
        ],
      ),
    );
  }
}

// Hàm bổ trợ màu sắc (nên cập nhật cho tông Pastel)
Color getColor(String status) {
  switch (status) {
    case 'cho_duyet':
      return Colors.orange;
    case 'chap_nhan':
      return Colors.green;
    case 'tu_choi':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String getText(String status) {
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
