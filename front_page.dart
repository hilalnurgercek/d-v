import 'package:flutter/material.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
//import 'dart:io';
import 'cam_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Technician App',
      theme: ThemeData(

        // This is the theme of your application.

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink.shade300),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade300,
            minimumSize: const Size(double.infinity, 60),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Enter Device Code'),
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
  final TextEditingController _deviceCodeController = TextEditingController() ;

  void _navigateToReports() {
    final code = _deviceCodeController.text.trim();
    if (code.isNotEmpty) {
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context) =>ReportListScreen(deviceCode : code)
          )
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.pink.shade300,

        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _deviceCodeController,
              decoration: const InputDecoration(
                labelText: 'Device Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateToReports,
              icon: const Icon(Icons.search),
              label :const Text('View Reports'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewReportScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Report'),
            ),

          ],
        ),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ReportListScreen extends StatelessWidget {
  final String deviceCode;

  const ReportListScreen({super.key, required this.deviceCode});

  final List<Map<String, String>> sampleReports = const [
    {
      'date': '2025-05-20',
      'issue': 'Broken display',
      'technician': 'John Doe',
    },
    {
      'date': '2025-04-18',
      'issue': 'Battery not charging',
      'technician': 'Jane Smith',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports for: $deviceCode'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView.builder(
        itemCount: sampleReports.length,
        itemBuilder: (context, index) {
          final report = sampleReports[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.report),
              title: Text(report['issue'] ?? ''),
              subtitle: Text(
                'Date: ${report['date']}\nTechnician: ${report['technician']}',
              ),
              isThreeLine: true,
              onTap: () {
                // Later: navigate to detailed report screen
              },
            ),
          );
        },
      ),
    );
  }
}

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Report'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Photo picker
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraPage()),
                );
                runApp(CameraApp());
              }, //---------------------------------------------------------------------------
              //child: Text('Open Camera'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photo'),
            ),
            const SizedBox(height: 16),

            // Notes input
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Save report button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: implement save logic
                final notes = _notesController.text.trim();
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Report'),
            ),
          ],
        ),
      ),
    );
  }
}
