import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleGoogleAuth() async {
    setState(() => _isLoading = true);
    final result = await context.read<AppProvider>().signIn();
    setState(() => _isLoading = false);
    
    if (result == null) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.redAccent)
        );
      }
    }
  }

  void _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final tr = context.read<AppProvider>().tr;

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('invalid_email'))));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('invalid_password'))));
      return;
    }

    setState(() => _isLoading = true);
    final isRegistering = _tabController.index == 1;
    
    if (isRegistering && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال الاسم / Please enter your name")));
      setState(() => _isLoading = false);
      return;
    }

    final result = isRegistering 
        ? await context.read<AppProvider>().signUpWithEmail(email, password, name)
        : await context.read<AppProvider>().signInWithEmail(email, password);
    
    setState(() => _isLoading = false);
    
    if (result == null) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.redAccent)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.read<AppProvider>().tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('app_title')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: tr('login')),
            Tab(text: tr('register')),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAuthView(context, isRegistering: false),
                _buildAuthView(context, isRegistering: true),
              ],
            ),
      ),
    );
  }

  Widget _buildAuthView(BuildContext context, {required bool isRegistering}) {
    final tr = context.read<AppProvider>().tr;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            isRegistering ? Icons.person_add_outlined : Icons.login_outlined, 
            size: 60, 
            color: AppColors.accent
          ),
          const SizedBox(height: 30),
          
          if (isRegistering) ...[
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: tr('locale') == 'ar' ? 'الاسم' : 'Full Name',
                labelStyle: const TextStyle(color: AppColors.accent),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
          ],

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: tr('email'),
              labelStyle: const TextStyle(color: AppColors.accent),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: tr('password'),
              labelStyle: const TextStyle(color: AppColors.accent),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.accent), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _handleEmailAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white10),
              ),
            ),
            child: Text(isRegistering ? tr('register') : tr('login')),
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Divider(color: Colors.white24)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(tr('or'), style: const TextStyle(color: Colors.grey))),
              const Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _handleGoogleAuth,
            icon: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_"G"_Logo.svg/1200px-Google_"G"_Logo.svg.png',
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, color: Colors.black),
            ),
            label: Text(tr('google_login'), style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}


