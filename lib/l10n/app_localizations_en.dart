// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Telerehab App';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign up';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get googleSignInCancelled => 'Google sign-in was cancelled';

  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  @override
  String get createAccount => 'Create your account';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter a password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get enterValidPhone => 'Enter a valid phone number';

  @override
  String get invalidPhoneFormat =>
      'Phone must contain only digits and be 10 digits long';

  @override
  String get invalidNameFormat => 'Name must contain only letters and spaces';

  @override
  String get enterValidDob => 'Enter your date of birth in DD/MM/YYYY format';

  @override
  String get invalidDobFormat => 'Enter a valid date in DD/MM/YYYY format';

  @override
  String get selectAge => 'Select your age';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get thisWeek => 'This Week';

  @override
  String get adherence => 'Adherence';

  @override
  String get exercises => 'exercises';

  @override
  String get logBladderDiary => 'Log Bladder Diary';

  @override
  String get startExercise => 'Start Today\'s Exercise';

  @override
  String get weeklyAdherence => 'Weekly Adherence';

  @override
  String weekXofY(Object currentWeek, Object totalWeeks) {
    return 'Week $currentWeek of $totalWeeks — Keep going!';
  }

  @override
  String week(Object week) {
    return 'W$week';
  }

  @override
  String iciqComparison(Object post, Object pre) {
    return 'Pre: $pre → Post: $post';
  }

  @override
  String get user => 'User';

  @override
  String get bengaluru => 'Bengaluru';

  @override
  String get profileDetails => 'Profile Details';

  @override
  String get healthInfo => 'Health Info';

  @override
  String get symptomDuration => 'Symptom Duration';

  @override
  String get months => 'months';

  @override
  String get soughtTreatment => 'Sought Treatment';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get logOut => 'Log Out';

  @override
  String get profileSetup => 'Profile Setup';

  @override
  String get profileStep1 => 'Step 1 of 3: Your Profile';

  @override
  String get enterYourCity => 'Enter your city';

  @override
  String get enterYourOccupation => 'Enter your occupation';

  @override
  String get selectIncontinenceType => 'Select an incontinence type';

  @override
  String get symptomDurationMonths => 'Symptom duration in months';

  @override
  String get enterValidDuration => 'Enter duration in months';

  @override
  String get durationCannotBeNegative => 'Duration cannot be negative';

  @override
  String get haveYouSoughtTreatment => 'Have you sought treatment?';

  @override
  String get continueText => 'Continue';

  @override
  String get stressIncontinence => 'Stress';

  @override
  String get urgeIncontinence => 'Urge';

  @override
  String get mixedIncontinence => 'Mixed';

  @override
  String get unknownIncontinence => 'Unknown';

  @override
  String get education => 'Education';

  @override
  String get whatIsUrinaryIncontinence => 'What is Urinary Incontinence?';

  @override
  String get understandingBasics => 'Understanding the basics';

  @override
  String get typesOfIncontinence => 'Types of Incontinence';

  @override
  String get stressUrgeMixed => 'Stress, Urge and Mixed';

  @override
  String get pelvicFloorMuscles => 'Pelvic Floor Muscles Explained';

  @override
  String get anatomyFunction => 'Anatomy and function';

  @override
  String get howPfmtWorks => 'How PFMT Works';

  @override
  String get scienceBehindExercises => 'The science behind the exercises';

  @override
  String get lifestyleChanges => 'Lifestyle Changes That Help';

  @override
  String get dietFluidHabits => 'Diet, fluid intake and habits';

  @override
  String get whenToSeeDoctor => 'When to See a Doctor';

  @override
  String get redFlagsReferrals => 'Red flags and referrals';

  @override
  String get whatIsUrinaryIncontinenceDetail =>
      'Urinary incontinence is the involuntary leakage of urine. It is a common condition that affects millions of people worldwide. Understanding the cause is the first step toward effective management. This section will help you learn the basics of what urinary incontinence is and why it happens.';

  @override
  String get typesOfIncontinenceDetail =>
      'There are several types of incontinence: Stress incontinence (leakage during coughing, sneezing, or exercise), Urge incontinence (sudden, intense urge to urinate followed by leakage), and Mixed incontinence (a combination of both). Each type may require different approaches to treatment.';

  @override
  String get pelvicFloorMusclesDetail =>
      'The pelvic floor muscles form a supportive hammock across the bottom of the pelvis. They support the bladder, bowel, and uterus. Weakness in these muscles can lead to incontinence. Learning to locate and contract these muscles correctly is key to pelvic floor training.';

  @override
  String get howPfmtWorksDetail =>
      'Pelvic Floor Muscle Training (PFMT) strengthens the pelvic floor muscles through repeated contractions. Regular exercise improves muscle tone, endurance, and coordination. Over time, this can reduce or eliminate leakage episodes.';

  @override
  String get lifestyleChangesDetail =>
      'Simple lifestyle adjustments can significantly improve bladder control: maintain a healthy weight, avoid bladder irritants (caffeine, spicy foods), drink adequate but not excessive fluids, and practice good bathroom habits.';

  @override
  String get whenToSeeDoctorDetail =>
      'Consult a healthcare professional if incontinence affects your quality of life, you have pain or blood in urine, symptoms worsen, or you\'re unsure about the cause. Early assessment often leads to better outcomes.';

  @override
  String weekNumber(Object week) {
    return 'Week $week';
  }

  @override
  String weekProgress(Object currentWeek, Object totalWeeks) {
    return 'Week $currentWeek of $totalWeeks';
  }

  @override
  String weekDifficulty(Object difficulty, Object weekNumber) {
    return 'Week $weekNumber — $difficulty';
  }

  @override
  String completedCount(Object completed, Object total) {
    return '$completed of $total completed';
  }

  @override
  String get reps => 'Reps';

  @override
  String get hold => 'Hold';

  @override
  String get rest => 'Rest';

  @override
  String seconds(Object seconds) {
    return '${seconds}s';
  }

  @override
  String minutesAndSeconds(Object minutes, Object seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get completeSession => 'Complete Session';

  @override
  String get iciqTitle => 'ICIQ Assessment';

  @override
  String get iciqQ1 => 'Q1. How often do you leak urine?';

  @override
  String get iciqQ1Subtitle => 'Choose the option that best matches your week.';

  @override
  String get iciqQ2 => 'Q2. How much urine do you usually leak?';

  @override
  String get iciqQ2Subtitle => 'Select the usual amount.';

  @override
  String get iciqQ3 =>
      'Q3. Overall, how much does leaking urine interfere with your everyday life?';

  @override
  String get iciqQ3Subtitle => '0 means not at all, 10 means a great deal.';

  @override
  String get iciqQ4 => 'Q4-Q6. When does urine leak?';

  @override
  String get iciqQ4Subtitle => 'Select all that apply.';

  @override
  String get iciqImpactScore => 'Impact score';

  @override
  String get iciqScore => 'Score';

  @override
  String get iciqSeverity => 'Severity';

  @override
  String get iciqResultTitle => 'ICIQ Result';

  @override
  String get iciqConsultDoctor =>
      'Please consult a medical professional before proceeding';

  @override
  String get submit => 'Submit';

  @override
  String get never => 'Never';

  @override
  String get onceAWeekOrLess => 'About once a week or less';

  @override
  String get twoOrThreeTimesAWeek => 'Two or three times a week';

  @override
  String get onceADay => 'About once a day';

  @override
  String get severalTimesADay => 'Several times a day';

  @override
  String get allTheTime => 'All the time';

  @override
  String get none => 'None';

  @override
  String get smallAmount => 'A small amount';

  @override
  String get moderateAmount => 'A moderate amount';

  @override
  String get largeAmount => 'A large amount';

  @override
  String get severityNone => 'None';

  @override
  String get severityMild => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severitySevere => 'Severe';

  @override
  String get severityVerySevere => 'Very Severe';

  @override
  String get leaksBeforeToilet => 'Leaks before reaching the toilet';

  @override
  String get leaksWhenCoughSneeze => 'Leaks when coughing or sneezing';

  @override
  String get leaksDuringActivity => 'Leaks during physical activity';

  @override
  String get ipaqTitle => 'IPAQ Screening';

  @override
  String get ipaqInstruction =>
      'Think about physical activities over the last 7 days.';

  @override
  String get ipaqQ1 =>
      'During the last 7 days, how much time did you spend sitting during a day? Include time at work, home, course work, and leisure (desk, reading, TV).';

  @override
  String get ipaqQ2 =>
      'During the last 7 days, on how many days did you walk for at least 10 minutes at a time? (Includes walking at work, home, travel, recreation, sport, exercise, or leisure.)';

  @override
  String get ipaqQ2DurationPrompt =>
      'How much time did you usually spend walking on one of those days?';

  @override
  String get ipaqQ3 =>
      'During the last 7 days, on how many days did you do moderate physical activities like gardening, cleaning, bicycling at a regular pace, swimming or other fitness activities? (At least 10 minutes at a time. Do not include walking.)';

  @override
  String get ipaqQ3DurationPrompt =>
      'How much time did you usually spend doing moderate activities on one of those days?';

  @override
  String get ipaqQ4 =>
      'During the last 7 days, on how many days did you do vigorous physical activities like heavy lifting, heavier garden/construction work, chopping wood, aerobics, jogging/running, or fast bicycling? (At least 10 minutes at a time.)';

  @override
  String get ipaqQ4DurationPrompt =>
      'How much time did you usually spend doing vigorous activities on one of those days?';

  @override
  String get ipaqQ5 =>
      'During the last 7 days, on how many days did you walk for at least 10 minutes at a time? (Walking to travel from place to place, or solely for recreation, sport, exercise, or leisure.)';

  @override
  String get ipaqQ5DurationPrompt =>
      'How much time did you usually spend walking on one of those days?';

  @override
  String get ipaqQ6 =>
      'On those days when you did moderate physical activities, how much time did you usually spend doing them?';

  @override
  String get ipaqQ7 =>
      'During the last 7 days, on a weekday (Monday–Friday), how much time did you spend sitting?';

  @override
  String get ipaqResultTitle => 'IPAQ-E Recorded';

  @override
  String get ipaqRecordedMessage =>
      'Your physical activity responses have been recorded.';

  @override
  String get completeAllQuestions => 'Please complete all questions';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String get noDay => 'No day';

  @override
  String get iqolTitle => 'I-QOL Assessment';

  @override
  String get iqolYourScore => 'Your Score';

  @override
  String get iqolResultTitle => 'I-QOL Result';

  @override
  String get iqolHigherScoreBetter => 'Higher score = better quality of life.';

  @override
  String get iqolMinimalImpact => 'Minimal Impact';

  @override
  String get iqolMildImpact => 'Mild Impact';

  @override
  String get iqolModerateImpact => 'Moderate Impact';

  @override
  String get iqolSevereImpact => 'Severe Impact';

  @override
  String iqolAnsweredCount(Object answered, Object total) {
    return '$answered of $total answered';
  }

  @override
  String get iqolExtremely => 'Extremely';

  @override
  String get iqolQuiteABit => 'Quite a bit';

  @override
  String get iqolModerately => 'Moderately';

  @override
  String get iqolALittle => 'A little';

  @override
  String get iqolNotAtAll => 'Not at all';

  @override
  String get iqolQ1 =>
      'I worry about not being able to get to the toilet on time.';

  @override
  String get iqolQ2 =>
      'I worry about coughing or sneezing because of my urinary problems.';

  @override
  String get iqolQ3 =>
      'I have to be careful standing up after sitting down because of my urinary problems.';

  @override
  String get iqolQ4 => 'I worry about where toilets are in new places.';

  @override
  String get iqolQ5 => 'I feel depressed because of my urinary problems.';

  @override
  String get iqolQ6 =>
      'I don\'t feel free to leave my home for long periods because of my urinary problems.';

  @override
  String get iqolQ7 =>
      'I feel frustrated because my urinary problems prevent me from doing what I want.';

  @override
  String get iqolQ8 => 'I worry about others smelling urine on me.';

  @override
  String get iqolQ9 => 'My urinary problems are always on my mind.';

  @override
  String get iqolQ10 =>
      'It\'s important for me to make frequent trips to the toilet.';

  @override
  String get iqolQ11 =>
      'Because of my urinary problems, it\'s important to plan every detail in advance.';

  @override
  String get iqolQ12 =>
      'I worry about my urinary problems getting worse as I grow older.';

  @override
  String get iqolQ13 =>
      'I have a hard time getting a good night of sleep because of my urinary problems.';

  @override
  String get iqolQ14 =>
      'I worry about being embarrassed or humiliated because of my urinary problems.';

  @override
  String get iqolQ15 =>
      'My urinary problems make me feel like I\'m not a healthy person.';

  @override
  String get iqolQ16 => 'My urinary problems make me feel helpless.';

  @override
  String get iqolQ17 =>
      'I get less enjoyment out of life because of my urinary problems.';

  @override
  String get iqolQ18 => 'I worry about wetting myself.';

  @override
  String get iqolQ19 => 'I feel like I have no control over my bladder.';

  @override
  String get iqolQ20 =>
      'I have to watch what or how much I drink because of my urinary problems.';

  @override
  String get iqolQ21 => 'My urinary problems limit my choice of clothing.';

  @override
  String get iqolQ22 =>
      'I worry about having sex because of my urinary problems.';

  @override
  String get bladderDiaryTitle => 'Bladder Diary';

  @override
  String get day1 => 'Day 1';

  @override
  String get day2 => 'Day 2';

  @override
  String get day3 => 'Day 3';

  @override
  String get bed => 'BED';

  @override
  String get woke => 'WOKE';

  @override
  String get drinks => 'Drinks';

  @override
  String get amountMlCups => 'Amount (ml / cups)';

  @override
  String get fluidType => 'Type (water, tea…)';

  @override
  String get urineOutput => 'Urine Output';

  @override
  String get mlOrLeak => 'ml (or write LEAK)';

  @override
  String get cantMeasure => 'Can\'t measure';

  @override
  String get bladderSensation => 'Bladder Sensation';

  @override
  String get code => 'Code';

  @override
  String get tapToSelect => 'Tap to select (0–4)';

  @override
  String get pad => 'Pad';

  @override
  String get sensationAbbr => 'S:';

  @override
  String get tapToAddEntry => 'Tap to add entry';

  @override
  String get sensationCodesTitle => 'Bladder Sensation Codes';

  @override
  String get sensationCodes => 'Sensation codes';

  @override
  String get selectCodeFor => 'Select code for';

  @override
  String get close => 'Close';

  @override
  String get diarySubmittedTitle => 'Diary Submitted';

  @override
  String get diarySubmittedMessage =>
      'Your 3-day bladder diary has been recorded successfully.';

  @override
  String get diarySaveFailed =>
      'Your diary could not be saved. Please check your connection and try again.';

  @override
  String get invalidCredentials =>
      'That email and password do not match an account.';

  @override
  String get networkUnavailable =>
      'Cannot reach the server. Please check your connection.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get dateOfBirthInFuture => 'Date of birth cannot be in the future';

  @override
  String get dashboardLoadFailed =>
      'Could not load your dashboard. Please check your connection and try again.';

  @override
  String get dashboardNoData =>
      'Your progress will appear here once you start the exercises.';

  @override
  String get assessmentSaveFailed =>
      'Your answers could not be saved. Please check your connection and try again.';

  @override
  String get assessmentSaveSignedOut =>
      'Your session has ended. Sign in again to save your answers.';

  @override
  String get diarySaveSignedOut =>
      'Your session has ended. Sign in again to save your diary.';

  @override
  String get retry => 'Retry';

  @override
  String get submitDiary => 'Submit 3-Day Diary';

  @override
  String get sensation0 => '0 – No urge, social reason';

  @override
  String get sensation1 => '1 – Normal desire, no urgency';

  @override
  String get sensation2 => '2 – Urgency, passed before toilet';

  @override
  String get sensation3 => '3 – Urgency, reached toilet, no leak';

  @override
  String get sensation4 => '4 – Urgency, could not reach toilet, leaked';

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
  String get timeMidday => 'Midday';

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
  String get timeMidnight => 'Midnight';

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
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get age => 'Age';

  @override
  String get city => 'City';

  @override
  String get occupation => 'Occupation';

  @override
  String get incontinenceType => 'Incontinence type';

  @override
  String get exercise => 'Exercise';

  @override
  String get diary => 'Diary';

  @override
  String get navAssessment => 'Assessment';

  @override
  String get profile => 'Profile';

  @override
  String get pause => 'Pause';

  @override
  String get start => 'Start';

  @override
  String get weekLabel => 'Week';

  @override
  String get assessmentNext => 'Next';

  @override
  String get assessmentBack => 'Back';

  @override
  String get assessmentResult => 'Result';

  @override
  String assessmentStep(Object step, Object total) {
    return 'Step $step of $total';
  }

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get selectDateOfBirth => 'Select date of birth';

  @override
  String get gender => 'Gender';

  @override
  String get female => 'Female';

  @override
  String get male => 'Male';

  @override
  String get other => 'Other';

  @override
  String get iciq_q3 => 'How often do you leak urine?';

  @override
  String get iciq_q4 => 'How much urine do you usually leak?';

  @override
  String get iciq_q5 =>
      'Overall, how much does leaking urine interfere with your everyday life?';

  @override
  String get iciq_q6 => 'When does urine leak?';

  @override
  String get iciqWhenLeaksNever => 'Never - urine does not leak';

  @override
  String get iciqWhenLeaksBeforeToilet => 'Leaks before reaching the toilet';

  @override
  String get iciqWhenLeaksCoughSneeze => 'Leaks when coughing or sneezing';

  @override
  String get iciqWhenLeaksAsleep => 'Leaks when asleep';

  @override
  String get iciqWhenLeaksActivity => 'Leaks during physical activity';

  @override
  String get iciqWhenLeaksAfterUrination =>
      'Leaks after finishing urination and dressed';

  @override
  String get iciqWhenLeaksNoReason => 'Leaks for no obvious reason';

  @override
  String get iciqWhenLeaksAllTime => 'Leaks all the time';

  @override
  String get iqolAboutTitle => 'About You';

  @override
  String get iqol_about_q1 => 'How many years have you had urinary problems?';

  @override
  String get iqol_about_q2 => 'Additional months with urinary problems';

  @override
  String get iqol_about_q3 => 'How severe is your urinary problem?';

  @override
  String get iqol_about_q4 =>
      'Do you leak with coughing, sneezing, or activity?';

  @override
  String get iqol_about_q5 => 'Do you leak with a sudden urge to urinate?';

  @override
  String get iqol_about_q6 => 'How often do you leak urine?';

  @override
  String get iqolScoreOutOf100 => 'Score out of 100';

  @override
  String get ipaq_q1 => 'Sitting time';

  @override
  String get ipaq_q2 => 'Walking';

  @override
  String get ipaq_q3 => 'Moderate activity';

  @override
  String get ipaq_q4 => 'Vigorous activity';

  @override
  String get days => 'Days';

  @override
  String get activityLevel => 'Activity level';

  @override
  String get activityLow => 'Low';

  @override
  String get activityModerate => 'Moderate';

  @override
  String get activityHigh => 'High';

  @override
  String get totalMetMinutes => 'Total MET-minutes';

  @override
  String get notAtAll => 'Not at all';

  @override
  String get aGreatDeal => 'A great deal';

  @override
  String get thisQuestionIsRequired => 'This question is required';

  @override
  String get noDays => 'No days';

  @override
  String get allSevenDays => 'All seven days';

  @override
  String get ok => 'OK';

  @override
  String get iciqHighSeverityTitle => 'High Severity Detected';

  @override
  String get iciqHighSeverityMessage =>
      'Based on your responses, your symptoms appear severe. Please consult a medical professional for a thorough evaluation before continuing with this program.';

  @override
  String get iciqOfferExercisesTitle => 'Continue with Exercises?';

  @override
  String get iciqOfferExercisesMessage =>
      'Would you like to continue with the physical activity assessment?';

  @override
  String get maritalStatus => 'Marital status';

  @override
  String get maritalSingle => 'Single';

  @override
  String get maritalMarried => 'Married';

  @override
  String get maritalSeparated => 'Separated';

  @override
  String get maritalDivorced => 'Divorced';

  @override
  String get maritalWidowed => 'Widowed';

  @override
  String get haveChildren => 'Do you have children?';

  @override
  String get deliveryTypeLabel => 'Type of delivery';

  @override
  String get deliveryVaginal => 'Vaginal delivery';

  @override
  String get deliveryCaesarean => 'Caesarean section';

  @override
  String get deliveryAssisted => 'Assisted delivery';

  @override
  String get deliveryOther => 'Other';

  @override
  String get childrenAgesLabel => 'Age(s) of child / children';

  @override
  String get childrenAgesHint => 'Example: 3, 7';

  @override
  String childbirthPainLevel(Object level) {
    return 'Childbirth-related pain level: $level / 10';
  }

  @override
  String get heightCmOptional => 'Height (cm) — optional';

  @override
  String get weightKgOptional => 'Weight (kg) — optional';

  @override
  String get haveDiabetes => 'Do you have diabetes?';

  @override
  String get haveHypertension => 'Do you have hypertension?';

  @override
  String get personalHistory => 'Personal History';

  @override
  String get children => 'Children';

  @override
  String get childbirthPain => 'Childbirth-related pain';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get diabetes => 'Diabetes';

  @override
  String get hypertension => 'Hypertension';

  @override
  String get notProvided => 'Not provided';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get dayLabel => 'Day';

  @override
  String get monthLabel => 'Month';

  @override
  String get yearLabel => 'Year';

  @override
  String get passwordMinEight => 'Password must be at least 8 characters';

  @override
  String get passwordNeedsSpecial =>
      'Password must contain at least one special character';

  @override
  String get emailAlreadyRegistered => 'This email is already registered';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKannada => 'Kannada';

  @override
  String get languageSystem => 'Use device language';
}
