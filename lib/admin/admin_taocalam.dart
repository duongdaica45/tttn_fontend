import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'admin_dangki.dart';

class TaoCaScreen extends StatefulWidget {
  const TaoCaScreen({super.key});

  @override
  State<TaoCaScreen> createState() => _TaoCaScreenState();
}

class _TaoCaScreenState extends State<TaoCaScreen> {
  final TextEditingController ngayController = TextEditingController();
  final TextEditingController caLamIdController = TextEditingController();
  final TextEditingController maxNhanVienController = TextEditingController();
  int selectedCaLam = 1;

  bool isLoading = false;
  List<String> danhSachNgayMo = [];
  bool isLoadingNgay = true;
  List lichLamList = [];
  bool isLoadingList = true;

  @override
  void initState() {
    super.initState();
    loadNgayMo();
    loadLichLam();
    caLamIdController.text = "1";
  }

  // --- API LOGIC (Giữ nguyên logic của bạn, chỉ thêm loading states) ---
  Future<void> deleteLichLam(int id) async {
    final response = await http.delete(
      Uri.parse("https://tttn-1-ujfk.onrender.com/api/lich-lam/$id"),
      headers: {"Accept": "application/json"},
    );

    final data = json.decode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));
  }

  Future<void> loadLichLam() async {
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/lich-lam");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        DateTime start = startOfWeek;
        DateTime end = endOfNextWeek;

        List filtered = data.where((item) {
          if (item['ngay'] == null) return false;

          DateTime ngay = DateTime.parse(item['ngay']);

          return ngay.isAfter(start.subtract(const Duration(days: 1))) &&
              ngay.isBefore(end.add(const Duration(days: 1)));
        }).toList();

        // 👉 Sắp xếp theo ngày (rất nên có)
        filtered.sort(
          (a, b) =>
              DateTime.parse(a['ngay']).compareTo(DateTime.parse(b['ngay'])),
        );

        setState(() {
          lichLamList = filtered;
          isLoadingList = false;
        });
      }
    } catch (e) {
      print("Lỗi load lịch: $e");
    }
  }

  Future<void> loadNgayMo() async {
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/ngay-mo");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<String> temp = List<String>.from(jsonDecode(response.body));
        temp.sort();
        setState(() {
          danhSachNgayMo = temp;
          isLoadingNgay = false;
        });
      }
    } catch (e) {
      print("Lỗi load ngày: $e");
    }
  }

  Future<void> taoCa() async {
    if (ngayController.text.isEmpty || maxNhanVienController.text.isEmpty) {
      _showSnackBar("Vui lòng nhập đủ thông tin", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/lich-lam");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ngay": ngayController.text,
          "ca_lam_id": selectedCaLam,
          "max_nhan_vien": int.parse(maxNhanVienController.text),
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar("✅ Tạo ca thành công", Colors.indigo);

        // 🔥 RESET TOÀN BỘ TRANG
        setState(() {
          ngayController.clear();
          maxNhanVienController.clear();
          selectedCaLam = 1;

          lichLamList = [];
          isLoadingList = true;
        });

        // reload lại dữ liệu
        await loadLichLam();
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(" ${data['message']}", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối", Colors.redAccent);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> pickDate() async {
    if (danhSachNgayMo.isEmpty) return;
    DateTime firstDate = DateTime.parse(danhSachNgayMo.first);
    DateTime lastDate = DateTime.parse(danhSachNgayMo.last);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (day) =>
          danhSachNgayMo.contains(day.toIso8601String().split('T')[0]),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.indigo),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(
        () => ngayController.text = picked.toIso8601String().split('T')[0],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tạo Lịch Làm Việc",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- PHẦN FORM NHẬP ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Ô Chọn Ngày
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: isLoadingNgay ? null : pickDate,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.indigo.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.indigo,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                ngayController.text.isEmpty
                                    ? "Chọn ngày"
                                    : ngayController.text,
                                style: TextStyle(
                                  color: ngayController.text.isEmpty
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Dropdown Ca làm
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.indigo.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedCaLam,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text("Ca sáng"),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text("Ca chiều"),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => selectedCaLam = value!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Nhập số nhân viên
                TextField(
                  controller: maxNhanVienController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Số nhân viên tối đa",
                    prefixIcon: const Icon(Icons.people, color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.indigo.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Nút Tạo Ca
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : taoCa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "TẠO CA LÀM MỚI",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // --- PHẦN DANH SÁCH ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(width: 4, height: 20, color: Colors.indigo),
                const SizedBox(width: 10),
                const Text(
                  "DANH SÁCH LỊCH ĐÃ TẠO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoadingList
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.indigo),
                  )
                : lichLamList.isEmpty
                ? const Center(child: Text("Chưa có lịch làm"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lichLamList.length,
                    itemBuilder: (context, index) {
                      final item = lichLamList[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.indigo.withOpacity(0.1)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo[50],
                            child: const Icon(
                              Icons.access_time_filled,
                              color: Colors.indigo,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item['ngay'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            item['ten_ca'],
                            style: TextStyle(color: Colors.indigo[300]),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Tối đa: ${item['max_nhan_vien']}",
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // 👇 CLICK thường
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DanhSachNhanVienFullScreen(lichLam: item),
                              ),
                            );
                          },

                          // 🔥 THÊM DÒNG NÀY
                          onLongPress: () {
                            HapticFeedback.mediumImpact(); // rung nhẹ cho xịn
                            confirmDelete(context, item);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void confirmDelete(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Bạn có muốn xóa lịch ngày ${item['ngay']} không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              await deleteLichLam(item['id']); // gọi API

              // reload lại danh sách
              loadLichLam();
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }
}

DateTime get startOfWeek {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1)); // Thứ 2
}

DateTime get endOfNextWeek {
  return startOfWeek.add(const Duration(days: 13)); // 2 tuần
}
