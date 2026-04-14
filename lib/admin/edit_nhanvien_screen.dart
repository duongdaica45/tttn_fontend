import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class EditNhanVienScreen extends StatefulWidget {
  final Map nhanVien;

  const EditNhanVienScreen({super.key, required this.nhanVien});

  @override
  State<EditNhanVienScreen> createState() => _EditNhanVienScreenState();
}

class _EditNhanVienScreenState extends State<EditNhanVienScreen> {
  late TextEditingController tenController;
  late TextEditingController emailController;
  late TextEditingController luongController;
  String chucVu = "Full";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Gán dữ liệu cũ vào controller
    tenController = TextEditingController(text: widget.nhanVien['ten_nhan_vien']);
    emailController = TextEditingController(text: widget.nhanVien['email']);
    luongController = TextEditingController(text: widget.nhanVien['luong_co_ban'].toString());
    chucVu = widget.nhanVien['chuc_vu'];
  }

  Future<void> updateNhanVien() async {
    // Validate dữ liệu
    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(tenController.text)) {
      _showSnackBar("Tên chỉ được chứa chữ", Colors.orange);
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(luongController.text)) {
      _showSnackBar("Lương chỉ được chứa số", Colors.orange);
      return;
    }

    setState(() => isLoading = true);
    final id = widget.nhanVien['id'];
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/nhanvien/$id");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ten_nhan_vien": tenController.text,
          "email": emailController.text,
          "chuc_vu": chucVu,
          "luong_co_ban": int.parse(luongController.text),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showSnackBar("Cập nhật thành công", Colors.pink);
        Navigator.pop(context);
      } else {
        _showSnackBar(data['message'] ?? "Lỗi cập nhật", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Lỗi server", Colors.redAccent);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chỉnh Sửa Nhân Viên", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Hero(
              tag: 'avatar_edit',
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.pink,
                child: Icon(Icons.edit_note_rounded, size: 45, color: Colors.white),
              ),
            ),
            const SizedBox(height: 25),
            
            // Card chứa Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: tenController,
                    label: "Họ và tên",
                    icon: Icons.person_outline,
                    formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ỹ\s]'))],
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: emailController,
                    label: "Email liên hệ",
                    icon: Icons.email_outlined,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: luongController,
                    label: "Lương cơ bản",
                    icon: Icons.account_balance_wallet_outlined,
                    type: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 15),
                  
                  // Chức vụ Dropdown
                  DropdownButtonFormField<String>(
                    value: chucVu,
                    decoration: InputDecoration(
                      labelText: "Chức vụ",
                      labelStyle: const TextStyle(color: Colors.pink),
                      prefixIcon: const Icon(Icons.work_outline, color: Colors.pink),
                      filled: true,
                      fillColor: Colors.pink.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ["Full", "Part", "Manager"]
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (value) => setState(() => chucVu = value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // Nút cập nhật
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateNhanVien,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(233, 30, 99, 1),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.pink.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CẬP NHẬT THÔNG TIN", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.pink),
        prefixIcon: Icon(icon, color: Colors.pink),
        filled: true,
        fillColor: Colors.pink.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.pink, width: 1),
        ),
      ),
    );
  }
}