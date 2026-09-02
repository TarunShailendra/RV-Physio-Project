/// Days in a given month, accounting for leap years.
///
/// The signup date-of-birth picker offered 1..31 for every month and handed
/// the result to DateTime, which normalises overflow: 31 February became
/// 3 March with nothing shown to the patient.
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
