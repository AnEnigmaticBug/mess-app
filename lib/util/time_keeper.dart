import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeKeeper {
  const TimeKeeper({
    @required this.durations,
    @required SharedPreferences preferences,
  }) : this._sPrefs = preferences;

  final Map<String, Duration> durations;
  final SharedPreferences _sPrefs;

  Future<bool> isDue(String item) async {
    if (!_sPrefs.containsKey('TIME_TRACKER_$item')) {
      return true;
    }
    try {
      final lastUpdated =
          DateTime.parse(_sPrefs.getString('TIME_TRACKER_$item'));
      return DateTime.now().isAfter(lastUpdated.add(durations[item]));
    } catch (e) {
      return true;
    }
  }

  Future<void> reset(String item) async {
    await _sPrefs.setString(
        'TIME_TRACKER_$item', DateTime.now().toIso8601String());
  }
}
