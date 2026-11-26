import 'package:material_ui/material_ui.dart';
import '../theme/app_theme.dart';

/// Represents the exact 10 input features expected by ml_model/student_model.pkl
/// and the backend /predict endpoint.
class StudentInput {
  const StudentInput({
    required this.g1,
    required this.g2,
    required this.absences,
    required this.studytime,
    required this.failures,
    required this.age,
    required this.schoolsup,
    required this.activities,
    required this.internet,
    required this.higher,
  });

  final double g1;
  final double g2;
  final int absences;
  final int studytime;
  final int failures;
  final int age;
  final bool schoolsup;
  final bool activities;
  final bool internet;
  final bool higher;

  factory StudentInput.defaults() => const StudentInput(
        g1: 12,
        g2: 13,
        absences: 3,
        studytime: 2,
        failures: 0,
        age: 17,
        schoolsup: false,
        activities: true,
        internet: true,
        higher: true,
      );

  factory StudentInput.highAchiever() => const StudentInput(
        g1: 17,
        g2: 18,
        absences: 1,
        studytime: 4,
        failures: 0,
        age: 17,
        schoolsup: false,
        activities: true,
        internet: true,
        higher: true,
      );

  factory StudentInput.needsSupport() => const StudentInput(
        g1: 7,
        g2: 6,
        absences: 16,
        studytime: 1,
        failures: 2,
        age: 18,
        schoolsup: true,
        activities: false,
        internet: false,
        higher: true,
      );

  StudentInput copyWith({
    double? g1,
    double? g2,
    int? absences,
    int? studytime,
    int? failures,
    int? age,
    bool? schoolsup,
    bool? activities,
    bool? internet,
    bool? higher,
  }) {
    return StudentInput(
      g1: g1 ?? this.g1,
      g2: g2 ?? this.g2,
      absences: absences ?? this.absences,
      studytime: studytime ?? this.studytime,
      failures: failures ?? this.failures,
      age: age ?? this.age,
      schoolsup: schoolsup ?? this.schoolsup,
      activities: activities ?? this.activities,
      internet: internet ?? this.internet,
      higher: higher ?? this.higher,
    );
  }

  /// Produces JSON matching the exact keys expected by backend/app.py.
  Map<String, dynamic> toJson() => {
        'G1': g1,
        'G2': g2,
        'absences': absences,
        'studytime': studytime,
        'failures': failures,
        'age': age,
        'schoolsup': schoolsup ? 'yes' : 'no',
        'activities': activities ? 'yes' : 'no',
        'internet': internet ? 'yes' : 'no',
        'higher': higher ? 'yes' : 'no',
      };

  static String studyTimeLabel(int level) {
    switch (level) {
      case 1:
        return '< 2 hours / week';
      case 2:
        return '2 – 5 hours / week';
      case 3:
        return '5 – 10 hours / week';
      case 4:
        return '> 10 hours / week';
      default:
        return '2 – 5 hours / week';
    }
  }
}

class PredictionResult {
  const PredictionResult({
    required this.predictedG3,
    required this.input,
    required this.timestamp,
    required this.responseMs,
  });

  final double predictedG3;
  final StudentInput input;
  final DateTime timestamp;
  final int responseMs;

  bool get isPassing => predictedG3 >= 10.0;

  String get performanceBand {
    if (predictedG3 >= 16.0) return 'Distinction';
    if (predictedG3 >= 13.0) return 'Strong Performance';
    if (predictedG3 >= 10.0) return 'Passing Track';
    return 'Needs Support';
  }

  Color get accentColor {
    if (predictedG3 >= 16.0) return AppColors.cyanBright;
    if (predictedG3 >= 13.0) return AppColors.emerald;
    if (predictedG3 >= 10.0) return AppColors.amber;
    return AppColors.rose;
  }

  List<String> buildInsights() {
    final tips = <String>[];
    if (input.g2 >= 14) {
      tips.add(
          'Strong 2nd period grade (${input.g2.toStringAsFixed(0)}/20) anchors a high final trajectory.');
    } else if (input.g2 < 10) {
      tips.add(
          'Boosting 2nd period mastery (${input.g2.toStringAsFixed(0)}/20) has the highest impact on G3.');
    }
    if (input.absences > 10) {
      tips.add(
          'High absences (${input.absences}) introduce grade volatility—consistent attendance helps significantly.');
    } else {
      tips.add(
          'Low absence count (${input.absences}) keeps your performance projection stable.');
    }
    if (input.studytime >= 3) {
      tips.add(
          'Weekly study commitment (${StudentInput.studyTimeLabel(input.studytime)}) reinforces retention.');
    } else {
      tips.add(
          'Increasing weekly study time above 5 hours could lift final exam readiness.');
    }
    if (input.failures > 0) {
      tips.add(
          'Prior failures (${input.failures}) increase risk; targeted practice or tutoring is recommended.');
    }
    return tips;
  }
}
