import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ping_my_therapist/services/appointment_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root screen — two tabs: Find Therapist / My Bookings
// ─────────────────────────────────────────────────────────────────────────────

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF535394),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 54, right: 16),
              title: const Text(
                'Book a Session',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                color: const Color(0xFF535394),
                child: Stack(
                  children: [
                    Positioned(
                      right: 16,
                      bottom: 48,
                      child: Opacity(
                        opacity: 0.15,
                        child: SvgPicture.asset(
                          'assets/images/serene.svg',
                          height: 90,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Find Therapist'),
                Tab(text: 'My Bookings'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _FindTherapistTab(),
            _MyBookingsTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Find Therapist
// ─────────────────────────────────────────────────────────────────────────────

class _FindTherapistTab extends StatefulWidget {
  const _FindTherapistTab();

  @override
  State<_FindTherapistTab> createState() => _FindTherapistTabState();
}

class _FindTherapistTabState extends State<_FindTherapistTab> {
  final _service = AppointmentService();
  List<TherapistInfo>? _therapists;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getVerifiedTherapists();
      if (mounted) setState(() => _therapists = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF535394)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Could not load therapists.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF535394),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_therapists == null || _therapists!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/images/serene.svg', height: 130),
              const SizedBox(height: 20),
              const Text(
                'No therapists available',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Verified therapists will appear here once they join the platform.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF535394),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _therapists!.length,
        itemBuilder: (ctx, i) => _TherapistCard(
          therapist: _therapists![i],
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) =>
                  TherapistDetailScreen(therapist: _therapists![i]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Therapist card in the list
// ─────────────────────────────────────────────────────────────────────────────

class _TherapistCard extends StatefulWidget {
  final TherapistInfo therapist;
  final VoidCallback onTap;

  const _TherapistCard({required this.therapist, required this.onTap});

  @override
  State<_TherapistCard> createState() => _TherapistCardState();
}

class _TherapistCardState extends State<_TherapistCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final t = widget.therapist;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD1C4E9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              _TherapistAvatar(name: t.name, photoUrl: t.profilePhoto, radius: 28),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (t.yearsOfExperience > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${t.yearsOfExperience} yrs experience',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (t.specializations.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: t.specializations
                            .take(3)
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E5F8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF535394),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF535394),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — My Bookings
// ─────────────────────────────────────────────────────────────────────────────

class _MyBookingsTab extends StatelessWidget {
  const _MyBookingsTab();

  @override
  Widget build(BuildContext context) {
    final service = AppointmentService();
    return StreamBuilder<List<AppointmentModel>>(
      stream: service.getMyAppointments(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF535394)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/images/serene.svg', height: 130),
                  const SizedBox(height: 20),
                  const Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Switch to "Find Therapist" to request your first session.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: appointments.length,
          itemBuilder: (_, i) =>
              _AppointmentCard(appointment: appointments[i]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking card (My Bookings tab)
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({required this.appointment});

  static const _statusColors = {
    'pending': Color(0xFFF59E0B),
    'confirmed': Color(0xFF3B82F6),
    'completed': Color(0xFF10B981),
    'cancelled': Color(0xFFEF4444),
    'rescheduled': Color(0xFF8B5CF6),
    'no_show': Color(0xFFDC2626),
  };

  static const _statusLabels = {
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'rescheduled': 'Rescheduled',
    'no_show': 'No Show',
  };

  @override
  Widget build(BuildContext context) {
    final apt = appointment;
    final dateStr =
        DateFormat('EEE, MMM d, yyyy').format(apt.scheduledAt.toLocal());
    final timeStr = DateFormat('h:mm a').format(apt.scheduledAt.toLocal());
    final statusColor =
        _statusColors[apt.status] ?? const Color(0xFF9CA3AF);
    final statusLabel =
        _statusLabels[apt.status] ?? _capitalize(apt.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status accent bar
          Container(
            width: 5,
            height: 80,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          apt.therapistName ?? 'Therapist',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '$timeStr  •  ${apt.duration} min  •  ${_capitalize(apt.type)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Therapist Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class TherapistDetailScreen extends StatelessWidget {
  final TherapistInfo therapist;

  const TherapistDetailScreen({super.key, required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with therapist avatar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            centerTitle: true,
            backgroundColor: const Color(0xFF535394),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Text(
                therapist.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
              ),
              background: Container(
                color: const Color(0xFF535394),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _TherapistAvatar(
                      name: therapist.name,
                      photoUrl: therapist.profilePhoto,
                      radius: 44,
                      fontSize: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Specializations
                if (therapist.specializations.isNotEmpty) ...[
                  _SectionTitle('Specializations'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: therapist.specializations
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E5F8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF535394),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Experience
                if (therapist.yearsOfExperience > 0) ...[
                  _InfoRow(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Experience',
                    value: '${therapist.yearsOfExperience} years',
                  ),
                  const SizedBox(height: 20),
                ],

                // Bio
                if (therapist.bio.isNotEmpty) ...[
                  _SectionTitle('About'),
                  const SizedBox(height: 8),
                  Text(
                    therapist.bio,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.65,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Availability
                if (therapist.availability.isNotEmpty) ...[
                  _SectionTitle('Available Days'),
                  const SizedBox(height: 10),
                  _AvailabilityChips(
                      availability: therapist.availability),
                  const SizedBox(height: 8),
                  _AvailabilityRows(
                      availability: therapist.availability),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.amber.shade800, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Availability not yet configured. You can still send a request.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),

      // Fixed bottom booking button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton.icon(
            onPressed: () => _openBookingSheet(context),
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: const Text(
              'Book a Session',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF535394),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(therapist: therapist),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Availability display widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AvailabilityChips extends StatelessWidget {
  final List<Map<String, dynamic>> availability;

  static const _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  const _AvailabilityChips({required this.availability});

  @override
  Widget build(BuildContext context) {
    final activeDays = availability
        .map((a) => (a['dayOfWeek'] as num?)?.toInt() ?? -1)
        .where((d) => d >= 0 && d < 7)
        .toSet();

    return Row(
      children: List.generate(7, (i) {
        final active = activeDays.contains(i);
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF535394)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _dayNames[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _AvailabilityRows extends StatelessWidget {
  final List<Map<String, dynamic>> availability;

  static const _dayNames = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday'
  ];

  const _AvailabilityRows({required this.availability});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: availability.map((slot) {
        final dow = (slot['dayOfWeek'] as num?)?.toInt() ?? -1;
        final dayName = (dow >= 0 && dow < 7) ? _dayNames[dow] : '—';
        final start = (slot['startTime'] as String?) ?? '';
        final end = (slot['endTime'] as String?) ?? '';

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$start – $end',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  final TherapistInfo therapist;

  const _BookingSheet({required this.therapist});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  final _service = AppointmentService();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  int _duration = 60;
  String _type = 'individual';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Generate 30-min slots within the therapist's availability for the selected date.
  List<String> get _availableSlots {
    if (_selectedDate == null) return [];

    // Flutter weekday: Monday=1 … Sunday=7; convert to 0=Sun…6=Sat
    final dow = _selectedDate!.weekday % 7;

    final matchingSlots = widget.therapist.availability
        .where((a) => (a['dayOfWeek'] as num?)?.toInt() == dow)
        .toList();

    if (matchingSlots.isEmpty) return [];

    final List<String> times = [];
    for (final slot in matchingSlots) {
      final start = _parseSlotTime(slot['startTime'] as String? ?? '09:00');
      final end = _parseSlotTime(slot['endTime'] as String? ?? '17:00');
      if (start == null || end == null) continue;

      var current = start;
      while (current.isBefore(end)) {
        times.add(DateFormat('h:mm a').format(current));
        current = current.add(const Duration(minutes: 30));
      }
    }
    return times;
  }

  DateTime? _parseSlotTime(String timeStr) {
    if (_selectedDate == null) return null;
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return null;
      return DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (_) {
      return null;
    }
  }

  bool _isAvailableDay(DateTime date) {
    final dow = date.weekday % 7;
    if (widget.therapist.availability.isEmpty) return true;
    return widget.therapist.availability
        .any((a) => (a['dayOfWeek'] as num?)?.toInt() == dow);
  }

  DateTime _bookingFirstDate() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 1));
  }

  DateTime _bookingLastDate() {
    return _bookingFirstDate().add(const Duration(days: 89));
  }

  DateTime? _firstSelectableDate() {
    if (widget.therapist.availability.isEmpty) {
      return _bookingFirstDate();
    }

    var cursor = _bookingFirstDate();
    final last = _bookingLastDate();
    while (!cursor.isAfter(last)) {
      if (_isAvailableDay(cursor)) return cursor;
      cursor = cursor.add(const Duration(days: 1));
    }
    return null;
  }

  Future<void> _pickDate() async {
    final firstDate = _bookingFirstDate();
    final lastDate = _bookingLastDate();
    final hasAvailability = widget.therapist.availability.isNotEmpty;
    final firstSelectable = hasAvailability ? _firstSelectableDate() : firstDate;

    if (hasAvailability && firstSelectable == null) {
      setState(() {
        _error =
            'This therapist has no bookable dates in the next 90 days. Please contact them directly.';
      });
      return;
    }

    final initialDate = _selectedDate != null &&
            (!hasAvailability || _isAvailableDay(_selectedDate!))
        ? _selectedDate!
        : firstSelectable!;

    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        selectableDayPredicate: hasAvailability ? _isAvailableDay : null,
        useRootNavigator: true,
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF535394),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null && mounted) {
        setState(() {
          _selectedDate = picked;
          _selectedTime = null;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not open the date picker. Please try again.');
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      setState(() => _error = 'Please select a date.');
      return;
    }
    if (_selectedTime == null && _availableSlots.isNotEmpty) {
      setState(() => _error = 'Please select a time slot.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Build the appointment DateTime
      DateTime scheduledAt;
      if (_selectedTime != null) {
        final parsed = DateFormat('h:mm a').parse(_selectedTime!);
        scheduledAt = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          parsed.hour,
          parsed.minute,
        );
      } else {
        // No slots configured — default to 09:00
        scheduledAt = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          9,
          0,
        );
      }

      // Duplicate check
      final isDuplicate =
          await _service.hasPendingRequest(widget.therapist.uid, scheduledAt);
      if (isDuplicate) {
        setState(() {
          _loading = false;
          _error = 'You already have a pending request for this slot.';
        });
        return;
      }

      await _service.requestAppointment(
        therapistUid: widget.therapist.uid,
        therapistName: widget.therapist.name,
        scheduledAt: scheduledAt,
        duration: _duration,
        type: _type,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Appointment request sent!'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Request a Session',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'with ${widget.therapist.name}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Error banner
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Date picker ──────────────────────────────────────────────
            _FieldLabel('Select Date'),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _selectedDate != null
                      ? const Color(0xFFE5E5F8)
                      : Colors.white,
                  border: Border.all(
                    color: _selectedDate != null
                        ? const Color(0xFF535394)
                        : const Color(0xFFD1C4E9),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: _selectedDate != null
                          ? const Color(0xFF535394)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEEE, MMMM d, yyyy')
                              .format(_selectedDate!)
                          : 'Tap to choose a date',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? const Color(0xFF535394)
                            : Colors.grey,
                        fontWeight: _selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
            const SizedBox(height: 16),

            // ── Time slots ───────────────────────────────────────────────
            if (_selectedDate != null) ...[
              _FieldLabel('Select Time Slot'),
              const SizedBox(height: 8),
              if (_availableSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No slots for this day. Select another date or submit anyway.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableSlots.map((time) {
                    final isSelected = _selectedTime == time;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTime = time),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF535394)
                              : const Color(0xFFE5E5F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF535394),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
            ],

            // ── Duration ─────────────────────────────────────────────────
            _FieldLabel('Duration'),
            const SizedBox(height: 8),
            Row(
              children: [30, 45, 60, 90].map((d) {
                final isSelected = _duration == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _duration = d),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF535394)
                            : const Color(0xFFE5E5F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$d min',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF535394),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Session type ─────────────────────────────────────────────
            _FieldLabel('Session Type'),
            const SizedBox(height: 8),
            Row(
              children: ['individual', 'couples', 'group'].map((t) {
                final isSelected = _type == t;
                final label = '${t[0].toUpperCase()}${t.substring(1)}';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF535394)
                            : const Color(0xFFE5E5F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF535394),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Notes ────────────────────────────────────────────────────
            _FieldLabel('Message (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Share what you'd like to work on…",
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF8F7FF),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF535394), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF535394),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFBBBBDD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Request Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TherapistAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final double? fontSize;

  const _TherapistAvatar({
    required this.name,
    this.photoUrl,
    required this.radius,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final size = fontSize ?? radius * 0.65;

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF7D7DDE),
      child: photoUrl != null
          ? ClipOval(
              child: Image.network(
                photoUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: size,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF535394),
        letterSpacing: -0.3,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7D7DDE)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
