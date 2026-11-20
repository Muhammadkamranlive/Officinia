// import 'dart:io';
// import 'package:logger/logger.dart';
// import 'package:path_provider/path_provider.dart';

// class FileLogger {
//   static final Logger _logger = Logger(
//     printer: PrettyPrinter(),
//     output: _FileOutput(),
//   );

//   static void log(String message) {
//     _logger.i(message);
//   }

//   static void error(String message) {
//     _logger.e(message);
//   }

//   static void debug(String message) {
//     _logger.d(message);
//   }

//   static void warning(String message) {
//     _logger.w(message);
//   }

//   static void verbose(String message) {
//     _logger.v(message);
//   }
// }

// class _FileOutput extends LogOutput {
//   late IOSink _sink;

//   _FileOutput() {
//     _init();
//   }

//   Future<void> _init() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final logDirectory = Directory('${directory.path}/logs');
//     printLogFilePath();
//     if (!(await logDirectory.exists())) {
//       await logDirectory.create(recursive: true);
//     }
//     final file = File('${logDirectory.path}/app_logs.txt');
//     _sink = file.openWrite(mode: FileMode.writeOnlyAppend);
//   }

//   @override
//   void output(OutputEvent event) {
//     for (var line in event.lines) {
//       _sink.write('${DateTime.now()}: $line\n');
//     }
//   }

//   @override
//   Future<void> destroy() async {
//     await _sink.flush();
//     await _sink.close();
//   }
// }

// Future<String> getLogFilePath() async {
//   final directory = await getApplicationDocumentsDirectory();
//   final logDirectory = Directory('${directory.path}/logs');
//   return '${logDirectory.path}/app_logs.txt';
// }

// void printLogFilePath() async {
//   String logFilePath = await getLogFilePath();
//   print("Log file path: $logFilePath");
// }
