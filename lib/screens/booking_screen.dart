import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../screens/booking_confirmation_screen.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialTime;

  const BookingScreen({super.key, this.initialDate, this.initialTime});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final BookingService _bookingService = BookingService();

  String _selectedCategory = 'Kamar Tidur';
  late DateTime _selectedDate;
  late String _selectedTime;
  String _selectedBuildingType = 'Gedung Putri';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime(2025, 4, 18);
    _selectedTime = widget.initialTime ?? '10:00 - 11:00';
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _floorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  String get _formattedDate => '${_selectedDate.day.toString().padLeft(2, '0')} / ${_selectedDate.month.toString().padLeft(2, '0')} / ${_selectedDate.year}';
  String get _scheduleKey => '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
  List<Map<String, dynamic>> get _currentSlots => _bookingService.getSlotsForDate(_scheduleKey);

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Color(AppConstants.primaryColor), onPrimary: Colors.white, onSurface: Color(AppConstants.textDark))),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (!_bookingService.isSlotAvailable(_scheduleKey, _selectedTime)) {
          final firstAvailable = _currentSlots.firstWhere((s) => s['isAvailable'] == true, orElse: () => {'time': '', 'isAvailable': false});
          final time = firstAvailable['time'] as String;
          _selectedTime = time.isNotEmpty ? time : _selectedTime;
        }
      });
    }
  }

  void _pickTime() async {
    final slots = _currentSlots;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: Text('Pilih Jam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              const SizedBox(height: 4),
              Center(child: Text(_formattedDate, style: TextStyle(fontSize: 12, color: Color(AppConstants.textLight)))),
              const SizedBox(height: 16),
              ...slots.map((slot) {
                final isAvailable = slot['isAvailable'] as bool;
                final time = slot['time'] as String;
                final isSelected = _selectedTime == time;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isAvailable ? () => Navigator.pop(context, time) : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(AppConstants.primaryColor) : isAvailable ? Color(AppConstants.accentColor) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: isAvailable ? null : Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isAvailable) Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.lock_rounded, size: 16, color: Colors.grey.shade400)),
                            Text(time, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : isAvailable ? Color(AppConstants.textDark) : Colors.grey.shade400)),
                            const SizedBox(width: 10),
                            if (!isAvailable)
                              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: Text('Penuh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red.shade300)))
                            else if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null) setState(() => _selectedTime = selected);
  }

  void _navigateToConfirmation() async {
    final building = _buildingController.text.trim();
    final floor = _floorController.text.trim();
    final room = _roomController.text.trim();

    if (building.isEmpty || floor.isEmpty || room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mohon lengkapi detail alamat sebelum melanjutkan.')));
      return;
    }

    final booking = BookingModel(
      category: _selectedCategory,
      buildingType: _selectedBuildingType,
      buildingDetail: building,
      floorDetail: floor,
      roomDetail: room,
      date: _selectedDate,
      timeRange: _selectedTime,
      userUid: AuthService().currentUser?.uid,
      userEmail: AuthService().currentUser?.email,
    );

    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BookingConfirmationScreen(booking: booking)));

    // Jika berhasil di confirmation, kirim true ke JadwalScreen agar slot refresh jadi Penuh
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700));

  Widget _radioItem(String value, String groupValue, Function(String) onChanged) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? Color(AppConstants.primaryColor) : Color(AppConstants.inputBorder), width: 2), color: isSelected ? Color(AppConstants.primaryColor) : Colors.white), child: isSelected ? const Center(child: Icon(Icons.check, size: 12, color: Colors.white)) : null),
          const SizedBox(width: 12),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(AppConstants.textDark))),
        ],
      ),
    );
  }

  Widget _underlineField({required String hint, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(AppConstants.inputBorder), width: 1.2))),
      child: TextFormField(controller: controller, style: TextStyle(color: Color(AppConstants.textDark), fontSize: 15), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Color(AppConstants.textLight)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 10))),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4))]), child: Column(children: children));
  }

  Widget _divider() {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: Color(AppConstants.inputBorder).withValues(alpha: 0.3)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.primaryColor),
      appBar: AppBar(backgroundColor: Color(AppConstants.primaryColor), elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context, false)), title: const Text('Pemesanan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)), centerTitle: false),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Color(AppConstants.backgroundColor), borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('*Pilih Kategori'), const SizedBox(height: 14),
              _buildCard([_radioItem('Kamar Tidur', _selectedCategory, (v) => setState(() => _selectedCategory = v)), _divider(), _radioItem('Kamar Mandi', _selectedCategory, (v) => setState(() => _selectedCategory = v)), _divider(), _radioItem('Kamar Tidur + Kamar Mandi', _selectedCategory, (v) => setState(() => _selectedCategory = v))]),
              const SizedBox(height: 24),
              _sectionTitle('*Pilih Gedung'), const SizedBox(height: 14),
              _buildCard([_radioItem('Gedung Putri', _selectedBuildingType, (v) => setState(() => _selectedBuildingType = v)), _divider(), _radioItem('Gedung Putra', _selectedBuildingType, (v) => setState(() => _selectedBuildingType = v))]),
              const SizedBox(height: 24),
              _sectionTitle('*Masukan Detail Alamat'), const SizedBox(height: 14),
              _underlineField(hint: 'Gedung Berapa', controller: _buildingController), const SizedBox(height: 18),
              _underlineField(hint: 'Lantai Berapa', controller: _floorController), const SizedBox(height: 18),
              _underlineField(hint: 'Kamar Berapa', controller: _roomController), const SizedBox(height: 28),
              _sectionTitle('*Masukan Detail Jadwal'), const SizedBox(height: 14),
              GestureDetector(onTap: _pickDate, child: Container(padding: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(AppConstants.inputBorder), width: 1.2))), child: Row(children: [Expanded(child: Text(_formattedDate, style: TextStyle(fontSize: 15, color: Color(AppConstants.textDark)))), Icon(Icons.calendar_today_rounded, color: Color(AppConstants.primaryColor))]))),
              const SizedBox(height: 20),
              GestureDetector(onTap: _pickTime, child: Container(padding: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(AppConstants.inputBorder), width: 1.2))), child: Row(children: [Expanded(child: Text(_selectedTime, style: TextStyle(fontSize: 15, color: Color(AppConstants.textDark)))), Icon(Icons.keyboard_arrow_down_rounded, color: Color(AppConstants.primaryColor))]))),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _navigateToConfirmation, style: ElevatedButton.styleFrom(backgroundColor: Color(AppConstants.primaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Lanjutkan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)))),
            ],
          ),
        ),
      ),
    );
  }
}