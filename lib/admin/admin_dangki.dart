import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_xacNhanDangKi.dart';

class DanhSachNhanVienFullScreen extends StatefulWidget {
  final Map lichLam;

  const DanhSachNhanVienFullScreen({super.key, required this.lichLam});

  @override
  State<DanhSachNhanVienFullScreen> createState() =>
      _DanhSachNhanVienFullScreenState();
}

class _DanhSachNhanVienFullScreenState
    extends State<DanhSachNhanVienFullScreen> {
  List nhanVienList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNhanVien();
  }

  Future<void> fetchNhanVien() async {
    final url = Uri.parse("http://localhost:8000/api/nhan-vien-full");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nhanVienList = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng chủ đạo
      appBar: AppBar(
        title: const Text(
          "Chọn Nhân Viên",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner hiển thị thông tin ca đang chọn
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.pink),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Đang chọn nhân viên cho ngày ${widget.lichLam['ngay']} (${widget.lichLam['ten_ca']})",
                    style: const TextStyle(color: Colors.pink, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.pink),
                  )
                : nhanVienList.isEmpty
                ? const Center(child: Text("Không có nhân viên nào"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: nhanVienList.length,
                    itemBuilder: (context, index) {
                      final nv = nhanVienList[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.pink[100],
                            child: const Icon(Icons.person, color: Colors.pink),
                          ),
                          title: Text(
                            nv['ten_nhan_vien'] ?? 'Không tên',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Chức vụ: ${nv['chuc_vu']}",
                              style: TextStyle(color: Colors.pink[300]),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.pink[200],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => XacNhanDangKyScreen(
                                  lichLam: widget.lichLam,
                                  nhanVien: nv,
                                ),
                              ),
                            );
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
}
