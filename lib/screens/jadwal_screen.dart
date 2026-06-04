import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import 'booking_screen.dart';

class JadwalScreen extends StatefulWidget {
  final VoidCallback? onBack; // ✅ Tambahkan parameter onBack

  const JadwalScreen({super.key, this.onBack});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late int selectedDay;
  late int currentMonth;
  late int currentYear;
  final BookingService _bookingService = BookingService();

  final List<String> monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const Color primaryColor = Color(0xFF0EA5E9);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentYear = now.year;
    currentMonth = now.month - 1;
    selectedDay = now.day;
  }

  String get scheduleKey => '$currentYear-${currentMonth + 1}-$selectedDay';
  List<Map<String, dynamic>> get currentSlots =>
      _bookingService.getSlotsForDate(scheduleKey);
  bool hasEvent(int day) {
    final key = '$currentYear-${currentMonth + 1}-$day';
    return _bookingService.hasScheduleForDate(key);
  }

  int get daysInMonth => DateTime(currentYear, currentMonth + 1 + 1, 0).day;
  int get firstWeekdayOfMonth {
    final weekday = DateTime(currentYear, currentMonth + 1, 1).weekday;
    return weekday - 1;
  }

  void _prevMonth() {
    setState(() {
      if (currentMonth == 0) {
        currentMonth = 11;
        currentYear--;
      } else {
        currentMonth--;
      }
      selectedDay = 1;
    });
  }

  void _nextMonth() {
    setState(() {
      if (currentMonth == 11) {
        currentMonth = 0;
        currentYear++;
      } else {
        currentMonth++;
      }
      selectedDay = 1;
    });
  }

  void _prevYear() {
    setState(() {
      currentYear--;
      selectedDay = 1;
    });
  }

  void _nextYear() {
    setState(() {
      currentYear++;
      selectedDay = 1;
    });
  }

  void _goToBooking({DateTime? initialDate, String? initialTime}) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingScreen(
                initialDate: initialDate, initialTime: initialTime)));
    if (result == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top + 62),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            28,
            MediaQuery.of(context).padding.top + 4,
            28,
            16,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0284C7),
                Color(0xFF38BDF8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Jadwal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCalendarSection(),
          const SizedBox(height: 12),
          _buildTimeSlotsSection(),
        ],
      ),
      // ❌ HAPUS TOTAL: bottomNavigationBar: Stack(...)
      // Karena sekarang menumpang pada BottomNav milik DashboardScreen
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left, color: primaryColor),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
            Column(children: [
              Text(monthNames[currentMonth],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                    onTap: _prevYear,
                    child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child:
                            Icon(Icons.remove, size: 14, color: primaryColor))),
                Text('$currentYear',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500)),
                GestureDetector(
                    onTap: _nextYear,
                    child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.add, size: 14, color: primaryColor))),
              ]),
            ]),
            IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right, color: primaryColor),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36)),
          ]),
          const SizedBox(height: 12),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const ['S', 'S', 'R', 'K', 'J', 'S', 'M']
                  .map((d) => SizedBox(
                      width: 36,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8)))))
                  .toList()),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final totalCells = firstWeekdayOfMonth + daysInMonth;
    final rows = (totalCells / 7).ceil();
    return Column(
        children: List.generate(
            rows,
            (rowIndex) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (colIndex) {
                  final cellIndex = rowIndex * 7 + colIndex;
                  final day = cellIndex - firstWeekdayOfMonth + 1;
                  if (day < 1 || day > daysInMonth) {
                    return const SizedBox(width: 36, height: 44);
                  }
                  return _buildDayCell(day);
                }))));
  }

  Widget _buildDayCell(int day) {
    final isSelected = day == selectedDay;
    final isToday = day == DateTime.now().day &&
        currentMonth == DateTime.now().month - 1 &&
        currentYear == DateTime.now().year;
    final hasEventOnDay = hasEvent(day);
    return GestureDetector(
      onTap: () => setState(() => selectedDay = day),
      child: SizedBox(
          width: 36,
          height: 44,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: primaryColor, width: 1.5)
                        : null),
                child: Center(
                    child: Text('$day',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? primaryColor
                                    : const Color(0xFF1E293B))))),
            const SizedBox(height: 2),
            if (hasEventOnDay && !isSelected)
              Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                      color: primaryColor, shape: BoxShape.circle))
            else
              const SizedBox(height: 5),
          ]
          )),
    );
  }

  Widget _buildTimeSlotsSection() {
    final slots = currentSlots;
    final dateLabel = '$selectedDay ${monthNames[currentMonth]} $currentYear';
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Pilih Jam',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
              Text(dateLabel,
                  style: const TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _buildLegend(Colors.red.shade400, 'Penuh'),
              const SizedBox(width: 16),
              _buildLegend(Colors.green.shade500, 'Tersedia')
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                // ✅ TAMBAHKAN: Padding bawah agar list jam tidak ketutupan tombol Add melayang
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  return _buildTimeSlotCard(
                      timeRange: slot['time'],
                      isAvailable: slot['isAvailable']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))
    ]);
  }

  Widget _buildTimeSlotCard(
      {required String timeRange, required bool isAvailable}) {
    final badgeBg =
        isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final badgeText =
        isAvailable ? const Color(0xFF15803D) : const Color(0xFFDC2626);
    final statusLabel = isAvailable ? 'Tersedia' : 'Penuh';

    return GestureDetector(
      onTap: isAvailable
          ? () {
              final bookingDate =
                  DateTime(currentYear, currentMonth + 1, selectedDay);
              _goToBooking(initialDate: bookingDate, initialTime: timeRange);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: isAvailable ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
            border: Border.all(
                color: isAvailable
                    ? Colors.grey.withValues(alpha: 0.1)
                    : Colors.red.shade100,
                width: 0.5)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(isAvailable ? Icons.access_time_rounded : Icons.block_rounded,
                size: 18,
                color: isAvailable
                    ? const Color(0xFF1E293B)
                    : Colors.red.shade300),
            const SizedBox(width: 10),
            Text(timeRange,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade400))
          ]),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: badgeBg, borderRadius: BorderRadius.circular(20)),
              child: Text(statusLabel,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: badgeText))),
        ]),
      ),
    );
  }
}
