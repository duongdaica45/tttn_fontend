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

  Future<void> addNhanVien() async {
    final url = Uri.parse("http://192.168.76.1:8000/api/nhanvien");
    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(tenController.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Tên chỉ được chứa chữ")));
      return;
    }

    // 🔥 Validate lương
    if (!RegExp(r'^[0-9]+$').hasMatch(luongController.text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lương chỉ được chứa số")));
      return;
    }

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Thêm thành công")));

        Navigator.pop(context); // quay lại màn danh sách
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
      appBar: AppBar(title: const Text("Thêm nhân viên")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: tenController,
                decoration: const InputDecoration(labelText: "Tên"),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ỹ\s]')),
                ],
              ),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              TextField(
                controller: luongController,
                decoration: const InputDecoration(labelText: "Lương"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 15),

              // 🔥 Dropdown chọn chức vụ
              DropdownButtonFormField<String>(
                value: chucVu,
                items: ["Full", "Part", "Manager"]
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    chucVu = value!;
                  });
                },
                decoration: const InputDecoration(labelText: "Chức vụ"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: addNhanVien,
                child: const Text("Thêm nhân viên"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
