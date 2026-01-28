import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A stroke represents a single continuous drawing path
class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawingStroke({
    required this.points,
    required this.color,
    this.strokeWidth = 8.0,
  });

  DrawingStroke copyWith({List<Offset>? points}) {
    return DrawingStroke(
      points: points ?? this.points,
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

/// Custom drawing canvas widget that provides smooth stroke rendering
class DrawingCanvas extends StatefulWidget {
  final Color strokeColor;
  final double strokeWidth;
  final Color backgroundColor;
  final VoidCallback? onDrawingChanged;
  final GlobalKey? repaintKey;

  const DrawingCanvas({
    super.key,
    this.strokeColor = Colors.black,
    this.strokeWidth = 8.0,
    this.backgroundColor = Colors.white,
    this.onDrawingChanged,
    this.repaintKey,
  });

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingStroke> _strokes = [];
  DrawingStroke? _currentStroke;
  final GlobalKey _canvasKey = GlobalKey();

  int _version = 0;

  /// Clear all strokes from the canvas
  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
      _version++;
    });
    widget.onDrawingChanged?.call();
  }

  /// Check if canvas has any drawing
  bool get hasDrawing => _strokes.isNotEmpty;

  /// Get the number of strokes
  int get strokeCount => _strokes.length;

  /// Get the raw strokes for ML processing
  List<DrawingStroke> get strokes => List.unmodifiable(_strokes);

  /// Export the canvas to image bytes (PNG format)
  Future<Uint8List?> exportToImage() async {
    try {
      final key = widget.repaintKey ?? _canvasKey;
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error exporting canvas: $e');
      return null;
    }
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    setState(() {
      _currentStroke = DrawingStroke(
        points: [localPosition],
        color: widget.strokeColor,
        strokeWidth: widget.strokeWidth,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentStroke == null) return;
    
    final localPosition = details.localPosition;
    setState(() {
      _currentStroke = _currentStroke!.copyWith(
        points: [..._currentStroke!.points, localPosition],
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke != null && _currentStroke!.points.length > 1) {
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
      });
      widget.onDrawingChanged?.call();
    } else {
      setState(() {
        _currentStroke = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.repaintKey ?? _canvasKey,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomPaint(
              painter: _DrawingPainter(
                strokes: List.from(_strokes),
                currentStroke: _currentStroke,
                backgroundColor: widget.backgroundColor,
                version: _version,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for rendering smooth strokes
class _DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;
  final Color backgroundColor;
  final int version;

  _DrawingPainter({
    required this.strokes,
    this.currentStroke,
    required this.backgroundColor,
    required this.version,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw all completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Draw current stroke being drawn
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Use path for smooth curves
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    // Use quadratic bezier for smoother lines
    for (int i = 1; i < stroke.points.length - 1; i++) {
      final p0 = stroke.points[i];
      final p1 = stroke.points[i + 1];
      final midPoint = Offset(
        (p0.dx + p1.dx) / 2,
        (p0.dy + p1.dy) / 2,
      );
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    // Draw to the last point
    if (stroke.points.length > 1) {
      final last = stroke.points.last;
      path.lineTo(last.dx, last.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return strokes.length != oldDelegate.strokes.length ||
        currentStroke != oldDelegate.currentStroke ||
        version != oldDelegate.version;
  }
}
