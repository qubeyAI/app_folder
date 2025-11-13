import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

AudioPlayer? _alarmPlayer;

/// Alarm callback triggered even if app is closed.
/// Plays selected custom sound looping or shows notification fallback.
void alarmCallback() async {
  final prefs = await SharedPreferences.getInstance();
  final customPath = prefs.getString('custom_alarm_sound_path');

  if (customPath != null && customPath.isNotEmpty) {
    _alarmPlayer = AudioPlayer();
    await _alarmPlayer!.setReleaseMode(ReleaseMode.loop);
    await _alarmPlayer!.play(DeviceFileSource(customPath));
  } else {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final androidDetails = AndroidNotificationDetails(
      'alarm_notification_channel',
      'Alarm Notifications',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      fullScreenIntent: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '⏰ Alarm',
      'Time to wake up!',
      notificationDetails,
    );
  }
}

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  TimeOfDay? _selectedTime;
  String? _customSoundFilePath;
  bool _isAlarmSet = false;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeAlarmManager();
    _loadSavedAlarm();
  }

  Future<void> _initializeAlarmManager() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AndroidAlarmManager.initialize();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSavedAlarm() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('alarm_hour');
    final minute = prefs.getInt('alarm_minute');
    final isSet = prefs.getBool('alarm_set') ?? false;
    final customPath = prefs.getString('custom_alarm_sound_path');

    setState(() {
      _selectedTime = (hour != null && minute != null) ? TimeOfDay(hour: hour, minute: minute) : null;
      _isAlarmSet = isSet;
      _customSoundFilePath = customPath;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickCustomSound() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null && path.isNotEmpty) {
        setState(() => _customSoundFilePath = path);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('custom_alarm_sound_path', path);
      }
    }
  }

  Future<void> _previewSound() async {
    try {
      await _player.stop();
      if (_customSoundFilePath != null && _customSoundFilePath!.isNotEmpty) {
        await _player.play(DeviceFileSource(_customSoundFilePath!), volume: 1.0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No custom sound selected')));
      }
    } catch (e) {
      debugPrint('Error playing preview: $e');
    }
  }

  Future<void> _setAlarm() async {
    if (_selectedTime == null) return;

    final now = DateTime.now();
    var alarmDateTime = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
    if (alarmDateTime.isBefore(now)) alarmDateTime = alarmDateTime.add(const Duration(days: 1));
    final diff = alarmDateTime.difference(now);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('alarm_hour', _selectedTime!.hour);
    await prefs.setInt('alarm_minute', _selectedTime!.minute);
    await prefs.setBool('alarm_set', true);
    if (_customSoundFilePath != null && _customSoundFilePath!.isNotEmpty) {
      await prefs.setString('custom_alarm_sound_path', _customSoundFilePath!);
    }

    // Cancel old alarm first to avoid duplicates.
    await AndroidAlarmManager.cancel(0);

    // Schedule new alarm.
    await AndroidAlarmManager.oneShot(diff, 0, alarmCallback, exact: true, wakeup: true);

    setState(() => _isAlarmSet = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm set for ${DateFormat('hh:mm a').format(alarmDateTime)}')),
    );
  }

  Future<void> _cancelAlarm() async {
    await AndroidAlarmManager.cancel(0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_set', false);
    await prefs.remove('alarm_hour');
    await prefs.remove('alarm_minute');
    await prefs.remove('custom_alarm_sound_path');

    await _player.stop();

    setState(() {
      _isAlarmSet = false;
      _selectedTime = null;
      _customSoundFilePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alarm cancelled')));
  }

  @override
  void dispose() {
    _player.dispose();
    _alarmPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Alarm Clock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.alarm, color: Colors.white, size: 120),
              const SizedBox(height: 20),
              Text(
                _selectedTime == null ? 'No alarm set' : 'Selected: ${_selectedTime!.format(context)}',
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                onPressed: _pickCustomSound,
                icon: const Icon(Icons.music_note),
                label: Text(_customSoundFilePath == null ? 'Select Custom Sound' : 'Change Custom Sound'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                onPressed: _previewSound,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Preview Sound'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: _pickTime,
                child: const Text('Pick Alarm Time'),
              ),
              const SizedBox(height: 20),
              if (!_isAlarmSet)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: _setAlarm,
                  child: const Text('Set Alarm'),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: _cancelAlarm,
                  child: const Text('Cancel Alarm'),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}


