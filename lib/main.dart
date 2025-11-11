import 'package:flutter/material.dart';
import 'package:network_project/networkiing_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSONPlaceholder Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Post #1'),
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
  bool _loading = false;
  String _title = '';
  String _body = '';
  String _error = '';

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final post = await NetworkiingService.getonepost('1');
      setState(() {
        _title = post['title']?.toString() ?? '';
        _body = post['body']?.toString() ?? '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : _error.isNotEmpty
                  ? Text(_error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center)
                  : _title.isEmpty
                      ? const Text('Tap the button to load post #1')
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(_title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge),
                              const SizedBox(height: 12),
                              Text(_body,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium),
                            ],
                          ),
                        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetch,
        tooltip: 'Fetch Post',
        child: const Icon(Icons.api),
      ),
    );
  }
}