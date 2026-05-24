import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  List<Map<String, String>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList('saved_addresses') ?? [];
    setState(() {
      _addresses = data.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
      _isLoading = false;
    });
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _addresses.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('saved_addresses', data);
  }

  void _showAddDialog({int? editIndex}) {
    final labelController = TextEditingController(
      text: editIndex != null ? _addresses[editIndex]['label'] ?? '' : '',
    );
    final addressController = TextEditingController(
      text: editIndex != null ? _addresses[editIndex]['address'] ?? '' : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          editIndex != null ? '编辑地址' : '添加常用地址',
          style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '标签（如：家、公司）',
                labelStyle: GoogleFonts.poppins(color: Colors.white54),
                prefixIcon: const Icon(Icons.label, color: Color(0xFFFFD700), size: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '地址',
                labelStyle: GoogleFonts.poppins(color: Colors.white54),
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 20),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFFFD700).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final label = labelController.text.trim();
              final address = addressController.text.trim();
              if (label.isEmpty || address.isEmpty) return;
              setState(() {
                final item = {'label': label, 'address': address};
                if (editIndex != null) {
                  _addresses[editIndex] = item;
                } else {
                  _addresses.add(item);
                }
              });
              _saveAddresses();
              Navigator.pop(context);
            },
            child: Text('保存', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    labelController.dispose();
    addressController.dispose();
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('删除地址', style: GoogleFonts.poppins(color: Colors.redAccent)),
        content: Text(
          '确定删除"${_addresses[index]['label']}"吗？',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('取消', style: GoogleFonts.poppins(color: Colors.white54))),
          TextButton(
            onPressed: () {
              setState(() => _addresses.removeAt(index));
              _saveAddresses();
              Navigator.pop(context);
            },
            child: Text('删除', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _getColor(String label) {
    final l = label.toLowerCase();
    if (l.contains('家') || l.contains('home')) return Colors.orange;
    if (l.contains('公司') || l.contains('work')) return Colors.blue;
    if (l.contains('学校') || l.contains('school')) return Colors.green;
    return const Color(0xFFFFD700);
  }

  IconData _getIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('家') || l.contains('home')) return Icons.home;
    if (l.contains('公司') || l.contains('work')) return Icons.work;
    if (l.contains('学校') || l.contains('school')) return Icons.school;
    return Icons.location_on;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('常用地址', style: GoogleFonts.poppins(color: const Color(0xFFFFD700), fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, color: Colors.white.withOpacity(0.2), size: 48),
                      const SizedBox(height: 12),
                      Text('暂无常用地址', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('点击右下角按钮添加', style: GoogleFonts.poppins(color: Colors.white24, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    final color = _getColor(addr['label'] ?? '');
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(_getIcon(addr['label'] ?? ''), color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(addr['label'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(addr['address'] ?? '', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white38, size: 18),
                            onPressed: () => _showAddDialog(editIndex: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                            onPressed: () => _confirmDelete(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: const Color(0xFF1A1A2E),
        child: const Icon(Icons.add),
      ),
    );
  }
}
