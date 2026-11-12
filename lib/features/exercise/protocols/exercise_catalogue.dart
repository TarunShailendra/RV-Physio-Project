/// Every exercise the protocol document prescribes, keyed by the identifier
/// used in the protocol tables and written to exercise_logs.exercise_key.
///
/// The display names are English. Patient-facing instructional text lives in
/// content/exercise_content.dart, which is where translations will be added.
const Map<String, String> exerciseCatalogue = {
  'pfmt_slow': 'Slow squeeze and hold',
  'pfmt_quick': 'Quick squeezes',
  'diaphragmatic_breathing': 'Diaphragmatic breathing',
  'pelvic_bridging': 'Pelvic bridging',
  'pelvic_tilt': 'Pelvic tilt',
  'pelvic_rotations': 'Pelvic rotations',
  'leg_circles': 'Leg circles',
  'single_leg_stretch': 'Single leg stretch',
  'straight_leg_raise': 'Straight leg raise',
  'side_leg_raise': 'Side leg raise',
  'wall_squat': 'Wall squat',
  'quadruped_arm_leg_raise': 'Quadruped arm-leg raise',
  'clamshells': 'Clamshells',
  'lunges': 'Lunges',
  'squats': 'Squats',
  'leg_scissors': 'Leg scissors',
};

/// Whether [key] is one of the two pelvic floor training items, which carry a
/// body position and a relax time that the general exercises do not.
bool isPfmt(String key) => key == 'pfmt_slow' || key == 'pfmt_quick';
