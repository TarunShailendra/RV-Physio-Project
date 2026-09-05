// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ಟೆಲಿರಿಹ್ಯಾಬ್ ಅಪ್ಲಿಕೇಶನ್';

  @override
  String get welcomeBack => 'ಮರಳಿ ಸ್ವಾಗತ';

  @override
  String get signInToContinue => 'ಮುಂದುವರಿಯಲು ಸೈನ್ ಇನ್ ಮಾಡಿ';

  @override
  String get email => 'ಇಮೇಲ್';

  @override
  String get password => 'ಪಾಸ್ವರ್ಡ್';

  @override
  String get login => 'ಲಾಗಿನ್';

  @override
  String get signUp => 'ಸೈನ್ ಅಪ್';

  @override
  String get dontHaveAccount => 'ಖಾತೆ ಇಲ್ಲವೇ? ಸೈನ್ ಅಪ್ ಮಾಡಿ';

  @override
  String get continueWithGoogle => 'Google ಮೂಲಕ ಮುಂದುವರಿಯಿರಿ';

  @override
  String get googleSignInCancelled => 'Google ಸೈನ್ ಇನ್ ರದ್ದುಪಡಿಸಲಾಗಿದೆ';

  @override
  String get googleSignInFailed =>
      'Google ಸೈನ್ ಇನ್ ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get createAccount => 'ನಿಮ್ಮ ಖಾತೆಯನ್ನು ರಚಿಸಿ';

  @override
  String get backToLogin => 'ಲಾಗಿನ್ ಪುಟಕ್ಕೆ ಹಿಂತಿರುಗಿ';

  @override
  String get enterYourName => 'ನಿಮ್ಮ ಹೆಸರನ್ನು ನಮೂದಿಸಿ';

  @override
  String get enterYourEmail => 'ನಿಮ್ಮ ಇಮೇಲ್ ನಮೂದಿಸಿ';

  @override
  String get enterValidEmail => 'ಮಾನ್ಯ ಇಮೇಲ್ ನಮೂದಿಸಿ';

  @override
  String get enterPassword => 'ಪಾಸ್ವರ್ಡ್ ನಮೂದಿಸಿ';

  @override
  String get passwordMinLength => 'ಪಾಸ್ವರ್ಡ್ ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳಾಗಿರಬೇಕು';

  @override
  String get enterPhoneNumber => 'ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';

  @override
  String get enterValidPhone => 'ಮಾನ್ಯ ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';

  @override
  String get invalidPhoneFormat =>
      'ಫೋನ್ ಸಂಖ್ಯೆಯಲ್ಲಿ ಕೇವಲ ಅಂಕೆಗಳಿರಬೇಕೆಂದು ಖಚಿತಪಡಿಸಿ ಮತ್ತು 10 ಅಂಕೆಗಳಾಗಿರಬೇಕು';

  @override
  String get invalidNameFormat =>
      'ಹೆಸರಿನಲ್ಲಿ ಕೇವಲ ಅಕ್ಷರಗಳು ಮತ್ತು ಜಾಗಗಳು ಮಾತ್ರ ಇರಬೇಕು';

  @override
  String get enterValidDob =>
      'ನಿಮ್ಮ ಜನ್ಮ ದಿನಾಂಕವನ್ನು DD/MM/YYYY ಸ್ವರೂಪದಲ್ಲಿ ನಮೂದಿಸಿ';

  @override
  String get invalidDobFormat =>
      'DD/MM/YYYY ಸ್ವರೂಪದಲ್ಲಿ ಮಾನ್ಯ ದಿನಾಂಕವನ್ನು ನಮೂದಿಸಿ';

  @override
  String get selectAge => 'ನಿಮ್ಮ ವಯಸ್ಸನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get dashboard => 'ಡ್ಯಾಶ್ಬೋರ್ಡ್';

  @override
  String get thisWeek => 'ಈ ವಾರ';

  @override
  String get adherence => 'ಅನುಸರಣೆ';

  @override
  String get exercises => 'ವ್ಯಾಯಾಮಗಳು';

  @override
  String get logBladderDiary => 'ಮೂತ್ರಕೋಶ ಡೈರಿ ದಾಖಲಿಸಿ';

  @override
  String get startExercise => 'ಇಂದಿನ ವ್ಯಾಯಾಮ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get weeklyAdherence => 'ಸಾಪ್ತಾಹಿಕ ಅನುಸರಣೆ';

  @override
  String weekXofY(Object currentWeek, Object totalWeeks) {
    return 'ವಾರ $currentWeek / $totalWeeks — ಮುಂದುವರಿಸಿ!';
  }

  @override
  String week(Object week) {
    return 'W$week';
  }

  @override
  String iciqComparison(Object post, Object pre) {
    return 'ಮೊದಲು: $pre → ನಂತರ: $post';
  }

  @override
  String get user => 'ಬಳಕೆದಾರ';

  @override
  String get bengaluru => 'ಬೆಂಗಳೂರು';

  @override
  String get profileDetails => 'ಪ್ರೊಫೈಲ್ ವಿವರಗಳು';

  @override
  String get healthInfo => 'ಆರೋಗ್ಯ ಮಾಹಿತಿ';

  @override
  String get symptomDuration => 'ರೋಗಲಕ್ಷಣದ ಅವಧಿ';

  @override
  String get months => 'ತಿಂಗಳುಗಳು';

  @override
  String get soughtTreatment => 'ಚಿಕಿತ್ಸೆ ಪಡೆದಿದ್ದೀರಾ?';

  @override
  String get yes => 'ಹೌದು';

  @override
  String get no => 'ಇಲ್ಲ';

  @override
  String get editProfile => 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ';

  @override
  String get logOut => 'ಲಾಗ್ ಔಟ್';

  @override
  String get profileSetup => 'ಪ್ರೊಫೈಲ್ ಸೆಟಪ್';

  @override
  String get profileStep1 => 'ಹಂತ 1 of 3: ನಿಮ್ಮ ಪ್ರೊಫೈಲ್';

  @override
  String get enterYourCity => 'ನಿಮ್ಮ ನಗರವನ್ನು ನಮೂದಿಸಿ';

  @override
  String get enterYourOccupation => 'ನಿಮ್ಮ ಉದ್ಯೋಗವನ್ನು ನಮೂದಿಸಿ';

  @override
  String get selectIncontinenceType => 'ಮೂತ್ರದ ಅಸಂಯಮದ ಪ್ರಕಾರವನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get symptomDurationMonths => 'ರೋಗಲಕ್ಷಣದ ಅವಧಿ (ತಿಂಗಳುಗಳಲ್ಲಿ)';

  @override
  String get enterValidDuration => 'ತಿಂಗಳುಗಳಲ್ಲಿ ಅವಧಿಯನ್ನು ನಮೂದಿಸಿ';

  @override
  String get durationCannotBeNegative => 'ಅವಧಿ ಋಣಾತ್ಮಕವಾಗಿರಬಾರದು';

  @override
  String get haveYouSoughtTreatment => 'ನೀವು ಚಿಕಿತ್ಸೆ ಪಡೆದಿದ್ದೀರಾ?';

  @override
  String get continueText => 'ಮುಂದುವರಿಯಿರಿ';

  @override
  String get stressIncontinence => 'ಸ್ಟ್ರೆಸ್';

  @override
  String get urgeIncontinence => 'ಅರ್ಜ್';

  @override
  String get mixedIncontinence => 'ಮಿಕ್ಸ್ಡ್';

  @override
  String get unknownIncontinence => 'ಅಜ್ಞಾತ';

  @override
  String get education => 'ಶಿಕ್ಷಣ';

  @override
  String get whatIsUrinaryIncontinence => 'ಮೂತ್ರದ ಅಸಂಯಮ ಎಂದರೇನು?';

  @override
  String get understandingBasics => 'ಮೂಲಭೂತ ತಿಳುವಳಿಕೆ';

  @override
  String get typesOfIncontinence => 'ಮೂತ್ರದ ಅಸಂಯಮದ ವಿಧಗಳು';

  @override
  String get stressUrgeMixed => 'ಸ್ಟ್ರೆಸ್, ಅರ್ಜ್ ಮತ್ತು ಮಿಕ್ಸ್ಡ್';

  @override
  String get pelvicFloorMuscles => 'ಪೆಲ್ವಿಕ್ ಫ್ಲೋರ್ ಸ್ನಾಯುಗಳ ವಿವರಣೆ';

  @override
  String get anatomyFunction => 'ಶರೀರ ರಚನೆ ಮತ್ತು ಕಾರ್ಯ';

  @override
  String get howPfmtWorks => 'ಪಿಎಫ್ಎಂಟಿ ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get scienceBehindExercises => 'ವ್ಯಾಯಾಮಗಳ ಹಿಂದಿನ ವಿಜ್ಞಾನ';

  @override
  String get lifestyleChanges => 'ಸಹಾಯಕ ಜೀವನಶೈಲಿ ಬದಲಾವಣೆಗಳು';

  @override
  String get dietFluidHabits => 'ಆಹಾರ, ದ್ರವ ಸೇವನೆ ಮತ್ತು ಅಭ್ಯಾಸಗಳು';

  @override
  String get whenToSeeDoctor => 'ವೈದ್ಯರನ್ನು ಯಾವಾಗ ಭೇಟಿ ಮಾಡಬೇಕು';

  @override
  String get redFlagsReferrals => 'ಎಚ್ಚರಿಕೆ ಸೂಚನೆಗಳು ಮತ್ತು ಉಲ್ಲೇಖಗಳು';

  @override
  String get whatIsUrinaryIncontinenceDetail =>
      'ಮೂತ್ರದ ಅಸಂಯಮ ಎಂದರೆ ಅನೈಚ್ಛಿಕ ಮೂತ್ರ ಸೋರಿಕೆ. ಇದು ವಿಶ್ವಾದ್ಯಂತ ಲಕ್ಷಾಂತರ ಜನರ ಮೇಲೆ ಪರಿಣಾಮ ಬೀರುವ ಸಾಮಾನ್ಯ ಸಮಸ್ಯೆಯಾಗಿದೆ. ಕಾರಣವನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳುವುದು ಪರಿಣಾಮಕಾರಿ ನಿರ್ವಹಣೆಯ ಮೊದಲ ಹೆಜ್ಜೆ. ಈ ವಿಭಾಗವು ಮೂತ್ರದ ಅಸಂಯಮ ಏನು ಮತ್ತು ಅದು ಏಕೆ ಸಂಭವಿಸುತ್ತದೆ ಎಂಬುದರ ಮೂಲಭೂತ ಅಂಶಗಳನ್ನು ತಿಳಿಸುತ್ತದೆ.';

  @override
  String get typesOfIncontinenceDetail =>
      'ಮೂತ್ರದ ಅಸಂಯಮದ ಹಲವಾರು ವಿಧಗಳಿವೆ: ಸ್ಟ್ರೆಸ್ ಅಸಂಯಮ (ಕೆಮ್ಮು, ಸೀನು ಅಥವಾ ವ್ಯಾಯಾಮದ ಸಮಯದಲ್ಲಿ ಸೋರಿಕೆ), ಅರ್ಜ್ ಅಸಂಯಮ (ಹಠಾತ್, ತೀವ್ರ ಮೂತ್ರ ವಿಸರ್ಜನೆಯ ಪ್ರಚೋದನೆ ಮತ್ತು ನಂತರ ಸೋರಿಕೆ), ಮತ್ತು ಮಿಕ್ಸ್ಡ್ ಅಸಂಯಮ (ಎರಡರ ಸಂಯೋಜನೆ). ಪ್ರತಿಯೊಂದು ವಿಧಕ್ಕೂ ವಿಭಿನ್ನ ಚಿಕಿತ್ಸಾ ವಿಧಾನಗಳು ಬೇಕಾಗಬಹುದು.';

  @override
  String get pelvicFloorMusclesDetail =>
      'ಪೆಲ್ವಿಕ್ ಫ್ಲೋರ್ ಸ್ನಾಯುಗಳು ಶ್ರೋಣಿಯ ಕೆಳಭಾಗದಲ್ಲಿ ಬೆಂಬಲಿತ ಜಾಲರಿಯನ್ನು ರೂಪಿಸುತ್ತವೆ. ಅವು ಮೂತ್ರಕೋಶ, ಕರುಳು ಮತ್ತು ಗರ್ಭಕೋಶವನ್ನು ಬೆಂಬಲಿಸುತ್ತವೆ. ಈ ಸ್ನಾಯುಗಳಲ್ಲಿನ ದೌರ್ಬಲ್ಯವು ಅಸಂಯಮಕ್ಕೆ ಕಾರಣವಾಗಬಹುದು. ಈ ಸ್ನಾಯುಗಳನ್ನು ಸರಿಯಾಗಿ ಗುರುತಿಸಲು ಮತ್ತು ಸಂಕುಚಿಸಲು ಕಲಿಯುವುದು ಪೆಲ್ವಿಕ್ ಫ್ಲೋರ್ ತರಬೇತಿಯ ಪ್ರಮುಖ ಅಂಶವಾಗಿದೆ.';

  @override
  String get howPfmtWorksDetail =>
      'ಪೆಲ್ವಿಕ್ ಫ್ಲೋರ್ ಸ್ನಾಯು ತರಬೇತಿ (ಪಿಎಫ್ಎಂಟಿ) ಪುನರಾವರ್ತಿತ ಸಂಕೋಚನಗಳ ಮೂಲಕ ಪೆಲ್ವಿಕ್ ಫ್ಲೋರ್ ಸ್ನಾಯುಗಳನ್ನು ಬಲಪಡಿಸುತ್ತದೆ. ನಿಯಮಿತ ವ್ಯಾಯಾಮವು ಸ್ನಾಯು ಟೋನ್, ಸಹಿಷ್ಣುತೆ ಮತ್ತು ಸಮನ್ವಯವನ್ನು ಸುಧಾರಿಸುತ್ತದೆ. ಕಾಲಾನಂತರದಲ್ಲಿ, ಇದು ಸೋರಿಕೆಯ ಪ್ರಸಂಗಗಳನ್ನು ಕಡಿಮೆ ಮಾಡಬಹುದು ಅಥವಾ ತೊಡೆದುಹಾಕಬಹುದು.';

  @override
  String get lifestyleChangesDetail =>
      'ಸರಳ ಜೀವನಶೈಲಿ ಹೊಂದಾಣಿಕೆಗಳು ಮೂತ್ರಕೋಶ ನಿಯಂತ್ರಣವನ್ನು ಗಮನಾರ್ಹವಾಗಿ ಸುಧಾರಿಸಬಹುದು: ಆರೋಗ್ಯಕರ ತೂಕವನ್ನು ಕಾಪಾಡಿಕೊಳ್ಳಿ, ಮೂತ್ರಕೋಶ ಉದ್ರೇಕಕಾರಿಗಳನ್ನು ತಪ್ಪಿಸಿ (ಕೆಫೀನ್, ಮಸಾಲೆಯುಕ್ತ ಆಹಾರಗಳು), ಸಾಕಷ್ಟು ಆದರೆ ಅತಿಯಾದ ದ್ರವ ಸೇವನೆ ಮಾಡಬೇಡಿ, ಮತ್ತು ಉತ್ತಮ ಬಾತ್ರೂಮ್ ಅಭ್ಯಾಸಗಳನ್ನು ಅನುಸರಿಸಿ.';

  @override
  String get whenToSeeDoctorDetail =>
      'ಅಸಂಯಮವು ನಿಮ್ಮ ಜೀವನದ ಗುಣಮಟ್ಟದ ಮೇಲೆ ಪರಿಣಾಮ ಬೀರಿದರೆ, ನಿಮಗೆ ನೋವು ಅಥವಾ ಮೂತ್ರದಲ್ಲಿ ರಕ್ತ ಕಂಡುಬಂದರೆ, ರೋಗಲಕ್ಷಣಗಳು ಉಲ್ಬಣಗೊಂಡರೆ, ಅಥವಾ ಕಾರಣದ ಬಗ್ಗೆ ನಿಮಗೆ ಖಚಿತವಿಲ್ಲದಿದ್ದರೆ ಆರೋಗ್ಯ ವೃತ್ತಿಪರರನ್ನು ಸಂಪರ್ಕಿಸಿ. ಆರಂಭಿಕ ಮೌಲ್ಯಮಾಪನವು ಉತ್ತಮ ಫಲಿತಾಂಶಗಳಿಗೆ ಕಾರಣವಾಗುತ್ತದೆ.';

  @override
  String weekNumber(Object week) {
    return 'ವಾರ $week';
  }

  @override
  String weekProgress(Object currentWeek, Object totalWeeks) {
    return 'ವಾರ $currentWeek / $totalWeeks';
  }

  @override
  String weekDifficulty(Object difficulty, Object weekNumber) {
    return 'ವಾರ $weekNumber — $difficulty';
  }

  @override
  String completedCount(Object completed, Object total) {
    return '$completed / $total ಪೂರ್ಣಗೊಂಡಿದೆ';
  }

  @override
  String get reps => 'ಪುನರಾವರ್ತನೆಗಳು';

  @override
  String get hold => 'ಹಿಡಿದಿಡಿ';

  @override
  String get rest => 'ವಿಶ್ರಾಂತಿ';

  @override
  String seconds(Object seconds) {
    return '$seconds ಸೆಕೆಂಡುಗಳು';
  }

  @override
  String minutesAndSeconds(Object minutes, Object seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get completeSession => 'ಸೆಷನ್ ಪೂರ್ಣಗೊಳಿಸಿ';

  @override
  String get iciqTitle => 'ICIQ ಮೌಲ್ಯಮಾಪನ';

  @override
  String get iciqQ1 =>
      'ಪ್ರಶ್ನೆ 1. ನೀವು ಎಷ್ಟು ಬಾರಿ ಮೂತ್ರ ಸೋರಿಕೆ ಅನುಭವಿಸುತ್ತೀರಿ?';

  @override
  String get iciqQ1Subtitle => 'ನಿಮ್ಮ ವಾರಕ್ಕೆ ಸೂಕ್ತವಾದ ಆಯ್ಕೆಯನ್ನು ಆರಿಸಿ.';

  @override
  String get iciqQ2 => 'ಪ್ರಶ್ನೆ 2. ಸಾಮಾನ್ಯವಾಗಿ ಎಷ್ಟು ಮೂತ್ರ ಸೋರಿಕೆಯಾಗುತ್ತದೆ?';

  @override
  String get iciqQ2Subtitle => 'ಸಾಮಾನ್ಯ ಪ್ರಮಾಣವನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get iciqQ3 =>
      'ಪ್ರಶ್ನೆ 3. ಒಟ್ಟಾರೆಯಾಗಿ, ಮೂತ್ರ ಸೋರಿಕೆ ನಿಮ್ಮ ದೈನಂದಿನ ಜೀವನದಲ್ಲಿ ಎಷ್ಟು ತೊಂದರೆ ಉಂಟುಮಾಡುತ್ತದೆ?';

  @override
  String get iciqQ3Subtitle =>
      '0 ಎಂದರೆ ಯಾವುದೇ ತೊಂದರೆ ಇಲ್ಲ, 10 ಎಂದರೆ ತುಂಬಾ ತೊಂದರೆ.';

  @override
  String get iciqQ4 => 'ಪ್ರಶ್ನೆ 4-6. ಯಾವಾಗ ಮೂತ್ರ ಸೋರಿಕೆಯಾಗುತ್ತದೆ?';

  @override
  String get iciqQ4Subtitle => 'ಎಲ್ಲಾ ಅನ್ವಯಿಸುವ ಆಯ್ಕೆಗಳನ್ನು ಆರಿಸಿ.';

  @override
  String get iciqImpactScore => 'ಪ್ರಭಾವ ಸ್ಕೋರ್';

  @override
  String get iciqScore => 'ಸ್ಕೋರ್';

  @override
  String get iciqSeverity => 'ತೀವ್ರತೆ';

  @override
  String get iciqResultTitle => 'ಐಸಿಐಕ್ಯೂ ಫಲಿತಾಂಶ';

  @override
  String get iciqConsultDoctor =>
      'ಮುಂದುವರಿಯುವ ಮೊದಲು ವೈದ್ಯಕೀಯ ವೃತ್ತಿಪರರನ್ನು ಸಂಪರ್ಕಿಸಿ';

  @override
  String get submit => 'ಸಲ್ಲಿಸು';

  @override
  String get never => 'ಎಂದಿಗೂ';

  @override
  String get onceAWeekOrLess => 'ವಾರಕ್ಕೊಮ್ಮೆ ಅಥವಾ ಕಡಿಮೆ';

  @override
  String get twoOrThreeTimesAWeek => 'ವಾರಕ್ಕೆ ಎರಡು ಅಥವಾ ಮೂರು ಬಾರಿ';

  @override
  String get onceADay => 'ದಿನಕ್ಕೊಮ್ಮೆ';

  @override
  String get severalTimesADay => 'ದಿನಕ್ಕೆ ಹಲವಾರು ಬಾರಿ';

  @override
  String get allTheTime => 'ಯಾವಾಗಲೂ';

  @override
  String get none => 'ಇಲ್ಲ';

  @override
  String get smallAmount => 'ಸ್ವಲ್ಪ ಪ್ರಮಾಣ';

  @override
  String get moderateAmount => 'ಮಧ್ಯಮ ಪ್ರಮಾಣ';

  @override
  String get largeAmount => 'ಹೆಚ್ಚಿನ ಪ್ರಮಾಣ';

  @override
  String get severityNone => 'ಇಲ್ಲ';

  @override
  String get severityMild => 'ಸೌಮ್ಯ';

  @override
  String get severityModerate => 'ಮಧ್ಯಮ';

  @override
  String get severitySevere => 'ತೀವ್ರ';

  @override
  String get severityVerySevere => 'ಅತಿ ತೀವ್ರ';

  @override
  String get leaksBeforeToilet => 'ಶೌಚಾಲಯ ತಲುಪುವ ಮೊದಲೇ ಸೋರಿಕೆ';

  @override
  String get leaksWhenCoughSneeze => 'ಕೆಮ್ಮು ಅಥವಾ ಸೀನುವಾಗ ಸೋರಿಕೆ';

  @override
  String get leaksDuringActivity => 'ದೈಹಿಕ ಚಟುವಟಿಕೆಯ ಸಮಯದಲ್ಲಿ ಸೋರಿಕೆ';

  @override
  String get ipaqTitle => 'IPAQ ತಪಾಸಣೆ';

  @override
  String get ipaqInstruction => 'ಕಳೆದ 7 ದಿನಗಳ ದೈಹಿಕ ಚಟುವಟಿಕೆಗಳ ಬಗ್ಗೆ ಯೋಚಿಸಿ.';

  @override
  String get ipaqQ1 =>
      'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ನೀವು ದಿನದಲ್ಲಿ ಎಷ್ಟು ಸಮಯ ಕುಳಿತುಕೊಳ್ಳುತ್ತೀರಿ? ಕೆಲಸ, ಮನೆ, ಕೋರ್ಸ್ ಕೆಲಸ ಮತ್ತು ವಿರಾಮ (ಡೆಸ್ಕ್, ಓದುವಿಕೆ, ಟಿವಿ) ಸೇರಿಸಿ.';

  @override
  String get ipaqQ2 =>
      'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಎಷ್ಟು ದಿನಗಳು ನೀವು ಕನಿಷ್ಠ 10 ನಿಮಿಷಗಳ ಕಾಲ ನಡೆದಿದ್ದೀರಿ? (ಕೆಲಸ, ಮನೆ, ಪ್ರಯಾಣ, ಮನರಂಜನೆ, ಕ್ರೀಡೆ, ವ್ಯಾಯಾಮ ಅಥವಾ ವಿರಾಮದಲ್ಲಿ ನಡೆಯುವಿಕೆ ಸೇರಿದೆ.)';

  @override
  String get ipaqQ2DurationPrompt =>
      'ಆ ದಿನಗಳಲ್ಲಿ ಸಾಮಾನ್ಯವಾಗಿ ಎಷ್ಟು ಸಮಯ ನಡೆದಿದ್ದೀರಿ?';

  @override
  String get ipaqQ3 =>
      'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಎಷ್ಟು ದಿನಗಳು ನೀವು ಮಧ್ಯಮ ದೈಹಿಕ ಚಟುವಟಿಕೆಗಳನ್ನು ಮಾಡಿದ್ದೀರಿ? ಉದಾ: ತೋಟಗಾರಿಕೆ, ಸ್ವಚ್ಛತೆ, ಸಾಮಾನ್ಯ ವೇಗದಲ್ಲಿ ಸೈಕ್ಲಿಂಗ್, ಈಜು ಅಥವಾ ಇತರ ಫಿಟ್ನೆಸ್ ಚಟುವಟಿಕೆಗಳು. (ಕನಿಷ್ಠ 10 ನಿಮಿಷಗಳು. ನಡೆಯುವಿಕೆಯನ್ನು ಸೇರಿಸಬೇಡಿ.)';

  @override
  String get ipaqQ3DurationPrompt =>
      'ಆ ದಿನಗಳಲ್ಲಿ ಸಾಮಾನ್ಯವಾಗಿ ಎಷ್ಟು ಸಮಯ ಮಧ್ಯಮ ಚಟುವಟಿಕೆಗಳನ್ನು ಮಾಡುತ್ತಿದ್ದೀರಿ?';

  @override
  String get ipaqQ4 =>
      'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಎಷ್ಟು ದಿನಗಳು ನೀವು ತೀವ್ರ ದೈಹಿಕ ಚಟುವಟಿಕೆಗಳನ್ನು ಮಾಡಿದ್ದೀರಿ? ಉದಾ: ಭಾರ ಎತ್ತುವುದು, ಭಾರೀ ತೋಟಗಾರಿಕೆ/ನಿರ್ಮಾಣ ಕೆಲಸ, ಮರ ಕಡಿಯುವುದು, ಏರೋಬಿಕ್ಸ್, ಜಾಗಿಂಗ್/ಓಟ, ಅಥವಾ ವೇಗವಾಗಿ ಸೈಕ್ಲಿಂಗ್. (ಕನಿಷ್ಠ 10 ನಿಮಿಷಗಳು.)';

  @override
  String get ipaqQ4DurationPrompt =>
      'ಆ ದಿನಗಳಲ್ಲಿ ಸಾಮಾನ್ಯವಾಗಿ ಎಷ್ಟು ಸಮಯ ತೀವ್ರ ಚಟುವಟಿಕೆಗಳನ್ನು ಮಾಡುತ್ತಿದ್ದೀರಿ?';

  @override
  String get ipaqQ5 =>
      'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ಎಷ್ಟು ದಿನಗಳು ನೀವು ಕನಿಷ್ಠ 10 ನಿಮಿಷಗಳ ಕಾಲ ನಡೆದಿದ್ದೀರಿ? (ಸ್ಥಳದಿಂದ ಸ್ಥಳಕ್ಕೆ ಪ್ರಯಾಣಿಸಲು ಅಥವಾ ಕೇವಲ ಮನರಂಜನೆ, ಕ್ರೀಡೆ, ವ್ಯಾಯಾಮ ಅಥವಾ ವಿರಾಮಕ್ಕಾಗಿ ನಡೆಯುವಿಕೆ.)';

  @override
  String get ipaqQ5DurationPrompt =>
      'ಆ ದಿನಗಳಲ್ಲಿ ಸಾಮಾನ್ಯವಾಗಿ ಎಷ್ಟು ಸಮಯ ನಡೆದಿದ್ದೀರಿ?';

  @override
  String get ipaqQ6 =>
      'ನೀವು ಮಧ್ಯಮ ದೈಹಿಕ ಚಟುವಟಿಕೆಗಳನ್ನು ಮಾಡಿದ ದಿನಗಳಲ್ಲಿ, ಸಾಮಾನ್ಯವಾಗಿ ಎಷ್ಟು ಸಮಯ ಅವುಗಳನ್ನು ಮಾಡುತ್ತಿದ್ದೀರಿ?';

  @override
  String get ipaqQ7 =>
      'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ, ವಾರದ ದಿನದಂದು (ಸೋಮವಾರ–ಶುಕ್ರವಾರ), ಎಷ್ಟು ಸಮಯ ಕುಳಿತುಕೊಳ್ಳುತ್ತೀರಿ?';

  @override
  String get ipaqResultTitle => 'ಐಪಿಎಕ್ಯೂ-ಇ ದಾಖಲಿಸಲಾಗಿದೆ';

  @override
  String get ipaqRecordedMessage =>
      'ನಿಮ್ಮ ದೈಹಿಕ ಚಟುವಟಿಕೆಯ ಪ್ರತಿಕ್ರಿಯೆಗಳನ್ನು ದಾಖಲಿಸಲಾಗಿದೆ.';

  @override
  String get completeAllQuestions => 'ದಯವಿಟ್ಟು ಎಲ್ಲಾ ಪ್ರಶ್ನೆಗಳನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ';

  @override
  String get hours => 'ಗಂಟೆಗಳು';

  @override
  String get minutes => 'ನಿಮಿಷಗಳು';

  @override
  String get noDay => 'ಯಾವುದೇ ದಿನವಿಲ್ಲ';

  @override
  String get iqolTitle => 'I-QOL ಮೌಲ್ಯಮಾಪನ';

  @override
  String get iqolYourScore => 'ನಿಮ್ಮ ಸ್ಕೋರ್';

  @override
  String get iqolResultTitle => 'ಐ-ಕ್ಯೂಓಎಲ್ ಫಲಿತಾಂಶ';

  @override
  String get iqolHigherScoreBetter => 'ಹೆಚ್ಚಿನ ಸ್ಕೋರ್ = ಉತ್ತಮ ಜೀವನ ಗುಣಮಟ್ಟ.';

  @override
  String get iqolMinimalImpact => 'ಕನಿಷ್ಠ ಪರಿಣಾಮ';

  @override
  String get iqolMildImpact => 'ಸೌಮ್ಯ ಪರಿಣಾಮ';

  @override
  String get iqolModerateImpact => 'ಮಧ್ಯಮ ಪರಿಣಾಮ';

  @override
  String get iqolSevereImpact => 'ತೀವ್ರ ಪರಿಣಾಮ';

  @override
  String iqolAnsweredCount(Object answered, Object total) {
    return '$answered / $total ಉತ್ತರಿಸಲಾಗಿದೆ';
  }

  @override
  String get iqolExtremely => 'ಅತ್ಯಂತ ಹೆಚ್ಚು';

  @override
  String get iqolQuiteABit => 'ಸಾಕಷ್ಟು';

  @override
  String get iqolModerately => 'ಮಧ್ಯಮವಾಗಿ';

  @override
  String get iqolALittle => 'ಸ್ವಲ್ಪ';

  @override
  String get iqolNotAtAll => 'ಏನೂ ಇಲ್ಲ';

  @override
  String get iqolQ1 => 'ಸಮಯಕ್ಕೆ ಸರಿಯಾಗಿ ಶೌಚಾಲಯಕ್ಕೆ ಹೋಗಲಾಗದೆಂಬ ಚಿಂತೆ.';

  @override
  String get iqolQ2 => 'ನನ್ನ ಮೂತ್ರದ ಸಮಸ್ಯೆಗಳಿಂದಾಗಿ ಕೆಮ್ಮು ಅಥವಾ ಸೀನುವಾಗ ಚಿಂತೆ.';

  @override
  String get iqolQ3 => 'ಕುಳಿತ ನಂತರ ಎದ್ದು ನಿಲ್ಲುವಾಗ ಎಚ್ಚರಿಕೆಯಿಂದಿರಬೇಕು.';

  @override
  String get iqolQ4 => 'ಹೊಸ ಸ್ಥಳಗಳಲ್ಲಿ ಶೌಚಾಲಯಗಳು ಎಲ್ಲಿವೆ ಎಂಬ ಚಿಂತೆ.';

  @override
  String get iqolQ5 => 'ಮೂತ್ರದ ಸಮಸ್ಯೆಗಳಿಂದ ಖಿನ್ನತೆ ಅನುಭವಿಸುವುದು.';

  @override
  String get iqolQ6 => 'ದೀರ್ಘಕಾಲ ಮನೆಯಿಂದ ಹೊರಗೆ ಹೋಗಲು ಸ್ವಾತಂತ್ರ್ಯವಿಲ್ಲ.';

  @override
  String get iqolQ7 => 'ಸಮಸ್ಯೆಗಳು ನಾನು ಬಯಸಿದ್ದನ್ನು ಮಾಡದಂತೆ ತಡೆಯುತ್ತವೆ, ನಿರಾಶೆ.';

  @override
  String get iqolQ8 => 'ಇತರರು ನನ್ನ ಮೇಲೆ ಮೂತ್ರ ವಾಸನೆ ಕಂಡುಕೊಳ್ಳಬಹುದೆಂಬ ಚಿಂತೆ.';

  @override
  String get iqolQ9 => 'ನನ್ನ ಮೂತ್ರದ ಸಮಸ್ಯೆಗಳು ಯಾವಾಗಲೂ ಮನಸ್ಸಿನಲ್ಲಿರುತ್ತವೆ.';

  @override
  String get iqolQ10 => 'ಆಗಾಗ್ಗೆ ಶೌಚಾಲಯಕ್ಕೆ ಹೋಗುವುದು ನನಗೆ ಮುಖ್ಯ.';

  @override
  String get iqolQ11 => 'ಮುಂಚಿತವಾಗಿ ಪ್ರತಿ ವಿವರವನ್ನು ಯೋಜಿಸುವುದು ಮುಖ್ಯ.';

  @override
  String get iqolQ12 => 'ವಯಸ್ಸಾದಂತೆ ಸಮಸ್ಯೆಗಳು ಉಲ್ಬಣಗೊಳ್ಳುವ ಚಿಂತೆ.';

  @override
  String get iqolQ13 => 'ಮೂತ್ರದ ಸಮಸ್ಯೆಗಳಿಂದ ರಾತ್ರಿ ನಿದ್ದೆ ಕಷ್ಟ.';

  @override
  String get iqolQ14 => 'ಮುಜುಗರ ಅಥವಾ ಅವಮಾನದ ಭಯ.';

  @override
  String get iqolQ15 => 'ನಾನು ಆರೋಗ್ಯವಂತ ವ್ಯಕ್ತಿಯಲ್ಲ ಎಂದು ಭಾಸವಾಗುತ್ತದೆ.';

  @override
  String get iqolQ16 => 'ಅಸಹಾಯಕತೆ ಅನುಭವವಾಗುತ್ತದೆ.';

  @override
  String get iqolQ17 => 'ಜೀವನದಲ್ಲಿ ಕಡಿಮೆ ಆನಂದ ಸಿಗುತ್ತದೆ.';

  @override
  String get iqolQ18 => 'ಮೂತ್ರ ಸೋರಿಕೆಯಾಗುವ ಚಿಂತೆ.';

  @override
  String get iqolQ19 => 'ಮೂತ್ರಕೋಶದ ಮೇಲೆ ನಿಯಂತ್ರಣವಿಲ್ಲ ಎಂದು ಭಾಸವಾಗುತ್ತದೆ.';

  @override
  String get iqolQ20 => 'ಕುಡಿಯುವುದನ್ನು ನಿಯಂತ್ರಿಸಬೇಕು.';

  @override
  String get iqolQ21 => 'ಬಟ್ಟೆ ಆಯ್ಕೆಯಲ್ಲಿ ಮಿತಿ.';

  @override
  String get iqolQ22 => 'ಲೈಂಗಿಕ ಸಂಬಂಧದ ಬಗ್ಗೆ ಚಿಂತೆ.';

  @override
  String get bladderDiaryTitle => 'ಮೂತ್ರಕೋಶ ಡೈರಿ';

  @override
  String get day1 => 'ದಿನ 1';

  @override
  String get day2 => 'ದಿನ 2';

  @override
  String get day3 => 'ದಿನ 3';

  @override
  String get bed => 'ಮಲಗು';

  @override
  String get woke => 'ಎದ್ದು';

  @override
  String get drinks => 'ಪಾನೀಯಗಳು';

  @override
  String get amountMlCups => 'ಪ್ರಮಾಣ (ಮಿಲಿ / ಕಪ್‌ಗಳು)';

  @override
  String get fluidType => 'ಪ್ರಕಾರ (ನೀರು, ಚಹಾ…)';

  @override
  String get urineOutput => 'ಮೂತ್ರ ಉತ್ಪಾದನೆ';

  @override
  String get mlOrLeak => 'ಮಿಲಿ (ಅಥವಾ LEAK ಬರೆಯಿರಿ)';

  @override
  String get cantMeasure => 'ಅಳೆಯಲು ಸಾಧ್ಯವಿಲ್ಲ';

  @override
  String get bladderSensation => 'ಮೂತ್ರಕೋಶದ ಸಂವೇದನೆ';

  @override
  String get code => 'ಕೋಡ್';

  @override
  String get tapToSelect => 'ಆಯ್ಕೆಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ (0–4)';

  @override
  String get pad => 'ಪ್ಯಾಡ್';

  @override
  String get sensationAbbr => 'S:';

  @override
  String get tapToAddEntry => 'ನಮೂದು ಸೇರಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get sensationCodesTitle => 'ಮೂತ್ರಕೋಶ ಸಂವೇದನೆ ಕೋಡ್‌ಗಳು';

  @override
  String get sensationCodes => 'ಸಂವೇದನೆ ಕೋಡ್‌ಗಳು';

  @override
  String get selectCodeFor => 'ಇದಕ್ಕಾಗಿ ಕೋಡ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get close => 'ಮುಚ್ಚು';

  @override
  String get diarySubmittedTitle => 'ಡೈರಿ ಸಲ್ಲಿಸಲಾಗಿದೆ';

  @override
  String get diarySubmittedMessage =>
      'ನಿಮ್ಮ 3-ದಿನಗಳ ಮೂತ್ರಕೋಶ ಡೈರಿಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ದಾಖಲಿಸಲಾಗಿದೆ.';

  @override
  String get diarySaveFailed =>
      'ನಿಮ್ಮ ಡೈರಿಯನ್ನು ಉಳಿಸಲಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get invalidCredentials =>
      'ಆ ಇಮೇಲ್ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್ ಯಾವುದೇ ಖಾತೆಗೆ ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ.';

  @override
  String get networkUnavailable =>
      'ಸರ್ವರ್ ತಲುಪಲಾಗುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get somethingWentWrong => 'ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get dateOfBirthInFuture => 'ಜನ್ಮ ದಿನಾಂಕ ಭವಿಷ್ಯದಲ್ಲಿ ಇರಲಾಗದು';

  @override
  String get dashboardLoadFailed =>
      'ನಿಮ್ಮ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get dashboardNoData =>
      'ನೀವು ವ್ಯಾಯಾಮಗಳನ್ನು ಪ್ರಾರಂಭಿಸಿದ ನಂತರ ನಿಮ್ಮ ಪ್ರಗತಿ ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.';

  @override
  String get assessmentSaveFailed =>
      'ನಿಮ್ಮ ಉತ್ತರಗಳನ್ನು ಉಳಿಸಲಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get assessmentSaveSignedOut =>
      'ನಿಮ್ಮ ಅವಧಿ ಮುಗಿದಿದೆ. ಉತ್ತರಗಳನ್ನು ಉಳಿಸಲು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get diarySaveSignedOut =>
      'ನಿಮ್ಮ ಅವಧಿ ಮುಗಿದಿದೆ. ಡೈರಿ ಉಳಿಸಲು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get submitDiary => '3-ದಿನಗಳ ಡೈರಿ ಸಲ್ಲಿಸು';

  @override
  String get sensation0 => '0 – ಯಾವುದೇ ಪ್ರಚೋದನೆ ಇಲ್ಲ, ಸಾಮಾಜಿಕ ಕಾರಣ';

  @override
  String get sensation1 => '1 – ಸಾಮಾನ್ಯ ಇಚ್ಛೆ, ತುರ್ತು ಇಲ್ಲ';

  @override
  String get sensation2 => '2 – ತುರ್ತು, ಶೌಚಾಲಯಕ್ಕೆ ತಲುಪುವ ಮೊದಲೇ ಹೋಯಿತು';

  @override
  String get sensation3 => '3 – ತುರ್ತು, ಶೌಚಾಲಯ ತಲುಪಿದೆ, ಸೋರಿಕೆ ಇಲ್ಲ';

  @override
  String get sensation4 => '4 – ತುರ್ತು, ಶೌಚಾಲಯ ತಲುಪಲಾಗಲಿಲ್ಲ, ಸೋರಿಕೆಯಾಯಿತು';

  @override
  String get time6am => '6am';

  @override
  String get time7am => '7am';

  @override
  String get time8am => '8am';

  @override
  String get time9am => '9am';

  @override
  String get time10am => '10am';

  @override
  String get time11am => '11am';

  @override
  String get timeMidday => 'ಮಧ್ಯಾಹ್ನ';

  @override
  String get time1pm => '1pm';

  @override
  String get time2pm => '2pm';

  @override
  String get time3pm => '3pm';

  @override
  String get time4pm => '4pm';

  @override
  String get time5pm => '5pm';

  @override
  String get time6pm => '6pm';

  @override
  String get time7pm => '7pm';

  @override
  String get time8pm => '8pm';

  @override
  String get time9pm => '9pm';

  @override
  String get time10pm => '10pm';

  @override
  String get time11pm => '11pm';

  @override
  String get timeMidnight => 'ಮಧ್ಯರಾತ್ರಿ';

  @override
  String get time1am => '1am';

  @override
  String get time2am => '2am';

  @override
  String get time3am => '3am';

  @override
  String get time4am => '4am';

  @override
  String get time5am => '5am';

  @override
  String get name => 'ಹೆಸರು';

  @override
  String get phone => 'ಫೋನ್';

  @override
  String get age => 'ವಯಸ್ಸು';

  @override
  String get city => 'ನಗರ';

  @override
  String get occupation => 'ಉದ್ಯೋಗ';

  @override
  String get incontinenceType => 'ಮೂತ್ರದ ಅಸಂಯಮದ ಪ್ರಕಾರ';

  @override
  String get exercise => 'ವ್ಯಾಯಾಮ';

  @override
  String get diary => 'ಡೈರಿ';

  @override
  String get navAssessment => 'ಮೌಲ್ಯಮಾಪನ';

  @override
  String get profile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get pause => 'ವಿರಾಮ';

  @override
  String get start => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get weekLabel => 'ವಾರ';

  @override
  String get assessmentNext => 'ಮುಂದೆ';

  @override
  String get assessmentBack => 'ಹಿಂದೆ';

  @override
  String get assessmentResult => 'ಫಲಿತಾಂಶ';

  @override
  String assessmentStep(Object step, Object total) {
    return 'ಹಂತ $step / $total';
  }

  @override
  String get dateOfBirth => 'ಜನ್ಮ ದಿನಾಂಕ';

  @override
  String get selectDateOfBirth => 'ಜನ್ಮ ದಿನಾಂಕ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get gender => 'ಲಿಂಗ';

  @override
  String get female => 'ಮಹಿಳೆ';

  @override
  String get male => 'ಪುರುಷ';

  @override
  String get other => 'ಇತರೆ';

  @override
  String get iciq_q3 => 'ನೀವು ಎಷ್ಟು ಬಾರಿ ಮೂತ್ರ ಸೋರಿಕೆ ಅನುಭವಿಸುತ್ತೀರಿ?';

  @override
  String get iciq_q4 => 'ಸಾಮಾನ್ಯವಾಗಿ ಎಷ್ಟು ಮೂತ್ರ ಸೋರಿಕೆಯಾಗುತ್ತದೆ?';

  @override
  String get iciq_q5 =>
      'ಒಟ್ಟಾರೆಯಾಗಿ, ಮೂತ್ರ ಸೋರಿಕೆ ನಿಮ್ಮ ದೈನಂದಿನ ಜೀವನದಲ್ಲಿ ಎಷ್ಟು ತೊಂದರೆ ಉಂಟುಮಾಡುತ್ತದೆ?';

  @override
  String get iciq_q6 => 'ಯಾವಾಗ ಮೂತ್ರ ಸೋರಿಕೆಯಾಗುತ್ತದೆ?';

  @override
  String get iciqWhenLeaksNever => 'ಎಂದಿಗೂ ಇಲ್ಲ - ಮೂತ್ರ ಸೋರಿಕೆಯಾಗುವುದಿಲ್ಲ';

  @override
  String get iciqWhenLeaksBeforeToilet => 'ಶೌಚಾಲಯ ತಲುಪುವ ಮೊದಲು ಸೋರಿಕೆ';

  @override
  String get iciqWhenLeaksCoughSneeze => 'ಕೆಮ್ಮುವಾಗ ಅಥವಾ ಸೀನುವಾಗ ಸೋರಿಕೆ';

  @override
  String get iciqWhenLeaksAsleep => 'ನಿದ್ರಿಸುವಾಗ ಸೋರಿಕೆ';

  @override
  String get iciqWhenLeaksActivity => 'ದೈಹಿಕ ಚಟುವಟಿಕೆಯ ಸಮಯದಲ್ಲಿ ಸೋರಿಕೆ';

  @override
  String get iciqWhenLeaksAfterUrination =>
      'ಮೂತ್ರ ವಿಸರ್ಜನೆ ಮುಗಿಸಿ ಬಟ್ಟೆ ಧರಿಸಿದ ನಂತರ ಸೋರಿಕೆ';

  @override
  String get iciqWhenLeaksNoReason => 'ಸ್ಪಷ್ಟ ಕಾರಣವಿಲ್ಲದೆ ಸೋರಿಕೆ';

  @override
  String get iciqWhenLeaksAllTime => 'ಯಾವಾಗಲೂ ಸೋರಿಕೆ';

  @override
  String get iqolAboutTitle => 'ನಿಮ್ಮ ಬಗ್ಗೆ';

  @override
  String get iqol_about_q1 => 'ನಿಮಗೆ ಮೂತ್ರದ ಸಮಸ್ಯೆಗಳು ಎಷ್ಟು ವರ್ಷಗಳಿಂದಿವೆ?';

  @override
  String get iqol_about_q2 => 'ಮೂತ್ರದ ಸಮಸ್ಯೆಯ ಹೆಚ್ಚುವರಿ ತಿಂಗಳುಗಳು';

  @override
  String get iqol_about_q3 => 'ನಿಮ್ಮ ಮೂತ್ರದ ಸಮಸ್ಯೆ ಎಷ್ಟು ತೀವ್ರವಾಗಿದೆ?';

  @override
  String get iqol_about_q4 =>
      'ಕೆಮ್ಮು, ಸೀನು ಅಥವಾ ಚಟುವಟಿಕೆಯ ಸಮಯದಲ್ಲಿ ಸೋರಿಕೆಯಾಗುತ್ತದೆಯೇ?';

  @override
  String get iqol_about_q5 =>
      'ಮೂತ್ರ ವಿಸರ್ಜನೆಗೆ ಹಠಾತ್ ತುರ್ತು ಭಾವನೆ ಬಂದಾಗ ಸೋರಿಕೆಯಾಗುತ್ತದೆಯೇ?';

  @override
  String get iqol_about_q6 => 'ನೀವು ಎಷ್ಟು ಬಾರಿ ಮೂತ್ರ ಸೋರಿಕೆ ಅನುಭವಿಸುತ್ತೀರಿ?';

  @override
  String get iqolScoreOutOf100 => '100ರಲ್ಲಿ ಸ್ಕೋರ್';

  @override
  String get ipaq_q1 => 'ಕುಳಿತುಕೊಳ್ಳುವ ಸಮಯ';

  @override
  String get ipaq_q2 => 'ನಡೆಯುವಿಕೆ';

  @override
  String get ipaq_q3 => 'ಮಧ್ಯಮ ಚಟುವಟಿಕೆ';

  @override
  String get ipaq_q4 => 'ತೀವ್ರ ಚಟುವಟಿಕೆ';

  @override
  String get days => 'ದಿನಗಳು';

  @override
  String get activityLevel => 'ಚಟುವಟಿಕೆ ಮಟ್ಟ';

  @override
  String get activityLow => 'ಕಡಿಮೆ';

  @override
  String get activityModerate => 'ಮಧ್ಯಮ';

  @override
  String get activityHigh => 'ಹೆಚ್ಚು';

  @override
  String get totalMetMinutes => 'ಒಟ್ಟು MET-ನಿಮಿಷಗಳು';

  @override
  String get notAtAll => 'ಇಲ್ಲ';

  @override
  String get aGreatDeal => 'ತುಂಬಾ';

  @override
  String get thisQuestionIsRequired => 'ಈ ಪ್ರಶ್ನೆ ಅವಶ್ಯಕ';

  @override
  String get noDays => 'ಯಾವುದೇ ದಿನಗಳಿಲ್ಲ';

  @override
  String get allSevenDays => 'ಎಲ್ಲಾ ಏಳು ದಿನಗಳು';

  @override
  String get ok => 'ಸರಿ';

  @override
  String get iciqHighSeverityTitle => 'ಹೆಚ್ಚಿನ ತೀವ್ರತೆ ಪತ್ತೆ';

  @override
  String get iciqHighSeverityMessage =>
      'ನಿಮ್ಮ ಉತ್ತರಗಳ ಆಧಾರದ ಮೇಲೆ, ನಿಮ್ಮ ರೋಗಲಕ್ಷಣಗಳು ತೀವ್ರವಾಗಿರಬಹುದು ಎಂದು ತೋರುತ್ತದೆ. ಈ ಕಾರ್ಯಕ್ರಮದೊಂದಿಗೆ ಮುಂದುವರಿಯುವ ಮೊದಲು ಸಂಪೂರ್ಣ ಮೌಲ್ಯಮಾಪನಕ್ಕಾಗಿ ವೈದ್ಯಕೀಯ ಅರ್ಹತೆ ಪಡೆದ ವೃತ್ತಿಪರರನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get iciqOfferExercisesTitle => 'ವ್ಯಾಯಾಮಗಳೊಂದಿಗೆ ಮುಂದುವರಿಯಿರಿ?';

  @override
  String get iciqOfferExercisesMessage =>
      'ನೀವು ಭೌತಿಕ ಚಟುವಟಿಕೆ ಮೌಲ್ಯಮಾಪನದೊಂದಿಗೆ ಮುಂದುವರಿಯಲು ಬಯಸುವಿರಾ?';

  @override
  String get maritalStatus => 'ವೈವಾಹಿಕ ಸ್ಥಿತಿ';

  @override
  String get maritalSingle => 'ಅವಿವಾಹಿತ';

  @override
  String get maritalMarried => 'ವಿವಾಹಿತ';

  @override
  String get maritalSeparated => 'ಬೇರ್ಪಟ್ಟಿದ್ದಾರೆ';

  @override
  String get maritalDivorced => 'ವಿಚ್ಛೇದಿತ';

  @override
  String get maritalWidowed => 'ವಿಧವೆ';

  @override
  String get haveChildren => 'ನಿಮಗೆ ಮಕ್ಕಳಿದ್ದಾರೆಯೇ?';

  @override
  String get deliveryTypeLabel => 'ಹೆರಿಗೆಯ ಪ್ರಕಾರ';

  @override
  String get deliveryVaginal => 'ಸಾಮಾನ್ಯ ಹೆರಿಗೆ';

  @override
  String get deliveryCaesarean => 'ಸಿಸೇರಿಯನ್ ಶಸ್ತ್ರಚಿಕಿತ್ಸೆ';

  @override
  String get deliveryAssisted => 'ಸಹಾಯದಿಂದ ಹೆರಿಗೆ';

  @override
  String get deliveryOther => 'ಇತರೆ';

  @override
  String get childrenAgesLabel => 'ಮಕ್ಕಳ ವಯಸ್ಸು';

  @override
  String get childrenAgesHint => 'ಉದಾಹರಣೆ: 3, 7';

  @override
  String childbirthPainLevel(Object level) {
    return 'ಹೆರಿಗೆ ಸಂಬಂಧಿತ ನೋವಿನ ಮಟ್ಟ: $level / 10';
  }

  @override
  String get heightCmOptional => 'ಎತ್ತರ (ಸೆಂ.ಮೀ) — ಐಚ್ಛಿಕ';

  @override
  String get weightKgOptional => 'ತೂಕ (ಕೆ.ಜಿ) — ಐಚ್ಛಿಕ';

  @override
  String get haveDiabetes => 'ನಿಮಗೆ ಮಧುಮೇಹ ಇದೆಯೇ?';

  @override
  String get haveHypertension => 'ನಿಮಗೆ ಅಧಿಕ ರಕ್ತದೊತ್ತಡ ಇದೆಯೇ?';

  @override
  String get personalHistory => 'ವೈಯಕ್ತಿಕ ಮಾಹಿತಿ';

  @override
  String get children => 'ಮಕ್ಕಳು';

  @override
  String get childbirthPain => 'ಹೆರಿಗೆ ಸಂಬಂಧಿತ ನೋವು';

  @override
  String get heightCm => 'ಎತ್ತರ (ಸೆಂ.ಮೀ)';

  @override
  String get weightKg => 'ತೂಕ (ಕೆ.ಜಿ)';

  @override
  String get diabetes => 'ಮಧುಮೇಹ';

  @override
  String get hypertension => 'ಅಧಿಕ ರಕ್ತದೋತ್ತಡ';

  @override
  String get notProvided => 'ನೀಡಿಲ್ಲ';

  @override
  String get genderNonBinary => 'ನಾನ್-ಬೈನರಿ';

  @override
  String get genderPreferNotToSay => 'ಹೇಳಲು ಬಯಸುವುದಿಲ್ಲ';

  @override
  String get sessionExpired =>
      'ನಿಮ್ಮ ಅವಧಿ ಮುಗಿದಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get dayLabel => 'ದಿನ';

  @override
  String get monthLabel => 'ತಿಂಗಳು';

  @override
  String get yearLabel => 'ವರ್ಷ';

  @override
  String get passwordMinEight => 'ಪಾಸ್‌ವರ್ಡ್ ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳಿರಬೇಕು';

  @override
  String get passwordNeedsSpecial =>
      'ಪಾಸ್‌ವರ್ಡ್‌ನಲ್ಲಿ ಕನಿಷ್ಠ ಒಂದು ವಿಶೇಷ ಅಕ್ಷರ ಇರಬೇಕು';

  @override
  String get emailAlreadyRegistered => 'ಈ ಇಮೇಲ್ ಈಗಾಗಲೇ ನೋಂದಾಯಿಸಲಾಗಿದೆ';

  @override
  String get language => 'ಭಾಷೆ';

  @override
  String get languageEnglish => 'ಇಂಗ್ಲಿಷ್';

  @override
  String get languageKannada => 'ಕನ್ನಡ';

  @override
  String get languageSystem => 'ಸಾಧನದ ಭಾಷೆ ಬಳಸಿ';
}
