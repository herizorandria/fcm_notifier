class ProgressStats {
  final List<DailyProgress> dailyProgress;
  final List<WeeklyProgress> weeklyProgress;
  final List<MonthlyProgress> monthlyProgress;

  ProgressStats({
    required this.dailyProgress,
    required this.weeklyProgress,
    required this.monthlyProgress,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      dailyProgress: (json['daily_progress'] as List)
          .map((e) => DailyProgress.fromJson(e))
          .toList(),
      weeklyProgress: (json['weekly_progress'] as List)
          .map((e) => WeeklyProgress.fromJson(e))
          .toList(),
      monthlyProgress: (json['monthly_progress'] as List)
          .map((e) => MonthlyProgress.fromJson(e))
          .toList(),
    );
  }
}

class DailyProgress {
  final String date;
  final int completedQuizzes;
  final double averagePoints;

  DailyProgress({
    required this.date,
    required this.completedQuizzes,
    required this.averagePoints,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: json['date'],
      completedQuizzes: json['completed_quizzes'],
      averagePoints: (json['average_points'] is int)
          ? (json['average_points'] as int).toDouble()
          : json['average_points'],
    );
  }
}

class WeeklyProgress {
  final String week;
  final int completedQuizzes;
  final double averagePoints;

  WeeklyProgress({
    required this.week,
    required this.completedQuizzes,
    required this.averagePoints,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      week: json['week'],
      completedQuizzes: json['completed_quizzes'],
      averagePoints: (json['average_points'] is int)
          ? (json['average_points'] as int).toDouble()
          : json['average_points'],
    );
  }
}

class MonthlyProgress {
  final String month;
  final int completedQuizzes;
  final double averagePoints;

  MonthlyProgress({
    required this.month,
    required this.completedQuizzes,
    required this.averagePoints,
  });

  factory MonthlyProgress.fromJson(Map<String, dynamic> json) {
    return MonthlyProgress(
      month: json['month'],
      completedQuizzes: json['completed_quizzes'],
      averagePoints: (json['average_points'] is int)
          ? (json['average_points'] as int).toDouble()
          : json['average_points'],
    );
  }
}