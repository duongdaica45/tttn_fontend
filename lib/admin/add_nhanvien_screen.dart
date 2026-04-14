import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class AddNhanVienScreen extends StatefulWidget {
  const AddNhanVienScreen({super.key});

  @override
  State<AddNhanVienScreen> createState() => _AddNhanVienScreenState();
}

class _AddNhanVienScreenState extends State<AddNhanVienScreen> {
  final TextEditingController tenController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController luongController = TextEditingController();

  String chucVu = "Full";
  bool isLoading = false;

  Future<void> addNhanVien() async {
    if (tenController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        luongController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    //final url = Uri.parse("http://127.0.0.1:8000/api/nhanvien");
    final url = Uri.parse("https://tttn-1-ujfk.onrender.com/api/nhanvien");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ten_nhan_vien": tenController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "chuc_vu": chucVu,
          "luong_co_ban": int.parse(luongController.text),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Thêm thành công"),
              backgroundColor: Colors.pink,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Lỗi")));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lỗi kết nối server")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thêm Nhân Viên",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Biểu tượng trang trí phía trên
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.pink,
              child: Icon(
                Icons.person_add_alt_1,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // Card chứa các trường nhập liệu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTextField(
                    controller: tenController,
                    label: "Tên nhân viên",
                    icon: Icons.person_outline,
                    formatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-ZÀ-ỹ\s]'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: passwordController,
                    label: "Mật khẩu",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: luongController,
                    label: "Lương cơ bản",
                    icon: Icons.monetization_on_outlined,
                    type: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 15),

                  // Dropdown chọn chức vụ trang trí hồng
                  DropdownButtonFormField<String>(
                    value: chucVu,
                    decoration: InputDecoration(
                      labelText: "Chức vụ",
                      labelStyle: const TextStyle(color: Colors.pink),
                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                        color: Colors.pink,
                      ),
                      filled: true,
                      fillColor: Colors.pink.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ["Full", "Part", "Manager"]
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => chucVu = value!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Nút Thêm
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : addNhanVien,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: Colors.pink.withOpacity(0.5),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "THÊM MỚI NHÂN VIÊN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget dùng chung cho TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.pink),
        prefixIcon: Icon(icon, color: Colors.pink),
        filled: true,
        fillColor: Colors.pink.withOpacity(0.05),
        border: OutlineInputBorder(
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
