import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Future<void> _updatePreference() async {
  int totalExecutions = 0;
  final sharedPreference = await SharedPreferences.getInstance();

  try {
    totalExecutions = sharedPreference.getInt('count_test') ?? 0;

    print(totalExecutions);
    await sharedPreference.setInt(
      'count_test',
      totalExecutions + 1,
    );
  } catch (err) {
    print(err);
  }
}

// @pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    switch (task) {
      case 'delayed_task':
        print("this method was delayed!");

        _updatePreference();

        break;

      case 'periodic_task':
        print("this method was periodic!");
        break;

      case Workmanager.iOSBackgroundTask:
        print("iOS background fetch delegate ran");
        break;

      default:
        {
          throw Exception('The task is not being processed');
        }
    }

    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _registerOneDelayedTask() {
    Workmanager().registerOneOffTask(
      "1",
      "delayed_task",
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        // requiresBatteryNotLow: true,
        // requiresCharging: true,
        // requiresDeviceIdle: true,
        // requiresStorageNotLow: true
      ),
      inputData: {
        'test_int': 123,
        'test_string': 'qwe',
      },
    );
  }

  void _registerPeriodicFrequencyTask() {
    Workmanager().registerPeriodicTask(
      "2",
      "periodic_task",
      initialDelay: const Duration(seconds: 5),
      inputData: {
        'test_int': 456,
        'test_string': 'asd',
      },
    );
  }

  void _onTap() {
    _registerOneDelayedTask();
    // _registerPeriodicFrequencyTask();
    _incrementCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTap,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
