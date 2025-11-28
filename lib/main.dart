import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const ClockApp());
}

class ClockApp extends StatelessWidget {
  const ClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Clock Master',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clock Master'),
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.alarm), text: 'Alarm'),
              Tab(icon: Icon(Icons.timer), text: 'Stopwatch'),
              Tab(icon: Icon(Icons.hourglass_bottom), text: 'Timer'),
            ],
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: const TabBarView(
          children: [
            AlarmTab(),
            StopwatchTab(),
            TimerTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. ALARM TAB
// ---------------------------------------------------------------------------
class AlarmTab extends StatefulWidget {
  const AlarmTab({super.key});

  @override
  State<AlarmTab> createState() => _AlarmTabState();
}

class _AlarmTabState extends State<AlarmTab> {
  // List to store alarms
  List<TimeOfDay> _alarms = [];

  // Function to add an alarm
  Future<void> _addAlarm() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _alarms.add(selectedTime);
        _alarms.sort((a, b) => a.hour.compareTo(b.hour)); // Simple sort
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarm set for ${selectedTime.format(context)}')),
      );
    }
  }

  void _deleteAlarm(int index) {
    setState(() {
      _alarms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _alarms.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.alarm_off, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text("No Alarms Set", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          final alarm = _alarms[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1E1E1E),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                alarm.format(context),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteAlarm(index),
              ),
              leading: Switch(
                value: true,
                onChanged: (val) {}, // Mock switch for visual
                activeColor: Colors.blueAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. STOPWATCH TAB
// ---------------------------------------------------------------------------
class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  // Updates the UI every 30 milliseconds to show moving numbers
  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  void _handleStartStop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer.cancel();
    } else {
      _stopwatch.start();
      _startTimer();
    }
    setState(() {});
  }

  void _reset() {
    _stopwatch.reset();
    if (_timer.isActive) _timer.cancel(); // Stop UI updates if reset
    setState(() {});
  }

  String _formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var hours = (secs ~/ 3600).toString().padLeft(2, '0');
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');
    var millis = (milliseconds % 1000) ~/ 10; // First 2 digits of millis

    return "$hours:$minutes:$seconds.${millis.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display Time
        Text(
          _formatTime(_stopwatch.elapsedMilliseconds),
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w300,
            fontFeatures: [FontFeature.tabularFigures()], // Keeps numbers width fixed
          ),
        ),
        const SizedBox(height: 50),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
                backgroundColor: const Color(0xFF333333),
              ),
              onPressed: _reset,
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(36),
                backgroundColor: _stopwatch.isRunning ? Colors.redAccent : Colors.greenAccent,
              ),
              onPressed: _handleStartStop,
              child: Icon(
                _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 3. TIMER TAB
// ---------------------------------------------------------------------------
class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  static const int _defaultTime = 60; // default 1 minute
  int _remainingSeconds = _defaultTime;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;

  void _startTimer() {
    if (_remainingSeconds > 0) {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            _isFinished = true;
            _showFinishedDialog();
          }
        });
      });
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _defaultTime;
      _isRunning = false;
      _isFinished = false;
    });
  }

  void _addTime(int seconds) {
    setState(() {
      _remainingSeconds += seconds;
    });
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Time's Up!"),
        content: const Text("Your timer has finished."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // Helper to format 90 seconds to "01:30"
  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isRunning && !_isFinished)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeButton(label: "+1 Min", onPressed: () => _addTime(60)),
                const SizedBox(width: 10),
                _TimeButton(label: "+5 Min", onPressed: () => _addTime(300)),
                const SizedBox(width: 10),
                _TimeButton(label: "+10 Sec", onPressed: () => _addTime(10)),
              ],
            ),
          ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: 1 - (_remainingSeconds / (_remainingSeconds + 10)), // Mock progress
                strokeWidth: 10,
                backgroundColor: const Color(0xFF333333),
                color: _isFinished ? Colors.red : Colors.blueAccent,
              ),
            ),
            Text(
              _formatDuration(_remainingSeconds),
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: _isFinished ? Colors.red : Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _resetTimer,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
                backgroundColor: const Color(0xFF333333),
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _isRunning ? _pauseTimer : _startTimer,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(36),
                backgroundColor: _isRunning ? Colors.orange : Colors.blueAccent,
              ),
              child: Icon(
                _isRunning ? Icons.pause : Icons.play_arrow,
                size: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _TimeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}