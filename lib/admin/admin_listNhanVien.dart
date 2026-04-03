import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_nhanvien_screen.dart';
import 'edit_nhanvien_screen.dart';


class NhanVienScreen extends StatefulWidget {
  const NhanVienScreen({super.key});

  @override
  State<NhanVienScreen> createState() => _NhanVienScreenState();
}

class _NhanVienScreenState extends State<NhanVienScreen> {
  List nhanVienList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNhanVien();
  }

  //Danh sách
  Future<void> fetchNhanVien() async {
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/nhanvien");

    try {
      final response = await http.get(url);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        List all = data['data'];

        // 🔥 LỌC CHỈ FULL + PART
        List filtered = all
            .where((nv) => nv['chuc_vu'] == 'Full' || nv['chuc_vu'] == 'Part')
            .toList();

        setState(() {
          nhanVienList = filtered;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  //Xóa
  Future<void> deleteNhanVien(int id) async {
    final url = Uri.parse("http://192.168.76.1:8000/api/nhanvien/$id");

    try {
      final response = await http.delete(url);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));

        // 🔥 reload lại danh sách
        fetchNhanVien();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách nhân viên")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // mở màn hình thêm
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNhanVienScreen()),
          );

          // reload lại danh sách sau khi thêm
          fetchNhanVien();
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: nhanVienList.length,
              itemBuilder: (context, index) {
                final nv = nhanVienList[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(nv['ten_nhan_vien']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${nv['email']}"),
                        Text("Chức vụ: ${nv['chuc_vu']}"),
                        Text("Lương: ${nv['luong_co_ban']}"),
                      ],
                    ),

                    // 🔥 MENU 3 CHẤM
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // 🔥 MỞ MÀN HÌNH SỬA
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditNhanVienScreen(nhanVien: nv),
                            ),
                          ).then((_) {
                            fetchNhanVien(); // reload lại sau khi sửa
                          });
                        }
                        if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Xác nhận"),
                              content: const Text(
                                "Bạn có chắc muốn xóa nhân viên này?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Hủy"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteNhanVien(nv['id']);
                                  },
                                  child: const Text("Xóa"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
