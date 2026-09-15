/// Patient-facing instructions for one exercise, in one language.
class ExerciseText {
  const ExerciseText({
    required this.startingPosition,
    required this.steps,
    required this.dos,
    required this.donts,
    this.tip,
  });

  final String startingPosition;
  final List<String> steps;
  final String? tip;
  final List<String> dos;
  final List<String> donts;
}

/// One exercise's instructions in every language the app has them in.
///
/// [kn] is null for every exercise today. These are clinical safety
/// instructions and were deliberately not machine-translated; a translator
/// fills this field in without touching any other code, and until they do, a
/// Kannada reader sees the English text rather than a blank page.
class ExerciseContent {
  const ExerciseContent({required this.en, this.kn});

  final ExerciseText en;
  final ExerciseText? kn;

  ExerciseText forLocale(String languageCode) =>
      languageCode == 'kn' ? (kn ?? en) : en;
}

/// Instructions for all sixteen exercises, transcribed from the "Exercise
/// Description" section of "App protocols with description.docx".
///
/// Where the document says "as prescribed above", that wording is kept: the
/// detail sheet shows the patient's own reps and hold alongside these steps.
const Map<String, ExerciseContent> exerciseContent = {
  'pfmt_slow': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Start lying on your back with knees bent. As you get stronger, your '
          'plan will have you do this same exercise sitting, and later '
          'standing.',
      steps: [
        'Get into the position - lying, sitting, or standing.',
        'Gently squeeze the muscles you use to stop the flow of urine while '
            'urinating.',
        'Hold the squeeze gently for the seconds prescribed.',
        'Relax fully and rest for a few seconds.',
        'Repeat as prescribed.',
      ],
      dos: [
        'Keep breathing normally while you hold the squeeze.',
        'Squeeze gently; a little effort is enough.',
        'Fully relax between each squeeze.',
        'Keep your legs, tummy, and bottom relaxed.',
      ],
      donts: [
        "Don't hold your breath.",
        "Don't squeeze so hard that you shake or strain.",
        "Don't tighten your stomach, thighs, or bottom instead.",
        "Don't try this exercise while you are actually urinating.",
      ],
    ),
  ),
  'pfmt_quick': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Same as Slow Squeeze and Hold - lying, sitting, or standing, '
          'depending on your plan.',
      steps: [
        'Get into the position your plan asks for.',
        'Squeeze the muscles you use to stop the flow of urine while '
            'urinating, quickly, and let go right away.',
        'Repeat as prescribed.',
      ],
      tip:
          'This trains your muscles to react fast and is useful for moments '
          'like coughing, sneezing, or laughing.',
      dos: [
        'Keep each squeeze short and quick.',
        'Breathe normally throughout.',
        'Rest for a few seconds between rounds.',
      ],
      donts: [
        "Don't hold the squeeze - let go right away.",
        "Don't clench your stomach, thighs, or bottom.",
        "Don't rush so much that you lose control of the squeeze.",
      ],
    ),
  ),
  'diaphragmatic_breathing': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back with your knees bent and feet flat on the floor. '
          '(You can also sit tall in a chair.)',
      steps: [
        'Place one hand on your chest and one hand on your belly.',
        'Breathe in slowly through your nose and let your belly rise. Your '
            'chest should stay still.',
        'Breathe out slowly through your mouth and let your belly fall back '
            'down.',
        'Keep breathing slowly and gently.',
      ],
      tip:
          'This exercise helps you relax and connect your breathing to your '
          'bladder control muscles before you start squeezing them.',
      dos: [
        'Keep your shoulders soft and relaxed.',
        'Breathe slowly and smoothly.',
        'Practice somewhere quiet and comfortable.',
      ],
      donts: [
        "Don't force your breath in or out.",
        "Don't raise your shoulders up toward your ears.",
        "Don't hold your breath at any point.",
      ],
    ),
  ),
  'pelvic_bridging': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back, knees bent, feet flat on the floor about '
          'hip-width apart, arms resting by your sides.',
      steps: [
        'Gently squeeze the muscles you use to stop the flow of urine while '
            'urinating.',
        'Press your feet into the floor and lift your hips until your body '
            'forms a straight line from shoulders to knees.',
        'Hold for the seconds prescribed.',
        'Lower your hips back down slowly and with control.',
        'Repeat as prescribed.',
      ],
      dos: [
        'Keep your neck and shoulders relaxed on the floor.',
        'Move slowly and with control.',
        'Keep your knees pointing forward.',
      ],
      donts: [
        "Don't arch your lower back too much at the top.",
        "Don't let your knees fall inward or outward.",
        "Don't lift your hips too high or too fast.",
      ],
    ),
  ),
  'pelvic_tilt': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back with your knees bent and feet flat on the floor.',
      steps: [
        'Gently tighten and push your lower belly to flatten your lower back '
            'into the floor.',
        'Hold for the seconds prescribed.',
        'Release and let your back return to its natural, relaxed state.',
        'Repeat as prescribed.',
      ],
      dos: ['Move gently and slowly.', 'Breathe normally the whole time.'],
      donts: [
        "Don't push so hard that your hips lift off the floor.",
        "Don't hold your breath.",
      ],
    ),
  ),
  'pelvic_rotations': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back with knees bent and feet flat on the floor. Place '
          'both arms spread wide by your side.',
      steps: [
        'Slowly rotate both knees together towards one side as far as '
            'comfortable, keeping your shoulders flat on the floor.',
        'Hold the position for 3 seconds and slowly bring your knees back to '
            'the starting position.',
        'Repeat the movement towards the opposite direction.',
        'Continue alternating sides.',
        'Repeat as prescribed.',
      ],
      dos: [
        'Move slowly and smoothly.',
        'Keep your shoulders flat on the floor.',
        'Move only as far as it feels comfortable.',
      ],
      donts: [
        'Do not move too fast or jerk your body.',
        'Do not lift your shoulders off the floor.',
        'Do not force or push through pain or discomfort.',
      ],
    ),
  ),
  'leg_circles': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back with one leg raised straight up toward the '
          'ceiling. Keep the other knee bent with your foot flat on the floor.',
      steps: [
        'Slowly draw a small circle in the air with your raised leg.',
        'Keep your hips and lower back still and steady on the floor.',
        'Repeat as prescribed.',
        'Switch to the other leg and repeat.',
      ],
      dos: [
        'Keep the circles small and controlled.',
        'Keep your lower back flat on the floor.',
      ],
      donts: [
        "Don't let your lower back arch up off the floor.",
        "Don't swing your leg quickly.",
      ],
    ),
  ),
  'single_leg_stretch': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back with both knees bent up toward your chest.',
      steps: [
        'Keep your head down, or gently lift your head and shoulders if that '
            'is comfortable for you.',
        'Straighten one leg out low, close to the ground, while keeping the '
            'other knee pulled toward your chest.',
        'Hold for the seconds prescribed, then switch legs.',
        'Continue alternating for the number of times prescribed.',
      ],
      dos: [
        'Keep your lower back flat and steady against the floor.',
        'Move at a comfortable, steady pace.',
      ],
      donts: [
        "Don't let your back arch up off the floor.",
        "Don't lower the straight leg so far that your back lifts.",
      ],
    ),
  ),
  'straight_leg_raise': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back. Bend one knee with that foot flat on the floor, '
          'and keep the other leg straight out on the floor.',
      steps: [
        'Gently engage your core and tighten the thigh muscle of the straight '
            'leg.',
        'Keeping that leg straight, slowly lift it up to about the same '
            'height as your other (bent) knee.',
        'Hold for the seconds prescribed.',
        'Slowly lower the leg back down with control, without letting it drop.',
        'Repeat for the prescribed number of repetitions, then switch legs.',
      ],
      dos: [
        'Keep the raised leg fully straight throughout the movement.',
        'Keep your lower back gently pressed toward the floor.',
        'Move slowly on both the lift and the lowering of the leg.',
      ],
      donts: [
        "Don't let the knee bend as you lift.",
        "Don't let your lower back arch up off the floor.",
        "Don't lift higher than the opposite knee; this strains the lower "
            'back unnecessarily.',
      ],
    ),
  ),
  'side_leg_raise': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your side with your bottom leg slightly bent for balance '
          'and your top leg straight.',
      steps: [
        'Lift your top leg straight up toward the ceiling.',
        'Hold for the seconds prescribed.',
        'Lower slowly back down.',
        'Repeat as prescribed.',
        'Switch to the other side and repeat the same process.',
      ],
      dos: [
        'Keep your top leg in line with your body.',
        'Keep your hips stacked, one on top of the other.',
      ],
      donts: [
        "Don't swing your leg.",
        "Don't let your top hip roll backward as you lift.",
      ],
    ),
  ),
  'wall_squat': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Stand with your back against a wall, feet shoulder-width apart, a '
          'small step forward and away from the wall.',
      steps: [
        'Slowly slide down the wall by bending your knees, like sitting into '
            'an invisible chair.',
        'Go down only as far as feels comfortable and controlled.',
        'Hold for the seconds prescribed.',
        'Slide back up slowly.',
        'Repeat as prescribed.',
      ],
      dos: [
        'Keep your knees over your ankles, not out past your toes.',
        'Keep your back flat against the wall.',
      ],
      donts: [
        "Don't let your knees cave inward.",
        "Don't go so low that it hurts your knees.",
      ],
    ),
  ),
  'quadruped_arm_leg_raise': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Get on your hands and knees, with hands under your shoulders and '
          'knees under your hips.',
      steps: [
        'Gently squeeze the muscles you use and your lower belly.',
        'Slowly reach one arm straight forward while straightening the '
            'opposite leg straight back.',
        'Hold briefly, keeping your back flat and steady.',
        'Lower slowly and switch sides.',
      ],
      dos: [
        'Keep your back flat, not arched or rounded.',
        'Move slowly and with control.',
      ],
      donts: [
        "Don't let your hips twist or tilt to one side.",
        "Don't rush the movement.",
      ],
    ),
  ),
  'clamshells': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your side with your knees bent in front of you, one on top '
          'of the other, and your hips stacked.',
      steps: [
        'Keep your feet touching each other.',
        'Lift your top knee up toward the ceiling, like opening a clamshell, '
            'while keeping your feet together.',
        'Hold briefly, then lower slowly.',
        'Repeat, then switch to the other side.',
      ],
      dos: [
        'Keep your hips stacked and steady.',
        'Move slowly and with control.',
      ],
      donts: [
        "Don't roll your top hip backwards.",
        "Don't let your feet come apart.",
      ],
    ),
  ),
  'lunges': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Stand tall with your feet hip-width apart. Hold onto a chair or '
          'something secure nearby if you would like extra balance.',
      steps: [
        'Step one foot forward.',
        'Bend both knees, lowering your back knee toward the floor.',
        'Push back up through your front foot to standing.',
        'Repeat, then switch legs.',
      ],
      dos: [
        'Keep your front knee over your ankle.',
        'Keep your upper body tall.',
        'Hold onto something sturdy for balance if you need to.',
      ],
      donts: [
        "Don't let your front knee go past your toes.",
        "Don't lean your body too far forward.",
      ],
    ),
  ),
  'squats': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Stand with feet shoulder-width apart, toes pointing slightly '
          'outward. Hold onto a sturdy chair if you would like extra balance.',
      steps: [
        'Bend your knees and push your hips back, like sitting into a chair.',
        'Lower yourself as far as feels comfortable.',
        'Push through your feet to stand back up.',
      ],
      dos: [
        'Keep your chest lifted.',
        'Keep your weight through your heels.',
        'Hold onto something firm for balance if needed.',
      ],
      donts: ["Don't let your knees cave inward.", "Don't round your back."],
    ),
  ),
  'leg_scissors': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back with both legs lifted straight up toward the '
          'ceiling.',
      steps: [
        'Slowly lower one leg toward the floor while keeping the other leg '
            'up. Keep both legs straight.',
        'Bring the legs back together, then switch, lowering the other leg.',
        'Keep alternating, like scissors, for the number of times your plan '
            'gives you.',
      ],
      dos: [
        'Keep your lower back flat against the floor.',
        'Move slowly and with control.',
      ],
      donts: [
        "Don't let your back arch up off the floor.",
        "Don't lower your legs so far that you lose control.",
      ],
    ),
  ),
};

/// Safety guidance that applies across every exercise, in addition to each
/// exercise's own DO and DON'T lists.
const List<String> generalDos = [
  'Empty your bladder before starting your pelvic floor exercises.',
  'Warm up gently and perform exercises on a firm, comfortable surface.',
  'Follow the prescribed frequency, repetitions, and hold times for your '
      'current week - do not skip ahead.',
  'Progress gradually, exactly as laid out in your week-by-week plan.',
  'Breathe normally and steadily throughout every exercise.',
  'Stop and consult your physiotherapist or doctor if you feel pain, unusual '
      'heaviness, or leakage during an exercise.',
];

const List<String> generalDonts = [
  "Don't hold your breath or strain during any exercise.",
  "Don't push through sharp, worsening, or lasting pain.",
  "Don't skip a progression level or increase intensity faster than "
      'prescribed.',
  "Don't substitute your buttocks, thighs, or abdominal muscles for the "
      'pelvic floor during PFMT.',
];
