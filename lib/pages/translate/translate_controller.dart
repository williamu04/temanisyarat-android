import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/history_service.dart';

class TranslateController extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();

  MethodChannel? _channel;

  bool hasPermission = false;
  bool modelLoaded = false;
  bool modelError = false;
  bool bufferReady = false;
  bool inferencePulse = false;
  bool hasLandmarks = true;
  int bufferCount = 0;
  int writeOffset = 0;
  int totalFrames = 0;
  String? currentPrediction;
  final List<String> history = [];

  bool _disposed = false;

  Future<void> init() async {
    final status = await Permission.camera.request();
    hasPermission = status.isGranted;
    notifyListeners();

    await _historyService.init();
    final existing = await _historyService.loadExisting();
    history.addAll(existing);
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    hasPermission = status.isGranted;
    notifyListeners();
  }

  void onPlatformViewCreated(int id) {
    _channel = MethodChannel('temanisyarat/hand_landmarker_$id');
    _channel?.setMethodCallHandler(_handleMethodCall);
    _startCamera();
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onLandmarks':
        _handleLandmarks(call.arguments as Map);
        break;
      case 'onModelReady':
        final args = call.arguments as Map;
        modelLoaded = args['loaded'] as bool? ?? false;
        modelError = !modelLoaded;
        notifyListeners();
        break;
      case 'onError':
        final args = call.arguments as Map;
        debugPrint('Landmarker error: ${args['message']}');
        break;
    }
  }

  void _handleLandmarks(Map args) {
    final newHasLandmarks = args['hasLandmarks'] as bool? ?? true;
    if (!newHasLandmarks) {
      hasLandmarks = false;
      currentPrediction = null;
      notifyListeners();
      return;
    }

    final prediction = args['prediction'] as String?;
    final newBufferCount = args['bufferCount'] as int? ?? 0;
    final newBufferReady = args['bufferReady'] as bool? ?? false;
    final modelLoadedArg = args['modelLoaded'] as bool?;
    final newWriteOffset = args['writeOffset'] as int? ?? 0;
    final newTotalFrames = args['totalFrames'] as int? ?? 0;

    if (!hasLandmarks) hasLandmarks = true;
    bufferCount = newBufferCount;
    bufferReady = newBufferReady;
    writeOffset = newWriteOffset;
    totalFrames = newTotalFrames;
    if (modelLoadedArg != null) modelLoaded = modelLoadedArg;
    notifyListeners();

    if (prediction != null && prediction != currentPrediction) {
      currentPrediction = prediction;
      history.add(prediction);
      if (history.length > 10) history.removeAt(0);
      unawaited(_historyService.append(prediction));
    }

    inferencePulse = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_disposed) {
        inferencePulse = false;
        notifyListeners();
      }
    });
  }

  void _startCamera() {
    if (!hasPermission) return;
    try {
      _channel?.invokeMethod('startCamera');
    } catch (e) {
      debugPrint('Failed to start camera: $e');
    }
  }

  void switchCamera() {
    try {
      _channel?.invokeMethod('switchCamera');
    } catch (e) {
      debugPrint('Failed to switch camera: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    try {
      _channel?.invokeMethod('stopCamera');
    } catch (_) {}
    super.dispose();
  }
}
