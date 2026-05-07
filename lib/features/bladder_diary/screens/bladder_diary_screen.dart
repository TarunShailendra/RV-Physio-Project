import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class BladderDiaryScreen extends StatefulWidget {
  const BladderDiaryScreen({super.key});
  @override
  State<BladderDiaryScreen> createState() => _BladderDiaryScreenState();
}

class BladderDiaryEntry {
  String fluidAmount = '';
  String fluidType = '';
  String urineOutput = ''; // ml or 'LEAK' or empty
  bool cantMeasure = false;
  int? bladderSensation; // 0–4 or null
  bool pad = false;
}

class _BladderDiaryScreenState extends State<BladderDiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 3 days × 24 time slots
  static const List<String> _timeSlotKeys = [
    'time6am', 'time7am', 'time8am', 'time9am', 'time10am', 'time11am',
    'timeMidday', 'time1pm', 'time2pm', 'time3pm', 'time4pm', 'time5pm',
    'time6pm', 'time7pm', 'time8pm', 'time9pm', 'time10pm', 'time11pm',
    'timeMidnight', 'time1am', 'time2am', 'time3am', 'time4am', 'time5am',
  ];

  // data[day][slotIndex]
  late List<List<BladderDiaryEntry>> _data;

  // bed/wake markers per day: map of slotIndex -> 'BED' or 'WOKE'
  late List<Map<int, String>> _markers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _data = List.generate(3, (_) =>
        List.generate(_timeSlotKeys.length, (_) => BladderDiaryEntry()));
    _markers = List.generate(3, (_) => {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<int, String> _getSensationLabels(AppLocalizations l10n) {
    return {
      0: l10n.sensation0,
      1: l10n.sensation1,
      2: l10n.sensation2,
      3: l10n.sensation3,
      4: l10n.sensation4,
    };
  }

  String _getLocalizedTimeSlot(int slot, AppLocalizations l10n) {
    switch (_timeSlotKeys[slot]) {
      case 'time6am': return l10n.time6am;
      case 'time7am': return l10n.time7am;
      case 'time8am': return l10n.time8am;
      case 'time9am': return l10n.time9am;
      case 'time10am': return l10n.time10am;
      case 'time11am': return l10n.time11am;
      case 'timeMidday': return l10n.timeMidday;
      case 'time1pm': return l10n.time1pm;
      case 'time2pm': return l10n.time2pm;
      case 'time3pm': return l10n.time3pm;
      case 'time4pm': return l10n.time4pm;
      case 'time5pm': return l10n.time5pm;
      case 'time6pm': return l10n.time6pm;
      case 'time7pm': return l10n.time7pm;
      case 'time8pm': return l10n.time8pm;
      case 'time9pm': return l10n.time9pm;
      case 'time10pm': return l10n.time10pm;
      case 'time11pm': return l10n.time11pm;
      case 'timeMidnight': return l10n.timeMidnight;
      case 'time1am': return l10n.time1am;
      case 'time2am': return l10n.time2am;
      case 'time3am': return l10n.time3am;
      case 'time4am': return l10n.time4am;
      case 'time5am': return l10n.time5am;
      default: return '';
    }
  }

  void _showSensationPicker(int day, int slot) {
    final l10n = AppLocalizations.of(context)!;
    final sensationLabels = _getSensationLabels(l10n);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bladderSensation,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${l10n.selectCodeFor} ${_getLocalizedTimeSlot(slot, l10n)}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            ...List.generate(5, (i) {
              final isSelected = _data[day][slot].bladderSensation == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _data[day][slot].bladderSensation = i);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00897B).withOpacity(0.12)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00897B)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(sensationLabels[i]!,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF00897B)
                              : Colors.black87)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _toggleMarker(int day, int slot, String marker) {
    setState(() {
      if (_markers[day][slot] == marker) {
        _markers[day].remove(slot);
      } else {
        _markers[day][slot] = marker;
      }
    });
  }

  Widget _buildDayTab(int day) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _timeSlotKeys.length,
      itemBuilder: (context, slot) {
        final entry = _data[day][slot];
        final marker = _markers[day][slot];
        final hasData = entry.fluidAmount.isNotEmpty ||
            entry.fluidType.isNotEmpty ||
            entry.urineOutput.isNotEmpty ||
            entry.cantMeasure ||
            entry.bladderSensation != null ||
            entry.pad ||
            marker != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: hasData ? 2 : 1,
          color: hasData ? Colors.white : Colors.grey.shade50,
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            leading: Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: hasData
                    ? const Color(0xFF00897B).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(_getLocalizedTimeSlot(slot, l10n),
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hasData
                            ? const Color(0xFF00897B)
                            : Colors.grey)),
              ),
            ),
            title: _buildSlotSummary(entry, marker),
            children: [
              // BED / WOKE markers
              Row(
                children: [
                  _markerChip('BED', day, slot, marker),
                  const SizedBox(width: 8),
                  _markerChip('WOKE', day, slot, marker),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Fluids
              Text(l10n.drinks,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _miniField(
                      label: l10n.amountMlCups,
                      value: entry.fluidAmount,
                      onChanged: (v) =>
                          setState(() => entry.fluidAmount = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _miniField(
                      label: l10n.fluidType,
                      value: entry.fluidType,
                      onChanged: (v) =>
                          setState(() => entry.fluidType = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Urine output
              Text(l10n.urineOutput,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _miniField(
                      label: l10n.mlOrLeak,
                      value: entry.urineOutput,
                      enabled: !entry.cantMeasure,
                      onChanged: (v) =>
                          setState(() => entry.urineOutput = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Can't measure tick
                  GestureDetector(
                    onTap: () => setState(() {
                      entry.cantMeasure = !entry.cantMeasure;
                      if (entry.cantMeasure) entry.urineOutput = '';
                    }),
                    child: Row(
                      children: [
                        _checkbox(entry.cantMeasure),
                        const SizedBox(width: 4),
                        Text(l10n.cantMeasure,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bladder sensation + Pad
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.bladderSensation,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _showSensationPicker(day, slot),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: entry.bladderSensation != null
                                      ? const Color(0xFF00897B)
                                      : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: entry.bladderSensation != null
                                  ? const Color(0xFF00897B).withOpacity(0.05)
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.bladderSensation != null
                                        ? '${l10n.code} ${entry.bladderSensation}'
                                        : l10n.tapToSelect,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: entry.bladderSensation != null
                                            ? const Color(0xFF00897B)
                                            : Colors.grey),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(l10n.pad,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => entry.pad = !entry.pad),
                        child: _checkbox(entry.pad, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlotSummary(BladderDiaryEntry entry, String? marker) {
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[];
    if (marker != null) parts.add(marker);
    if (entry.fluidAmount.isNotEmpty || entry.fluidType.isNotEmpty) {
      parts.add('💧 ${entry.fluidAmount} ${entry.fluidType}'.trim());
    }
    if (entry.cantMeasure) {
      parts.add('🚽 ✓');
    } else if (entry.urineOutput.isNotEmpty) {
      parts.add('🚽 ${entry.urineOutput}');
    }
    if (entry.bladderSensation != null) {
      parts.add('${l10n.sensationAbbr}${entry.bladderSensation}');
    }
    if (entry.pad) parts.add('🟦 ${l10n.pad}');

    return Text(
      parts.isEmpty ? l10n.tapToAddEntry : parts.join('  ·  '),
      style: GoogleFonts.poppins(
          fontSize: 11,
          color: parts.isEmpty ? Colors.grey.shade400 : Colors.black87),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _markerChip(String label, int day, int slot, String? current) {
    final l10n = AppLocalizations.of(context)!;
    final active = current == label;
    final displayLabel = label == 'BED' ? l10n.bed : l10n.woke;
    return GestureDetector(
      onTap: () => _toggleMarker(day, slot, label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00897B)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active
                  ? const Color(0xFF00897B)
                  : Colors.grey.shade300),
        ),
        child: Text(displayLabel,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.grey.shade700)),
      ),
    );
  }

  Widget _miniField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: enabled,
      style: GoogleFonts.poppins(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 11),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: !enabled,
        fillColor: Colors.grey.shade100,
      ),
      onChanged: onChanged,
    );
  }

  Widget _checkbox(bool value, {double size = 20}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: value ? const Color(0xFF00897B) : Colors.transparent,
        border: Border.all(
            color: value ? const Color(0xFF00897B) : Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: value
          ? Icon(Icons.check, size: size * 0.7, color: Colors.white)
          : null,
    );
  }

  void _showSensationGuide() {
    final l10n = AppLocalizations.of(context)!;
    final sensationLabels = _getSensationLabels(l10n);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.sensationCodesTitle,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sensationLabels.entries
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('${e.value}',
                        style: GoogleFonts.poppins(fontSize: 12)),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close,
                style: GoogleFonts.poppins(color: const Color(0xFF00897B))),
          )
        ],
      ),
    );
  }

  void _submitDiary() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.diarySubmittedTitle,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: Color(0xFF00897B), size: 56),
            const SizedBox(height: 12),
            Text(
              l10n.diarySubmittedMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.continueText,
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      appBar: AppBar(
        title: Text(l10n.bladderDiaryTitle,
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF00897B),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: l10n.sensationCodes,
            onPressed: _showSensationGuide,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 13),
          tabs: [
            Tab(text: l10n.day1),
            Tab(text: l10n.day2),
            Tab(text: l10n.day3),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDayTab(0),
          _buildDayTab(1),
          _buildDayTab(2),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submitDiary,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00897B),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(l10n.submitDiary,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}