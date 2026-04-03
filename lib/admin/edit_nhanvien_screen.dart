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

  @override
  void initState() {
    super.initState();

    // 🔥 GÁN DỮ LIỆU CŨ
    tenController = TextEditingController(
      text: widget.nhanVien['ten_nhan_vien'],
    );
    emailController = TextEditingController(text: widget.nhanVien['email']);
    luongController = TextEditingController(
      text: widget.nhanVien['luong_co_ban'].toString(),
    );

    chucVu = widget.nhanVien['chuc_vu'];
  }

  Future<void> updateNhanVien() async {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Lỗi")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi server")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa nhân viên")),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
              controller: luongController,
              decoration: const InputDecoration(labelText: "Lương"),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: chucVu,
              items: ["Full", "Part", "Manager"]
                  .map(
                    (role) => DropdownMenuItem(value: role, child: Text(role)),
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
              onPressed: updateNhanVien,
              child: const Text("Cập nhật"),
            ),
          ],
        ),
      ),
    );
  }
}
