import '../../assessment/models/ipaq_model.dart';

/// Body position a pelvic floor contraction is performed in.
enum ExercisePosition { supine, sitting, standing }

/// One line of a protocol's prescription: an exercise plus its dose.
///
/// [reps] is null for exercises the document prescribes without a count, such
/// as diaphragmatic breathing. [holdSeconds] is null where the document says
/// "no hold" or gives no hold at all. [relaxSeconds] applies only to the slow
/// pelvic floor holds, which are the only items given an explicit rest.
class PrescribedItem {
  const PrescribedItem({
    required this.exerciseKey,
    required this.sets,
    this.position,
    this.reps,
    this.holdSeconds,
    this.relaxSeconds,
  });

  final String exerciseKey;
  final ExercisePosition? position;
  final int? reps;
  final int? holdSeconds;
  final int? relaxSeconds;
  final int sets;
}

/// A two-week stage of a protocol.
class ProtocolWeekBlock {
  const ProtocolWeekBlock({
    required this.startWeek,
    required this.endWeek,
    required this.daysPerWeek,
    required this.progressionFocus,
    required this.items,
  });

  final int startWeek;
  final int endWeek;

  /// Days of the week the patient trains. Three to five, never seven.
  final int daysPerWeek;
  final String progressionFocus;
  final List<PrescribedItem> items;

  bool covers(int week) => week >= startWeek && week <= endWeek;
}

/// One cell of the severity x activity matrix from the protocol document.
class Protocol {
  const Protocol({
    required this.id,
    required this.severityBand,
    required this.activity,
    required this.intensity,
    required this.timeRange,
    required this.type,
    required this.blocks,
  });

  final String id;
  final String severityBand;

  /// The activity level this table was written for.
  ///
  /// Descriptive, not a selector: [protocolFor] matches on the id. It is
  /// `high` on the severe protocol because that is the only severe table the
  /// document provides, and the same table serves moderate and low activity
  /// patients too.
  final IPAQActivityLevel activity;
  final String intensity;
  final String timeRange;
  final String type;
  final List<ProtocolWeekBlock> blocks;

  ProtocolWeekBlock blockForWeek(int week) {
    for (final block in blocks) {
      if (block.covers(week)) return block;
    }
    throw ArgumentError.value(week, 'week', 'Outside protocol $id');
  }
}
