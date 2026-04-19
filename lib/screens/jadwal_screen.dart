import 'package:flutter/material.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late int selectedDay;
  late int currentMonth; // 0-based (0 = Januari)
  late int currentYear;
  int activeNavIndex = 1;

  final List<String> monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  // Key: "year-month-day" (month 1-based), Value: list of time slots
  final Map<String, List<Map<String, dynamic>>> scheduleData = {
    '2025-4-1':  [
      {'time': '07:00 - 08:00', 'isAvailable': false},
      {'time': '09:00 - 10:00', 'isAvailable': true},
      {'time': '13:00 - 14:00', 'isAvailable': true},
    ],
    '2025-4-5':  [
      {'time': '07:00 - 08:00', 'isAvailable': false},
      {'time': '10:00 - 11:00', 'isAvailable': false},
      {'time': '14:00 - 15:00', 'isAvailable': true},
    ],
    '2025-4-10': [
      {'time': '08:00 - 09:00', 'isAvailable': true},
      {'time': '11:00 - 12:00', 'isAvailable': false},
      {'time': '15:00 - 16:00', 'isAvailable': true},
    ],
    '2025-4-15': [
      {'time': '07:00 - 08:00', 'isAvailable': false},
      {'time': '10:00 - 11:00', 'isAvailable': false},
      {'time': '13:00 - 14:00', 'isAvailable': false},
    ],
    '2025-4-19': [
      {'time': '07:00 - 08:00', 'isAvailable': false},
      {'time': '10:00 - 11:00', 'isAvailable': true},
      {'time': '11:00 - 12:00', 'isAvailable': true},
    ],
    '2025-4-22': [
      {'time': '09:00 - 10:00', 'isAvailable': true},
      {'time': '12:00 - 13:00', 'isAvailable': false},
      {'time': '16:00 - 17:00', 'isAvailable': true},
    ],
    '2025-5-3':  [
      {'time': '07:00 - 08:00', 'isAvailable': true},
      {'time': '10:00 - 11:00', 'isAvailable': true},
    ],
    '2025-5-10': [
      {'time': '08:00 - 09:00', 'isAvailable': false},
      {'time': '13:00 - 14:00', 'isAvailable': true},
    ],
  };

  // Default slots jika tanggal tidak ada di scheduleData
  final List<Map<String, dynamic>> defaultSlots = [
    {'time': '07:00 - 08:00', 'isAvailable': false},
    {'time': '10:00 - 11:00', 'isAvailable': true},
    {'time': '11:00 - 12:00', 'isAvailable': true},
  ];

  static const Color primaryColor = Color(0xFF0EA5E9);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentYear = now.year;
    currentMonth = now.month - 1; // Convert to 0-based
    selectedDay = now.day;
  }

  String get scheduleKey => '$currentYear-${currentMonth + 1}-$selectedDay';

  List<Map<String, dynamic>> get currentSlots =>
      scheduleData[scheduleKey] ?? defaultSlots;

  bool hasEvent(int day) {
    final key = '$currentYear-${currentMonth + 1}-$day';
    return scheduleData.containsKey(key);
  }

  int get daysInMonth => DateTime(currentYear, currentMonth + 1 + 1, 0).day;

  // Hari pertama di bulan ini (0=Senin, 6=Minggu — format ISO)
  int get firstWeekdayOfMonth {
    final weekday = DateTime(currentYear, currentMonth + 1, 1).weekday;
    return weekday - 1; // Flutter weekday: 1=Mon..7=Sun → 0-based offset
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Jadwal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildCalendarSection(),
          const SizedBox(height: 12),
          _buildTimeSlotsSection(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          // Navigasi Bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left, color: primaryColor),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Column(
                children: [
                  Text(
                    monthNames[currentMonth],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Navigasi Tahun
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _prevYear,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.remove, size: 14, color: primaryColor),
                        ),
                      ),
                      Text(
                        '$currentYear',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: _nextYear,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.add, size: 14, color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right, color: primaryColor),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Header hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['S', 'S', 'R', 'K', 'J', 'S', 'M'].map((d) {
              return SizedBox(
                width: 36,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Grid kalender
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final totalCells = firstWeekdayOfMonth + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (colIndex) {
            final cellIndex = rowIndex * 7 + colIndex;
            final day = cellIndex - firstWeekdayOfMonth + 1;

            if (day < 1 || day > daysInMonth) {
              return const SizedBox(width: 36, height: 44);
            }
            return _buildDayCell(day);
          }),
        );
      }),
    );
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: primaryColor, width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? primaryColor
                            : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Titik indikator event
            if (hasEventOnDay && !isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsSection() {
    final slots = currentSlots;
    final dateLabel =
        '$selectedDay ${monthNames[currentMonth]} $currentYear';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Jam',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Legenda
            Row(
              children: [
                _buildLegend(Colors.red.shade400, 'Penuh'),
                const SizedBox(width: 16),
                _buildLegend(Colors.green.shade500, 'Tersedia'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  return _buildTimeSlotCard(
                    timeRange: slot['time'],
                    isAvailable: slot['isAvailable'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildTimeSlotCard({
    required String timeRange,
    required bool isAvailable,
  }) {
    final badgeBg = isAvailable
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);
    final badgeText = isAvailable
        ? const Color(0xFF15803D)
        : const Color(0xFFDC2626);
    final statusLabel = isAvailable ? 'Tersedia' : 'Penuh';

    return GestureDetector(
      onTap: isAvailable
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Memesan jadwal: $timeRange',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: primaryColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeRange,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badgeText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.access_time, 'label': 'Riwayat'},
      {'icon': Icons.notifications_outlined, 'label': 'Notifikasi'},
      {'icon': Icons.message_outlined, 'label': 'Pesan'},
    ];

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (i) {
          final isActive = i == activeNavIndex;
          return GestureDetector(
            onTap: () => setState(() => activeNavIndex = i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isActive)
                  Container(
                    height: 3,
                    width: 24,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(height: 7),
                Icon(
                  navItems[i]['icon'] as IconData,
                  color: isActive ? primaryColor : Colors.grey,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  navItems[i]['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? primaryColor : Colors.grey,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}