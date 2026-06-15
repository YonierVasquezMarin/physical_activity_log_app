import 'package:physical_activity_log_app/models/report_summary.dart';

class ReportSummaryResponseDto {
  final Map<String, dynamic> period;
  final Map<String, dynamic> overview;
  final Map<String, dynamic> consistency;
  final Map<String, dynamic> categories;
  final Map<String, dynamic> activities;
  final Map<String, dynamic> goals;

  const ReportSummaryResponseDto({
    required this.period,
    required this.overview,
    required this.consistency,
    required this.categories,
    required this.activities,
    required this.goals,
  });

  factory ReportSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return ReportSummaryResponseDto(
      period: json['period'] as Map<String, dynamic>,
      overview: json['overview'] as Map<String, dynamic>,
      consistency: json['consistency'] as Map<String, dynamic>,
      categories: json['categories'] as Map<String, dynamic>,
      activities: json['activities'] as Map<String, dynamic>,
      goals: json['goals'] as Map<String, dynamic>,
    );
  }

  ReportSummary toModel() => ReportSummary(
        period: _parsePeriod(period),
        overview: _parseOverview(overview),
        consistency: _parseConsistency(consistency),
        categories: _parseCategories(categories),
        activities: _parseActivities(activities),
        goals: _parseGoals(goals),
      );

  static ReportPeriod _parsePeriod(Map<String, dynamic> json) {
    return ReportPeriod(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      timezone: json['timezone'] as String? ?? 'Z',
    );
  }

  static ReportOverview _parseOverview(Map<String, dynamic> json) {
    final categoryJson = json['mostFrequentCategory'];
    return ReportOverview(
      totalSessions: json['totalSessions'] as int,
      activeDays: json['activeDays'] as int,
      averageSessionsPerWeek:
          (json['averageSessionsPerWeek'] as num).toDouble(),
      mostFrequentCategory: categoryJson != null
          ? _parseCategoryStat(categoryJson as Map<String, dynamic>)
          : null,
    );
  }

  static ReportCategoryStat _parseCategoryStat(Map<String, dynamic> json) {
    return ReportCategoryStat(
      id: json['id'] as int,
      name: json['name'] as String,
      sessionCount: json['sessionCount'] as int,
    );
  }

  static ReportConsistency _parseConsistency(Map<String, dynamic> json) {
    final weeksJson = json['sessionsByWeek'] as List<dynamic>? ?? [];
    return ReportConsistency(
      currentStreakDays: json['currentStreakDays'] as int,
      longestStreakDays: json['longestStreakDays'] as int,
      sessionsByWeek: weeksJson
          .map(
            (item) => ReportWeekSessionCount(
              week: (item as Map<String, dynamic>)['week'] as String,
              count: item['count'] as int,
            ),
          )
          .toList(),
      inactiveDays: json['inactiveDays'] as int,
    );
  }

  static ReportCategories _parseCategories(Map<String, dynamic> json) {
    final breakdownJson = json['breakdown'] as List<dynamic>? ?? [];
    return ReportCategories(
      totalSessionsWithActivities:
          json['totalSessionsWithActivities'] as int,
      breakdown: breakdownJson
          .map(
            (item) => ReportCategoryBreakdown(
              categoryId: (item as Map<String, dynamic>)['categoryId'] as int,
              categoryName: item['categoryName'] as String,
              sessionCount: item['sessionCount'] as int,
              percentage: (item['percentage'] as num).toDouble(),
            ),
          )
          .toList(),
    );
  }

  static ReportActivities _parseActivities(Map<String, dynamic> json) {
    final topJson = json['top'] as List<dynamic>? ?? [];
    return ReportActivities(
      top: topJson
          .map(
            (item) => ReportTopActivity(
              activityId: (item as Map<String, dynamic>)['activityId'] as int,
              activityName: item['activityName'] as String,
              categoryName: item['categoryName'] as String,
              occurrences: item['occurrences'] as int,
            ),
          )
          .toList(),
      uniqueActivitiesCount: json['uniqueActivitiesCount'] as int,
    );
  }

  static ReportGoals _parseGoals(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return ReportGoals(
      activeCount: json['activeCount'] as int,
      expiredCount: json['expiredCount'] as int,
      withoutProgressCount: json['withoutProgressCount'] as int,
      items: itemsJson
          .map(
            (item) => ReportGoalItem(
              id: (item as Map<String, dynamic>)['id'] as int,
              title: item['title'] as String,
              status: item['status'] as String,
            ),
          )
          .toList(),
    );
  }
}
