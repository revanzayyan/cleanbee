import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialTime;

  const BookingScreen({
    super.key,
    this.initialDate,
    this.initialTime,
  });

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
  bool _isSubmitting = false;

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

  String get _formattedDate {
    return '${_selectedDate.day.toString().padLeft(2, '0')} / '
        '${_selectedDate.month.toString().padLeft(2, '0')} / '
        '${_selectedDate.year}';
  }

  String get _scheduleKey =>
      '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';

  /// Slot dari service — yang sudah di-booking otomatis false
  List<Map<String, dynamic>> get _currentSlots =>
      _bookingService.getSlotsForDate(_scheduleKey);

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(AppConstants.primaryColor),
              onPrimary: Colors.white,
              onSurface: Color(AppConstants.textDark),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(AppConstants.primaryColor),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Jika jam yang dipilih sudah penuh di tanggal baru, cari yang tersedia
        if (!_bookingService.isSlotAvailable(_scheduleKey, _selectedTime)) {
          final firstAvailable = _currentSlots.firstWhere(
            (s) => s['isAvailable'] == true,
            orElse: () => {'time': '', 'isAvailable': false},
          );
          final time = firstAvailable['time'] as String;
          _selectedTime = time.isNotEmpty ? time : _selectedTime;
        }
      });
    }
  }

  /// Bottom sheet pilih jam — slot penuh DISABLED, hanya tersedia yang bisa dipilih
  void _pickTime() async {
    final slots = _currentSlots;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'Pilih Jam',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  _formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(AppConstants.textLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Daftar slot
              ...slots.map((slot) {
                final isAvailable = slot['isAvailable'] as bool;
                final time = slot['time'] as String;
                final isSelected = _selectedTime == time;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildTimeButton(
                    time: time,
                    isSelected: isSelected,
                    isAvailable: isAvailable,
                    onTap: isAvailable
                        ? () => Navigator.pop(context, time)
                        : null,
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedTime = selected);
    }
  }

  /// Tombol jam individual — tersedia vs penuh
  Widget _buildTimeButton({
    required String time,
    required bool isSelected,
    required bool isAvailable,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(AppConstants.primaryColor)
                : isAvailable
                    ? Color(AppConstants.accentColor)
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: isAvailable
                ? null
                : Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isAvailable)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : isAvailable
                          ? Color(AppConstants.textDark)
                          : Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 10),
              if (!isAvailable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Penuh',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade300,
                    ),
                  ),
                )
              else if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  bool _validate() {
    if (_buildingController.text.trim().isEmpty) {
      _showError('Gedung berapa harus diisi');
      return false;
    }
    if (_floorController.text.trim().isEmpty) {
      _showError('Lantai berapa harus diisi');
      return false;
    }
    if (_roomController.text.trim().isEmpty) {
      _showError('Kamar berapa harus diisi');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Pemesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Kategori', _selectedCategory),
            _infoRow('Gedung', _selectedBuildingType),
            _infoRow(
                'Detail',
                '${_buildingController.text.trim()}, Lantai '
                '${_floorController.text.trim()}, Kamar '
                '${_roomController.text.trim()}'),
            _infoRow('Tanggal', _formattedDate),
            _infoRow('Jam', _selectedTime),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: TextStyle(color: Color(AppConstants.textLight))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.primaryColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Pesan'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: Color(AppConstants.textLight))),
          ),
          Text(': ',
              style: TextStyle(color: Color(AppConstants.textLight))),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.textDark))),
          ),
        ],
      ),
    );
  }

  void _submitBooking() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    // Simulasi delay
    await Future.delayed(const Duration(milliseconds: 800));

    final order = _bookingService.createBooking(
      category: _selectedCategory,
      buildingType: _selectedBuildingType,
      buildingDetail: _buildingController.text.trim(),
      floorDetail: _floorController.text.trim(),
      roomDetail: _roomController.text.trim(),
      date: _selectedDate,
      timeRange: _selectedTime,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (order != null) {
      // Berhasil → pop kembali ke JadwalScreen dengan result true
      // JadwalScreen akan refresh dan slot ini otomatis "Penuh"
      Navigator.pop(context, true);
    } else {
      _showError('Maaf, slot jam tersebut sudah penuh.');
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }

  Widget _radioItem(
      String value, String groupValue, Function(String) onChanged) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Color(AppConstants.primaryColor)
                    : Color(AppConstants.inputBorder),
                width: 2,
              ),
              color:
                  isSelected ? Color(AppConstants.primaryColor) : Colors.white,
            ),
            child: isSelected
                ? const Center(
                    child:
                        Icon(Icons.check, size: 12, color: Colors.white))
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _underlineField(
      {required String hint, required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Color(AppConstants.inputBorder), width: 1.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        style:
            TextStyle(color: Color(AppConstants.textDark), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Color(AppConstants.textLight)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.primaryColor),
      appBar: AppBar(
        backgroundColor: Color(AppConstants.primaryColor),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text(
          'Pemesanan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(AppConstants.backgroundColor),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Kategori ──
              _sectionTitle('*Pilih Kategori'),
              const SizedBox(height: 14),
              _buildCard([
                _radioItem('Kamar Tidur', _selectedCategory,
                    (v) => setState(() => _selectedCategory = v)),
                _divider(),
                _radioItem('Kamar Mandi', _selectedCategory,
                    (v) => setState(() => _selectedCategory = v)),
                _divider(),
                _radioItem('Kamar Tidur + Kamar Mandi', _selectedCategory,
                    (v) => setState(() => _selectedCategory = v)),
              ]),
              const SizedBox(height: 24),

              // ── Gedung ──
              _sectionTitle('*Pilih Gedung'),
              const SizedBox(height: 14),
              _buildCard([
                _radioItem('Gedung Putri', _selectedBuildingType,
                    (v) => setState(() => _selectedBuildingType = v)),
                _divider(),
                _radioItem('Gedung Putra', _selectedBuildingType,
                    (v) => setState(() => _selectedBuildingType = v)),
              ]),
              const SizedBox(height: 24),

              // ── Detail Alamat ──
              _sectionTitle('*Masukan Detail Alamat'),
              const SizedBox(height: 14),
              _underlineField(
                  hint: 'Gedung Berapa', controller: _buildingController),
              const SizedBox(height: 18),
              _underlineField(
                  hint: 'Lantai Berapa', controller: _floorController),
              const SizedBox(height: 18),
              _underlineField(
                  hint: 'Kamar Berapa', controller: _roomController),
              const SizedBox(height: 28),

              // ── Jadwal ──
              _sectionTitle('*Masukan Detail Jadwal'),
              const SizedBox(height: 14),
              _datePickerField(),
              const SizedBox(height: 20),
              _timePickerField(),
              const SizedBox(height: 32),

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isSubmitting ? null : _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppConstants.primaryColor),
                    disabledBackgroundColor: Color(AppConstants.primaryColor)
                        .withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lanjutkan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
          height: 1,
          color: Color(AppConstants.inputBorder).withValues(alpha: 0.3)),
    );
  }

  Widget _datePickerField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: Color(AppConstants.inputBorder), width: 1.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _formattedDate,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(AppConstants.textDark),
                ),
              ),
            ),
            Icon(Icons.calendar_today_rounded,
                color: Color(AppConstants.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _timePickerField() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: Color(AppConstants.inputBorder), width: 1.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedTime,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(AppConstants.textDark),
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(AppConstants.primaryColor)),
          ],
        ),
      ),
    );
  }
}