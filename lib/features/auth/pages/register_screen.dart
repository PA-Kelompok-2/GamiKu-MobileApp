import 'package:application_gamiku/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart'; // ✅ tambah ini

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authC = Get.find<AuthController>();

  bool isObscure = true;

  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showErrorSnackbar("Registrasi Gagal", "Semua field wajib diisi.");
      return;
    }

    if (name.length < 3) {
      showErrorSnackbar("Registrasi Gagal", "Nama minimal 3 karakter.");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      showErrorSnackbar("Registrasi Gagal", "Format email tidak valid.");
      return;
    }

    if (password.length < 8) {
      showErrorSnackbar("Registrasi Gagal", "Password minimal 8 karakter.");
      return;
    }

    if (confirmPassword.isEmpty) {
      showErrorSnackbar("Registrasi Gagal", "Konfirmasi password wajib diisi.");
      return;
    }

    if (confirmPassword != password) {
      showErrorSnackbar("Registrasi Gagal", "Password tidak sama.");
      return;
    }

    try {
      await authC.register(email: email, password: password, name: name);
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();

      showErrorSnackbar(
        "Registrasi Gagal",
        errorMsg.contains('email')
            ? "Email sudah digunakan atau tidak valid."
            : "Terjadi kesalahan, coba lagi.",
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashRed,
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 25, top: 70, right: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Join GamiKu sekarang",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/logo.png', height: 50),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Nama",
                        prefixIcon: const Icon(
                          Icons.person,
                          color: AppColors.splashRed,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(
                          Icons.email,
                          color: AppColors.splashRed,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: passwordController,
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: AppColors.splashRed,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: AppColors.splashRed,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authC.isLoading.value ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.splashRed,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: authC.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Register",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sudah punya akun? "),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.login),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.splashRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}