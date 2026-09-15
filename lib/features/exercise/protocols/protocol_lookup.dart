import '../../assessment/models/ipaq_model.dart';
import '../models/protocol.dart';
import 'protocol_tables.dart';

/// The protocol for a patient, from their ICIQ severity band and IPAQ
/// activity level.
///
/// The document defines seven of the nine matrix cells: Severe+Moderate and
/// Severe+Low have no table, and all three severe cells therefore use the one
/// severe protocol, which is already the most conservative in the document.
///
/// A null band or activity means the patient has not finished onboarding. The
/// route guard sends them back to the questionnaires, but rather than throw,
/// this falls back to the severe protocol: a data gap must never hand a
/// patient a harder prescription than they should receive.
Protocol protocolFor({String? severityBand, IPAQActivityLevel? activity}) {
  if (severityBand == null || activity == null) return _severe;
  if (severityBand == 'severe') return _severe;

  final suffix = switch (activity) {
    IPAQActivityLevel.high => 'high',
    IPAQActivityLevel.moderate => 'moderate',
    IPAQActivityLevel.low => 'low',
  };
  final id = '${severityBand}_$suffix';
  for (final protocol in allProtocols) {
    if (protocol.id == id) return protocol;
  }
  return _severe;
}

Protocol get _severe => allProtocols.firstWhere((p) => p.id == 'severe');
