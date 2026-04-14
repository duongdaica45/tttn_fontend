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

  Future<void> fetchNhanVien() async {
    final url = Uri.parse("http://127.0.0.1:8000/api/nhanvien");
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        List all = data['data'];
        List filtered = all
            .where((nv) => nv['chuc_vu'] == 'Full' || nv['chuc_vu'] == 'Part')
            .toList();

        setState(() {
          nhanVienList = filtered;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteNhanVien(int id) async {
    final url = Uri.parse("http://127.0.0.1:8000/api/nhanvien/$id");
    try {
      final response = await http.delete(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: Colors.pink,
            ),
          );
        }
        fetchNhanVien();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi kết nối server"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50]?.withOpacity(0.3), // Nền hồng cực nhẹ
      appBar: AppBar(
        title: const Text(
          "Quản lý nhân viên",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNhanVienScreen()),
          );
          fetchNhanVien();
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: nhanVienList.length,
              itemBuilder: (context, index) {
                final nv = nhanVienList[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
                      nv['ten_nhan_vien'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.email_outlined, nv['email']),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildBadge(nv['chuc_vu']),
                              const SizedBox(width: 10),
                              Text(
                                "Lương: ${nv['luong_co_ban']}",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditNhanVienScreen(nhanVien: nv),
                            ),
                          ).then((_) => fetchNhanVien());
                        } else if (value == 'delete') {
                          _showDeleteConfirm(nv);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text("Sửa"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text("Xóa"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Widget hỗ trợ hiển thị dòng thông tin
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget hiển thị nhãn chức vụ (Full/Part)
  Widget _buildBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: role == 'Full' ? Colors.pink[400] : Colors.pink[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: role == 'Full' ? Colors.white : Colors.pink[700],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Hàm hiển thị Dialog xác nhận xóa chuyên nghiệp hơn
  void _showDeleteConfirm(Map nv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa nhân viên ${nv['ten_nhan_vien']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteNhanVien(nv['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }
}
