import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Telerehab App'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled'**
  String get googleSignInCancelled;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get googleSignInFailed;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @invalidPhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Phone must contain only digits and be 10 digits long'**
  String get invalidPhoneFormat;

  /// No description provided for @invalidNameFormat.
  ///
  /// In en, this message translates to:
  /// **'Name must contain only letters and spaces'**
  String get invalidNameFormat;

  /// No description provided for @enterValidDob.
  ///
  /// In en, this message translates to:
  /// **'Enter your date of birth in DD/MM/YYYY format'**
  String get enterValidDob;

  /// No description provided for @invalidDobFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date in DD/MM/YYYY format'**
  String get invalidDobFormat;

  /// No description provided for @selectAge.
  ///
  /// In en, this message translates to:
  /// **'Select your age'**
  String get selectAge;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @adherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'exercises'**
  String get exercises;

  /// No description provided for @logBladderDiary.
  ///
  /// In en, this message translates to:
  /// **'Log Bladder Diary'**
  String get logBladderDiary;

  /// No description provided for @startExercise.
  ///
  /// In en, this message translates to:
  /// **'Start Today\'s Exercise'**
  String get startExercise;

  /// No description provided for @weeklyAdherence.
  ///
  /// In en, this message translates to:
  /// **'Weekly Adherence'**
  String get weeklyAdherence;

  /// No description provided for @weekXofY.
  ///
  /// In en, this message translates to:
  /// **'Week {currentWeek} of {totalWeeks} — Keep going!'**
  String weekXofY(Object currentWeek, Object totalWeeks);

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'W{week}'**
  String week(Object week);

  /// No description provided for @iciqComparison.
  ///
  /// In en, this message translates to:
  /// **'Pre: {pre} → Post: {post}'**
  String iciqComparison(Object post, Object pre);

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @bengaluru.
  ///
  /// In en, this message translates to:
  /// **'Bengaluru'**
  String get bengaluru;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get profileDetails;

  /// No description provided for @healthInfo.
  ///
  /// In en, this message translates to:
  /// **'Health Info'**
  String get healthInfo;

  /// No description provided for @symptomDuration.
  ///
  /// In en, this message translates to:
  /// **'Symptom Duration'**
  String get symptomDuration;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @soughtTreatment.
  ///
  /// In en, this message translates to:
  /// **'Sought Treatment'**
  String get soughtTreatment;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Profile Setup'**
  String get profileSetup;

  /// No description provided for @profileStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 3: Your Profile'**
  String get profileStep1;

  /// No description provided for @enterYourCity.
  ///
  /// In en, this message translates to:
  /// **'Enter your city'**
  String get enterYourCity;

  /// No description provided for @enterYourOccupation.
  ///
  /// In en, this message translates to:
  /// **'Enter your occupation'**
  String get enterYourOccupation;

  /// No description provided for @selectIncontinenceType.
  ///
  /// In en, this message translates to:
  /// **'Select an incontinence type'**
  String get selectIncontinenceType;

  /// No description provided for @symptomDurationMonths.
  ///
  /// In en, this message translates to:
  /// **'Symptom duration in months'**
  String get symptomDurationMonths;

  /// No description provided for @enterValidDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter duration in months'**
  String get enterValidDuration;

  /// No description provided for @durationCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Duration cannot be negative'**
  String get durationCannotBeNegative;

  /// No description provided for @haveYouSoughtTreatment.
  ///
  /// In en, this message translates to:
  /// **'Have you sought treatment?'**
  String get haveYouSoughtTreatment;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @stressIncontinence.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stressIncontinence;

  /// No description provided for @urgeIncontinence.
  ///
  /// In en, this message translates to:
  /// **'Urge'**
  String get urgeIncontinence;

  /// No description provided for @mixedIncontinence.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixedIncontinence;

  /// No description provided for @unknownIncontinence.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownIncontinence;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @whatIsUrinaryIncontinence.
  ///
  /// In en, this message translates to:
  /// **'What is Urinary Incontinence?'**
  String get whatIsUrinaryIncontinence;

  /// No description provided for @understandingBasics.
  ///
  /// In en, this message translates to:
  /// **'Understanding the basics'**
  String get understandingBasics;

  /// No description provided for @typesOfIncontinence.
  ///
  /// In en, this message translates to:
  /// **'Types of Incontinence'**
  String get typesOfIncontinence;

  /// No description provided for @stressUrgeMixed.
  ///
  /// In en, this message translates to:
  /// **'Stress, Urge and Mixed'**
  String get stressUrgeMixed;

  /// No description provided for @pelvicFloorMuscles.
  ///
  /// In en, this message translates to:
  /// **'Pelvic Floor Muscles Explained'**
  String get pelvicFloorMuscles;

  /// No description provided for @anatomyFunction.
  ///
  /// In en, this message translates to:
  /// **'Anatomy and function'**
  String get anatomyFunction;

  /// No description provided for @howPfmtWorks.
  ///
  /// In en, this message translates to:
  /// **'How PFMT Works'**
  String get howPfmtWorks;

  /// No description provided for @scienceBehindExercises.
  ///
  /// In en, this message translates to:
  /// **'The science behind the exercises'**
  String get scienceBehindExercises;

  /// No description provided for @lifestyleChanges.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle Changes That Help'**
  String get lifestyleChanges;

  /// No description provided for @dietFluidHabits.
  ///
  /// In en, this message translates to:
  /// **'Diet, fluid intake and habits'**
  String get dietFluidHabits;

  /// No description provided for @whenToSeeDoctor.
  ///
  /// In en, this message translates to:
  /// **'When to See a Doctor'**
  String get whenToSeeDoctor;

  /// No description provided for @redFlagsReferrals.
  ///
  /// In en, this message translates to:
  /// **'Red flags and referrals'**
  String get redFlagsReferrals;

  /// No description provided for @whatIsUrinaryIncontinenceDetail.
  ///
  /// In en, this message translates to:
  /// **'Urinary incontinence is the involuntary leakage of urine. It is a common condition that affects millions of people worldwide. Understanding the cause is the first step toward effective management. This section will help you learn the basics of what urinary incontinence is and why it happens.'**
  String get whatIsUrinaryIncontinenceDetail;

  /// No description provided for @typesOfIncontinenceDetail.
  ///
  /// In en, this message translates to:
  /// **'There are several types of incontinence: Stress incontinence (leakage during coughing, sneezing, or exercise), Urge incontinence (sudden, intense urge to urinate followed by leakage), and Mixed incontinence (a combination of both). Each type may require different approaches to treatment.'**
  String get typesOfIncontinenceDetail;

  /// No description provided for @pelvicFloorMusclesDetail.
  ///
  /// In en, this message translates to:
  /// **'The pelvic floor muscles form a supportive hammock across the bottom of the pelvis. They support the bladder, bowel, and uterus. Weakness in these muscles can lead to incontinence. Learning to locate and contract these muscles correctly is key to pelvic floor training.'**
  String get pelvicFloorMusclesDetail;

  /// No description provided for @howPfmtWorksDetail.
  ///
  /// In en, this message translates to:
  /// **'Pelvic Floor Muscle Training (PFMT) strengthens the pelvic floor muscles through repeated contractions. Regular exercise improves muscle tone, endurance, and coordination. Over time, this can reduce or eliminate leakage episodes.'**
  String get howPfmtWorksDetail;

  /// No description provided for @lifestyleChangesDetail.
  ///
  /// In en, this message translates to:
  /// **'Simple lifestyle adjustments can significantly improve bladder control: maintain a healthy weight, avoid bladder irritants (caffeine, spicy foods), drink adequate but not excessive fluids, and practice good bathroom habits.'**
  String get lifestyleChangesDetail;

  /// No description provided for @whenToSeeDoctorDetail.
  ///
  /// In en, this message translates to:
  /// **'Consult a healthcare professional if incontinence affects your quality of life, you have pain or blood in urine, symptoms worsen, or you\'re unsure about the cause. Early assessment often leads to better outcomes.'**
  String get whenToSeeDoctorDetail;

  /// No description provided for @weekNumber.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String weekNumber(Object week);

  /// No description provided for @weekProgress.
  ///
  /// In en, this message translates to:
  /// **'Week {currentWeek} of {totalWeeks}'**
  String weekProgress(Object currentWeek, Object totalWeeks);

  /// No description provided for @weekDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Week {weekNumber} — {difficulty}'**
  String weekDifficulty(Object difficulty, Object weekNumber);

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed'**
  String completedCount(Object completed, Object total);

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String seconds(Object seconds);

  /// No description provided for @minutesAndSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}:{seconds}'**
  String minutesAndSeconds(Object minutes, Object seconds);

  /// No description provided for @completeSession.
  ///
  /// In en, this message translates to:
  /// **'Complete Session'**
  String get completeSession;

  /// No description provided for @iciqTitle.
  ///
  /// In en, this message translates to:
  /// **'ICIQ Assessment'**
  String get iciqTitle;

  /// No description provided for @iciqQ1.
  ///
  /// In en, this message translates to:
  /// **'Q1. How often do you leak urine?'**
  String get iciqQ1;

  /// No description provided for @iciqQ1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the option that best matches your week.'**
  String get iciqQ1Subtitle;

  /// No description provided for @iciqQ2.
  ///
  /// In en, this message translates to:
  /// **'Q2. How much urine do you usually leak?'**
  String get iciqQ2;

  /// No description provided for @iciqQ2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the usual amount.'**
  String get iciqQ2Subtitle;

  /// No description provided for @iciqQ3.
  ///
  /// In en, this message translates to:
  /// **'Q3. Overall, how much does leaking urine interfere with your everyday life?'**
  String get iciqQ3;

  /// No description provided for @iciqQ3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'0 means not at all, 10 means a great deal.'**
  String get iciqQ3Subtitle;

  /// No description provided for @iciqQ4.
  ///
  /// In en, this message translates to:
  /// **'Q4-Q6. When does urine leak?'**
  String get iciqQ4;

  /// No description provided for @iciqQ4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply.'**
  String get iciqQ4Subtitle;

  /// No description provided for @iciqImpactScore.
  ///
  /// In en, this message translates to:
  /// **'Impact score'**
  String get iciqImpactScore;

  /// No description provided for @iciqScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get iciqScore;

  /// No description provided for @iciqSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get iciqSeverity;

  /// No description provided for @iciqResultTitle.
  ///
  /// In en, this message translates to:
  /// **'ICIQ Result'**
  String get iciqResultTitle;

  /// No description provided for @iciqConsultDoctor.
  ///
  /// In en, this message translates to:
  /// **'Please consult a medical professional before proceeding'**
  String get iciqConsultDoctor;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @onceAWeekOrLess.
  ///
  /// In en, this message translates to:
  /// **'About once a week or less'**
  String get onceAWeekOrLess;

  /// No description provided for @twoOrThreeTimesAWeek.
  ///
  /// In en, this message translates to:
  /// **'Two or three times a week'**
  String get twoOrThreeTimesAWeek;

  /// No description provided for @onceADay.
  ///
  /// In en, this message translates to:
  /// **'About once a day'**
  String get onceADay;

  /// No description provided for @severalTimesADay.
  ///
  /// In en, this message translates to:
  /// **'Several times a day'**
  String get severalTimesADay;

  /// No description provided for @allTheTime.
  ///
  /// In en, this message translates to:
  /// **'All the time'**
  String get allTheTime;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @smallAmount.
  ///
  /// In en, this message translates to:
  /// **'A small amount'**
  String get smallAmount;

  /// No description provided for @moderateAmount.
  ///
  /// In en, this message translates to:
  /// **'A moderate amount'**
  String get moderateAmount;

  /// No description provided for @largeAmount.
  ///
  /// In en, this message translates to:
  /// **'A large amount'**
  String get largeAmount;

  /// No description provided for @severityNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get severityNone;

  /// No description provided for @severityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severityMild;

  /// No description provided for @severityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// No description provided for @severitySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// No description provided for @severityVerySevere.
  ///
  /// In en, this message translates to:
  /// **'Very Severe'**
  String get severityVerySevere;

  /// No description provided for @leaksBeforeToilet.
  ///
  /// In en, this message translates to:
  /// **'Leaks before reaching the toilet'**
  String get leaksBeforeToilet;

  /// No description provided for @leaksWhenCoughSneeze.
  ///
  /// In en, this message translates to:
  /// **'Leaks when coughing or sneezing'**
  String get leaksWhenCoughSneeze;

  /// No description provided for @leaksDuringActivity.
  ///
  /// In en, this message translates to:
  /// **'Leaks during physical activity'**
  String get leaksDuringActivity;

  /// No description provided for @ipaqTitle.
  ///
  /// In en, this message translates to:
  /// **'IPAQ Screening'**
  String get ipaqTitle;

  /// No description provided for @ipaqInstruction.
  ///
  /// In en, this message translates to:
  /// **'Think about physical activities over the last 7 days.'**
  String get ipaqInstruction;

  /// No description provided for @ipaqQ1.
  ///
  /// In en, this message translates to:
  /// **'During the last 7 days, how much time did you spend sitting during a day? Include time at work, home, course work, and leisure (desk, reading, TV).'**
  String get ipaqQ1;

  /// No description provided for @ipaqQ2.
  ///
  /// In en, this message translates to:
  /// **'During the last 7 days, on how many days did you walk for at least 10 minutes at a time? (Includes walking at work, home, travel, recreation, sport, exercise, or leisure.)'**
  String get ipaqQ2;

  /// No description provided for @ipaqQ2DurationPrompt.
  ///
  /// In en, this message translates to:
  /// **'How much time did you usually spend walking on one of those days?'**
  String get ipaqQ2DurationPrompt;

  /// No description provided for @ipaqQ3.
  ///
  /// In en, this message translates to:
  /// **'During the last 7 days, on how many days did you do moderate physical activities like gardening, cleaning, bicycling at a regular pace, swimming or other fitness activities? (At least 10 minutes at a time. Do not include walking.)'**
  String get ipaqQ3;

  /// No description provided for @ipaqQ3DurationPrompt.
  ///
  /// In en, this message translates to:
  /// **'How much time did you usually spend doing moderate activities on one of those days?'**
  String get ipaqQ3DurationPrompt;

  /// No description provided for @ipaqQ4.
  ///
  /// In en, this message translates to:
  /// **'During the last 7 days, on how many days did you do vigorous physical activities like heavy lifting, heavier garden/construction work, chopping wood, aerobics, jogging/running, or fast bicycling? (At least 10 minutes at a time.)'**
  String get ipaqQ4;

  /// No description provided for @ipaqQ4DurationPrompt.
  ///
  /// In en, this message translates to:
  /// **'How much time did you usually spend doing vigorous activities on one of those days?'**
  String get ipaqQ4DurationPrompt;

  /// No description provided for @ipaqQ5.
  ///
  /// In en, this message translates to:
  /// **'During the last 7 days, on how many days did you walk for at least 10 minutes at a time? (Walking to travel from place to place, or solely for recreation, sport, exercise, or leisure.)'**
  String get ipaqQ5;

  /// No description provided for @ipaqQ5DurationPrompt.
  ///
  /// In en, this message translates to:
  /// **'How much time did you usually spend walking on one of those days?'**
  String get ipaqQ5DurationPrompt;

  /// No description provided for @ipaqQ6.
  ///
  /// In en, this message translates to:
  /// **'On those days when you did moderate physical activities, how much time did you usually spend doing them?'**
  String get ipaqQ6;

  /// No description provided for @ipaqQ7.
  ///
  /// In en, this message translates to:
  /// **'During the last 7 days, on a weekday (Monday–Friday), how much time did you spend sitting?'**
  String get ipaqQ7;

  /// No description provided for @ipaqResultTitle.
  ///
  /// In en, this message translates to:
  /// **'IPAQ-E Recorded'**
  String get ipaqResultTitle;

  /// No description provided for @ipaqRecordedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your physical activity responses have been recorded.'**
  String get ipaqRecordedMessage;

  /// No description provided for @completeAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'Please complete all questions'**
  String get completeAllQuestions;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @noDay.
  ///
  /// In en, this message translates to:
  /// **'No day'**
  String get noDay;

  /// No description provided for @iqolTitle.
  ///
  /// In en, this message translates to:
  /// **'I-QOL Assessment'**
  String get iqolTitle;

  /// No description provided for @iqolYourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get iqolYourScore;

  /// No description provided for @iqolResultTitle.
  ///
  /// In en, this message translates to:
  /// **'I-QOL Result'**
  String get iqolResultTitle;

  /// No description provided for @iqolHigherScoreBetter.
  ///
  /// In en, this message translates to:
  /// **'Higher score = better quality of life.'**
  String get iqolHigherScoreBetter;

  /// No description provided for @iqolMinimalImpact.
  ///
  /// In en, this message translates to:
  /// **'Minimal Impact'**
  String get iqolMinimalImpact;

  /// No description provided for @iqolMildImpact.
  ///
  /// In en, this message translates to:
  /// **'Mild Impact'**
  String get iqolMildImpact;

  /// No description provided for @iqolModerateImpact.
  ///
  /// In en, this message translates to:
  /// **'Moderate Impact'**
  String get iqolModerateImpact;

  /// No description provided for @iqolSevereImpact.
  ///
  /// In en, this message translates to:
  /// **'Severe Impact'**
  String get iqolSevereImpact;

  /// No description provided for @iqolAnsweredCount.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} answered'**
  String iqolAnsweredCount(Object answered, Object total);

  /// No description provided for @iqolExtremely.
  ///
  /// In en, this message translates to:
  /// **'Extremely'**
  String get iqolExtremely;

  /// No description provided for @iqolQuiteABit.
  ///
  /// In en, this message translates to:
  /// **'Quite a bit'**
  String get iqolQuiteABit;

  /// No description provided for @iqolModerately.
  ///
  /// In en, this message translates to:
  /// **'Moderately'**
  String get iqolModerately;

  /// No description provided for @iqolALittle.
  ///
  /// In en, this message translates to:
  /// **'A little'**
  String get iqolALittle;

  /// No description provided for @iqolNotAtAll.
  ///
  /// In en, this message translates to:
  /// **'Not at all'**
  String get iqolNotAtAll;

  /// No description provided for @iqolQ1.
  ///
  /// In en, this message translates to:
  /// **'I worry about not being able to get to the toilet on time.'**
  String get iqolQ1;

  /// No description provided for @iqolQ2.
  ///
  /// In en, this message translates to:
  /// **'I worry about coughing or sneezing because of my urinary problems.'**
  String get iqolQ2;

  /// No description provided for @iqolQ3.
  ///
  /// In en, this message translates to:
  /// **'I have to be careful standing up after sitting down because of my urinary problems.'**
  String get iqolQ3;

  /// No description provided for @iqolQ4.
  ///
  /// In en, this message translates to:
  /// **'I worry about where toilets are in new places.'**
  String get iqolQ4;

  /// No description provided for @iqolQ5.
  ///
  /// In en, this message translates to:
  /// **'I feel depressed because of my urinary problems.'**
  String get iqolQ5;

  /// No description provided for @iqolQ6.
  ///
  /// In en, this message translates to:
  /// **'I don\'t feel free to leave my home for long periods because of my urinary problems.'**
  String get iqolQ6;

  /// No description provided for @iqolQ7.
  ///
  /// In en, this message translates to:
  /// **'I feel frustrated because my urinary problems prevent me from doing what I want.'**
  String get iqolQ7;

  /// No description provided for @iqolQ8.
  ///
  /// In en, this message translates to:
  /// **'I worry about others smelling urine on me.'**
  String get iqolQ8;

  /// No description provided for @iqolQ9.
  ///
  /// In en, this message translates to:
  /// **'My urinary problems are always on my mind.'**
  String get iqolQ9;

  /// No description provided for @iqolQ10.
  ///
  /// In en, this message translates to:
  /// **'It\'s important for me to make frequent trips to the toilet.'**
  String get iqolQ10;

  /// No description provided for @iqolQ11.
  ///
  /// In en, this message translates to:
  /// **'Because of my urinary problems, it\'s important to plan every detail in advance.'**
  String get iqolQ11;

  /// No description provided for @iqolQ12.
  ///
  /// In en, this message translates to:
  /// **'I worry about my urinary problems getting worse as I grow older.'**
  String get iqolQ12;

  /// No description provided for @iqolQ13.
  ///
  /// In en, this message translates to:
  /// **'I have a hard time getting a good night of sleep because of my urinary problems.'**
  String get iqolQ13;

  /// No description provided for @iqolQ14.
  ///
  /// In en, this message translates to:
  /// **'I worry about being embarrassed or humiliated because of my urinary problems.'**
  String get iqolQ14;

  /// No description provided for @iqolQ15.
  ///
  /// In en, this message translates to:
  /// **'My urinary problems make me feel like I\'m not a healthy person.'**
  String get iqolQ15;

  /// No description provided for @iqolQ16.
  ///
  /// In en, this message translates to:
  /// **'My urinary problems make me feel helpless.'**
  String get iqolQ16;

  /// No description provided for @iqolQ17.
  ///
  /// In en, this message translates to:
  /// **'I get less enjoyment out of life because of my urinary problems.'**
  String get iqolQ17;

  /// No description provided for @iqolQ18.
  ///
  /// In en, this message translates to:
  /// **'I worry about wetting myself.'**
  String get iqolQ18;

  /// No description provided for @iqolQ19.
  ///
  /// In en, this message translates to:
  /// **'I feel like I have no control over my bladder.'**
  String get iqolQ19;

  /// No description provided for @iqolQ20.
  ///
  /// In en, this message translates to:
  /// **'I have to watch what or how much I drink because of my urinary problems.'**
  String get iqolQ20;

  /// No description provided for @iqolQ21.
  ///
  /// In en, this message translates to:
  /// **'My urinary problems limit my choice of clothing.'**
  String get iqolQ21;

  /// No description provided for @iqolQ22.
  ///
  /// In en, this message translates to:
  /// **'I worry about having sex because of my urinary problems.'**
  String get iqolQ22;

  /// No description provided for @bladderDiaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Bladder Diary'**
  String get bladderDiaryTitle;

  /// No description provided for @day1.
  ///
  /// In en, this message translates to:
  /// **'Day 1'**
  String get day1;

  /// No description provided for @day2.
  ///
  /// In en, this message translates to:
  /// **'Day 2'**
  String get day2;

  /// No description provided for @day3.
  ///
  /// In en, this message translates to:
  /// **'Day 3'**
  String get day3;

  /// No description provided for @bed.
  ///
  /// In en, this message translates to:
  /// **'BED'**
  String get bed;

  /// No description provided for @woke.
  ///
  /// In en, this message translates to:
  /// **'WOKE'**
  String get woke;

  /// No description provided for @drinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get drinks;

  /// No description provided for @amountMlCups.
  ///
  /// In en, this message translates to:
  /// **'Amount (ml / cups)'**
  String get amountMlCups;

  /// No description provided for @fluidType.
  ///
  /// In en, this message translates to:
  /// **'Type (water, tea…)'**
  String get fluidType;

  /// No description provided for @urineOutput.
  ///
  /// In en, this message translates to:
  /// **'Urine Output'**
  String get urineOutput;

  /// No description provided for @mlOrLeak.
  ///
  /// In en, this message translates to:
  /// **'ml (or write LEAK)'**
  String get mlOrLeak;

  /// No description provided for @cantMeasure.
  ///
  /// In en, this message translates to:
  /// **'Can\'t measure'**
  String get cantMeasure;

  /// No description provided for @bladderSensation.
  ///
  /// In en, this message translates to:
  /// **'Bladder Sensation'**
  String get bladderSensation;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select (0–4)'**
  String get tapToSelect;

  /// No description provided for @pad.
  ///
  /// In en, this message translates to:
  /// **'Pad'**
  String get pad;

  /// No description provided for @sensationAbbr.
  ///
  /// In en, this message translates to:
  /// **'S:'**
  String get sensationAbbr;

  /// No description provided for @tapToAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Tap to add entry'**
  String get tapToAddEntry;

  /// No description provided for @sensationCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Bladder Sensation Codes'**
  String get sensationCodesTitle;

  /// No description provided for @sensationCodes.
  ///
  /// In en, this message translates to:
  /// **'Sensation codes'**
  String get sensationCodes;

  /// No description provided for @selectCodeFor.
  ///
  /// In en, this message translates to:
  /// **'Select code for'**
  String get selectCodeFor;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @diarySubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary Submitted'**
  String get diarySubmittedTitle;

  /// No description provided for @diarySubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your 3-day bladder diary has been recorded successfully.'**
  String get diarySubmittedMessage;

  /// No description provided for @submitDiary.
  ///
  /// In en, this message translates to:
  /// **'Submit 3-Day Diary'**
  String get submitDiary;

  /// No description provided for @sensation0.
  ///
  /// In en, this message translates to:
  /// **'0 – No urge, social reason'**
  String get sensation0;

  /// No description provided for @sensation1.
  ///
  /// In en, this message translates to:
  /// **'1 – Normal desire, no urgency'**
  String get sensation1;

  /// No description provided for @sensation2.
  ///
  /// In en, this message translates to:
  /// **'2 – Urgency, passed before toilet'**
  String get sensation2;

  /// No description provided for @sensation3.
  ///
  /// In en, this message translates to:
  /// **'3 – Urgency, reached toilet, no leak'**
  String get sensation3;

  /// No description provided for @sensation4.
  ///
  /// In en, this message translates to:
  /// **'4 – Urgency, could not reach toilet, leaked'**
  String get sensation4;

  /// No description provided for @time6am.
  ///
  /// In en, this message translates to:
  /// **'6am'**
  String get time6am;

  /// No description provided for @time7am.
  ///
  /// In en, this message translates to:
  /// **'7am'**
  String get time7am;

  /// No description provided for @time8am.
  ///
  /// In en, this message translates to:
  /// **'8am'**
  String get time8am;

  /// No description provided for @time9am.
  ///
  /// In en, this message translates to:
  /// **'9am'**
  String get time9am;

  /// No description provided for @time10am.
  ///
  /// In en, this message translates to:
  /// **'10am'**
  String get time10am;

  /// No description provided for @time11am.
  ///
  /// In en, this message translates to:
  /// **'11am'**
  String get time11am;

  /// No description provided for @timeMidday.
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get timeMidday;

  /// No description provided for @time1pm.
  ///
  /// In en, this message translates to:
  /// **'1pm'**
  String get time1pm;

  /// No description provided for @time2pm.
  ///
  /// In en, this message translates to:
  /// **'2pm'**
  String get time2pm;

  /// No description provided for @time3pm.
  ///
  /// In en, this message translates to:
  /// **'3pm'**
  String get time3pm;

  /// No description provided for @time4pm.
  ///
  /// In en, this message translates to:
  /// **'4pm'**
  String get time4pm;

  /// No description provided for @time5pm.
  ///
  /// In en, this message translates to:
  /// **'5pm'**
  String get time5pm;

  /// No description provided for @time6pm.
  ///
  /// In en, this message translates to:
  /// **'6pm'**
  String get time6pm;

  /// No description provided for @time7pm.
  ///
  /// In en, this message translates to:
  /// **'7pm'**
  String get time7pm;

  /// No description provided for @time8pm.
  ///
  /// In en, this message translates to:
  /// **'8pm'**
  String get time8pm;

  /// No description provided for @time9pm.
  ///
  /// In en, this message translates to:
  /// **'9pm'**
  String get time9pm;

  /// No description provided for @time10pm.
  ///
  /// In en, this message translates to:
  /// **'10pm'**
  String get time10pm;

  /// No description provided for @time11pm.
  ///
  /// In en, this message translates to:
  /// **'11pm'**
  String get time11pm;

  /// No description provided for @timeMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get timeMidnight;

  /// No description provided for @time1am.
  ///
  /// In en, this message translates to:
  /// **'1am'**
  String get time1am;

  /// No description provided for @time2am.
  ///
  /// In en, this message translates to:
  /// **'2am'**
  String get time2am;

  /// No description provided for @time3am.
  ///
  /// In en, this message translates to:
  /// **'3am'**
  String get time3am;

  /// No description provided for @time4am.
  ///
  /// In en, this message translates to:
  /// **'4am'**
  String get time4am;

  /// No description provided for @time5am.
  ///
  /// In en, this message translates to:
  /// **'5am'**
  String get time5am;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @incontinenceType.
  ///
  /// In en, this message translates to:
  /// **'Incontinence type'**
  String get incontinenceType;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @diary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diary;

  /// No description provided for @navAssessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get navAssessment;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekLabel;

  /// No description provided for @assessmentNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get assessmentNext;

  /// No description provided for @assessmentBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get assessmentBack;

  /// No description provided for @assessmentResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get assessmentResult;

  /// No description provided for @assessmentStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String assessmentStep(Object step, Object total);

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @iciq_q3.
  ///
  /// In en, this message translates to:
  /// **'How often do you leak urine?'**
  String get iciq_q3;

  /// No description provided for @iciq_q4.
  ///
  /// In en, this message translates to:
  /// **'How much urine do you usually leak?'**
  String get iciq_q4;

  /// No description provided for @iciq_q5.
  ///
  /// In en, this message translates to:
  /// **'Overall, how much does leaking urine interfere with your everyday life?'**
  String get iciq_q5;

  /// No description provided for @iciq_q6.
  ///
  /// In en, this message translates to:
  /// **'When does urine leak?'**
  String get iciq_q6;

  /// No description provided for @iciqWhenLeaksNever.
  ///
  /// In en, this message translates to:
  /// **'Never - urine does not leak'**
  String get iciqWhenLeaksNever;

  /// No description provided for @iciqWhenLeaksBeforeToilet.
  ///
  /// In en, this message translates to:
  /// **'Leaks before reaching the toilet'**
  String get iciqWhenLeaksBeforeToilet;

  /// No description provided for @iciqWhenLeaksCoughSneeze.
  ///
  /// In en, this message translates to:
  /// **'Leaks when coughing or sneezing'**
  String get iciqWhenLeaksCoughSneeze;

  /// No description provided for @iciqWhenLeaksAsleep.
  ///
  /// In en, this message translates to:
  /// **'Leaks when asleep'**
  String get iciqWhenLeaksAsleep;

  /// No description provided for @iciqWhenLeaksActivity.
  ///
  /// In en, this message translates to:
  /// **'Leaks during physical activity'**
  String get iciqWhenLeaksActivity;

  /// No description provided for @iciqWhenLeaksAfterUrination.
  ///
  /// In en, this message translates to:
  /// **'Leaks after finishing urination and dressed'**
  String get iciqWhenLeaksAfterUrination;

  /// No description provided for @iciqWhenLeaksNoReason.
  ///
  /// In en, this message translates to:
  /// **'Leaks for no obvious reason'**
  String get iciqWhenLeaksNoReason;

  /// No description provided for @iciqWhenLeaksAllTime.
  ///
  /// In en, this message translates to:
  /// **'Leaks all the time'**
  String get iciqWhenLeaksAllTime;

  /// No description provided for @iqolAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get iqolAboutTitle;

  /// No description provided for @iqol_about_q1.
  ///
  /// In en, this message translates to:
  /// **'How many years have you had urinary problems?'**
  String get iqol_about_q1;

  /// No description provided for @iqol_about_q2.
  ///
  /// In en, this message translates to:
  /// **'Additional months with urinary problems'**
  String get iqol_about_q2;

  /// No description provided for @iqol_about_q3.
  ///
  /// In en, this message translates to:
  /// **'How severe is your urinary problem?'**
  String get iqol_about_q3;

  /// No description provided for @iqol_about_q4.
  ///
  /// In en, this message translates to:
  /// **'Do you leak with coughing, sneezing, or activity?'**
  String get iqol_about_q4;

  /// No description provided for @iqol_about_q5.
  ///
  /// In en, this message translates to:
  /// **'Do you leak with a sudden urge to urinate?'**
  String get iqol_about_q5;

  /// No description provided for @iqol_about_q6.
  ///
  /// In en, this message translates to:
  /// **'How often do you leak urine?'**
  String get iqol_about_q6;

  /// No description provided for @iqolScoreOutOf100.
  ///
  /// In en, this message translates to:
  /// **'Score out of 100'**
  String get iqolScoreOutOf100;

  /// No description provided for @ipaq_q1.
  ///
  /// In en, this message translates to:
  /// **'Sitting time'**
  String get ipaq_q1;

  /// No description provided for @ipaq_q2.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get ipaq_q2;

  /// No description provided for @ipaq_q3.
  ///
  /// In en, this message translates to:
  /// **'Moderate activity'**
  String get ipaq_q3;

  /// No description provided for @ipaq_q4.
  ///
  /// In en, this message translates to:
  /// **'Vigorous activity'**
  String get ipaq_q4;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activityLevel;

  /// No description provided for @activityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get activityLow;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get activityModerate;

  /// No description provided for @activityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get activityHigh;

  /// No description provided for @totalMetMinutes.
  ///
  /// In en, this message translates to:
  /// **'Total MET-minutes'**
  String get totalMetMinutes;

  /// No description provided for @notAtAll.
  ///
  /// In en, this message translates to:
  /// **'Not at all'**
  String get notAtAll;

  /// No description provided for @aGreatDeal.
  ///
  /// In en, this message translates to:
  /// **'A great deal'**
  String get aGreatDeal;

  /// No description provided for @thisQuestionIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This question is required'**
  String get thisQuestionIsRequired;

  /// No description provided for @noDays.
  ///
  /// In en, this message translates to:
  /// **'No days'**
  String get noDays;

  /// No description provided for @allSevenDays.
  ///
  /// In en, this message translates to:
  /// **'All seven days'**
  String get allSevenDays;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @iciqHighSeverityTitle.
  ///
  /// In en, this message translates to:
  /// **'High Severity Detected'**
  String get iciqHighSeverityTitle;

  /// No description provided for @iciqHighSeverityMessage.
  ///
  /// In en, this message translates to:
  /// **'Based on your responses, your symptoms appear severe. Please consult a medical professional for a thorough evaluation before continuing with this program.'**
  String get iciqHighSeverityMessage;

  /// No description provided for @iciqOfferExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Exercises?'**
  String get iciqOfferExercisesTitle;

  /// No description provided for @iciqOfferExercisesMessage.
  ///
  /// In en, this message translates to:
  /// **'Would you like to continue with the physical activity assessment?'**
  String get iciqOfferExercisesMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
