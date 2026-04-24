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

  // Định nghĩa hệ màu chủ đạo
  final Color primaryPink = const Color(0xFF7986CB);
  final Color lightPinkBg = const Color(0xFFE8EAF6);

  @override
  void initState() {
    super.initState();
    fetchNhanVien();
  }

  Future<void> fetchNhanVien() async {
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/nhanvien");
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
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/nhanvien/$id");
    try {
      final response = await http.delete(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message']),
              backgroundColor: primaryPink,
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
      backgroundColor: lightPinkBg, // Nền hồng trắng đồng bộ
      appBar: AppBar(
        title: const Text(
          "Danh Sách Nhân Viên",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNhanVienScreen()),
          );
          fetchNhanVien();
        },
        backgroundColor: primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPink))
          : RefreshIndicator(
              color: primaryPink,
              onRefresh: fetchNhanVien,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding dưới để tránh FAB
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: nhanVienList.length,
                itemBuilder: (context, index) {
                  final nv = nhanVienList[index];
                  return _buildNhanVienCard(nv);
                },
              ),
            ),
    );
  }

  Widget _buildNhanVienCard(Map nv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPink.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: primaryPink.withOpacity(0.1),
          child: Icon(Icons.person, color: primaryPink, size: 28),
        ),
        title: Text(
          nv['ten_nhan_vien'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2D3142),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.email_outlined, nv['email'] ?? "N/A"),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildBadge(nv['chuc_vu']),
                  const SizedBox(width: 12),
                  const Icon(Icons.payments_outlined, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    "${nv['luong_co_ban']}đ",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz, color: Colors.grey),
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNhanVienScreen(nhanVien: nv),
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
                  Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text("Chỉnh sửa"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text("Xóa nhân viên"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String role) {
    bool isFull = role == 'Full';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFull ? primaryPink : primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: isFull ? Colors.white : primaryPink,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteConfirm(Map nv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác nhận xóa"),
        content: Text("Dữ liệu của nhân viên ${nv['ten_nhan_vien']} sẽ bị xóa vĩnh viễn."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy bỏ", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteNhanVien(nv['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Xóa ngay"),
          ),
        ],
      ),
    );
  }
}