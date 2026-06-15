class ReportSummary {
  final ReportPeriod period;
  final ReportOverview overview;
  final ReportConsistency consistency;
  final ReportCategories categories;
  final ReportActivities activities;
  final ReportGoals goals;

  const ReportSummary({
    required this.period,
    required this.overview,
    required this.consistency,
    required this.categories,
    required this.activities,
    required this.goals,
  });
}

class ReportPeriod {
  final DateTime from;
  final DateTime to;
  final String timezone;

  const ReportPeriod({
    required this.from,
    required this.to,
    required this.timezone,
  });
}

class ReportOverview {
  final int totalSessions;
  final int activeDays;
  final double averageSessionsPerWeek;
  final ReportCategoryStat? mostFrequentCategory;

  const ReportOverview({
    required this.totalSessions,
    required this.activeDays,
    required this.averageSessionsPerWeek,
    this.mostFrequentCategory,
  });
}

class ReportCategoryStat {
  final int id;
  final String name;
  final int sessionCount;

  const ReportCategoryStat({
    required this.id,
    required this.name,
    required this.sessionCount,
  });
}

class ReportConsistency {
  final int currentStreakDays;
  final int longestStreakDays;
  final List<ReportWeekSessionCount> sessionsByWeek;
  final int inactiveDays;

  const ReportConsistency({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.sessionsByWeek,
    required this.inactiveDays,
  });
}

class ReportWeekSessionCount {
  final String week;
  final int count;

  const ReportWeekSessionCount({
    required this.week,
    required this.count,
  });
}

class ReportCategories {
  final int totalSessionsWithActivities;
  final List<ReportCategoryBreakdown> breakdown;

  const ReportCategories({
    required this.totalSessionsWithActivities,
    required this.breakdown,
  });
}

class ReportCategoryBreakdown {
  final int categoryId;
  final String categoryName;
  final int sessionCount;
  final double percentage;

  const ReportCategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.sessionCount,
    required this.percentage,
  });
}

class ReportActivities {
  final List<ReportTopActivity> top;
  final int uniqueActivitiesCount;

  const ReportActivities({
    required this.top,
    required this.uniqueActivitiesCount,
  });
}

class ReportTopActivity {
  final int activityId;
  final String activityName;
  final String categoryName;
  final int occurrences;

  const ReportTopActivity({
    required this.activityId,
    required this.activityName,
    required this.categoryName,
    required this.occurrences,
  });
}

class ReportGoals {
  final int activeCount;
  final int expiredCount;
  final int withoutProgressCount;
  final List<ReportGoalItem> items;

  const ReportGoals({
    required this.activeCount,
    required this.expiredCount,
    required this.withoutProgressCount,
    required this.items,
  });
}

class ReportGoalItem {
  final int id;
  final String title;
  final String status;

  const ReportGoalItem({
    required this.id,
    required this.title,
    required this.status,
  });
}
