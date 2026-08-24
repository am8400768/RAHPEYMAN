// profile_shape_painter.dart
import 'package:flutter/material.dart';

class ProfileShapeCard extends StatelessWidget {
  final String type;
  final Map<String, dynamic> item;
  final Color accent;

  const ProfileShapeCard(
      {super.key,
      required this.type,
      required this.item,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0x73050B12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x159AC2E0)),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: ProfileShapePainter(type: type, item: item, accent: accent),
        ),
      ),
    );
  }
}

class ProfileShapePainter extends CustomPainter {
  final String type;
  final Map<String, dynamic> item;
  final Color accent;

  static const double vb = 236;
  static const double pad = 54;
  static const double area = vb - pad * 2;

  ProfileShapePainter(
      {required this.type, required this.item, required this.accent});

  double _n(String key) => (item[key] as num).toDouble();

  String _fmtDim(num n) {
    final v = n.toDouble();
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    String s = (v * 100).round().toDouble().toString(); // ساده‌سازی برای نمایش
    return v.toStringAsFixed(1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / vb;
    canvas.save();
    canvas.scale(scale, scale);

    final fillPaint = Paint()
      ..color = const Color(0x1A9AC2E0)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF84A2B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    switch (type) {
      case 'IPE':
      case 'IPB':
      case 'INP':
        _drawIBeam(canvas, fillPaint, strokePaint);
        break;
      case 'UNP':
        _drawChannel(canvas, fillPaint, strokePaint);
        break;
      case 'L':
        _drawAngle(canvas, fillPaint, strokePaint);
        break;
      case 'T':
        _drawTee(canvas, fillPaint, strokePaint);
        break;
      case 'REBAR':
        _drawRebar(canvas, fillPaint, strokePaint);
        break;
      case 'BOX':
        _drawBox(canvas, fillPaint, strokePaint);
        break;
    }
    canvas.restore();
  }

  void _label(Canvas canvas, Offset center, String text) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: accent,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: center, width: tp.width + 8, height: tp.height + 3),
            const Radius.circular(3)),
        Paint()..color = const Color(0xFF0A1826));
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _dimH(Canvas canvas, double x1, double x2, double y, String label,
      {bool below = true}) {
    final p = Paint()
      ..color = accent
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x1, y - 4), Offset(x1, y + 4), p);
    canvas.drawLine(Offset(x2, y - 4), Offset(x2, y + 4), p);
    canvas.drawLine(Offset(x1, y), Offset(x2, y), p);
    _label(canvas, Offset((x1 + x2) / 2, below ? y + 13 : y - 9), label);
  }

  void _dimV(Canvas canvas, double y1, double y2, double x, String label) {
    final p = Paint()
      ..color = accent
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x - 4, y1), Offset(x + 4, y1), p);
    canvas.drawLine(Offset(x - 4, y2), Offset(x + 4, y2), p);
    canvas.drawLine(Offset(x, y1), Offset(x, y2), p);
    _label(canvas, Offset(x.clamp(28.0, vb - 28.0), y2 + 14), label);
  }

  void _leader(Canvas canvas, Offset from, Offset to, String label) {
    canvas.drawLine(
        from,
        to,
        Paint()
          ..color = const Color(0x269AC2E0)
          ..strokeWidth = 1);
    canvas.drawCircle(from, 1.6, Paint()..color = accent);
    _label(canvas, to, label);
  }

  void _drawIBeam(Canvas canvas, Paint fill, Paint stroke) {
    final h = _n('h'), b = _n('b'), t = _n('t'), tg = _n('tg');
    final scale = (area / b < area / h) ? area / b : area / h;
    final bw = b * scale,
        bh = h * scale,
        tw = (t * scale).clamp(2.4, 100.0),
        tf = (tg * scale).clamp(2.6, 100.0);
    final ox = (vb - bw) / 2, oy = (vb - bh) / 2, midX = ox + bw / 2;
    final path = Path()
      ..moveTo(ox, oy)
      ..lineTo(ox + bw, oy)
      ..lineTo(ox + bw, oy + tf)
      ..lineTo(midX + tw / 2, oy + tf)
      ..lineTo(midX + tw / 2, oy + bh - tf)
      ..lineTo(ox + bw, oy + bh - tf)
      ..lineTo(ox + bw, oy + bh)
      ..lineTo(ox, oy + bh)
      ..lineTo(ox, oy + bh - tf)
      ..lineTo(midX - tw / 2, oy + bh - tf)
      ..lineTo(midX - tw / 2, oy + tf)
      ..lineTo(ox, oy + tf)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    _dimV(canvas, oy, oy + bh, ox + bw + 22, '${_fmtDim(h)} mm');
    _dimH(canvas, ox, ox + bw, oy + bh + 18, '${_fmtDim(b)} mm');
    _leader(canvas, Offset(midX + tw / 2, oy + bh / 2),
        Offset(midX + 26, oy + bh * 0.32), 's=${_fmtDim(t)}');
    _leader(canvas, Offset(ox + bw * 0.78, oy + tf / 2),
        Offset(ox + bw + 6, oy - 10), 'tg=${_fmtDim(tg)}');
  }

  void _drawChannel(Canvas canvas, Paint fill, Paint stroke) {
    final h = _n('h'), b = _n('b'), t = _n('t'), tg = _n('tg');
    final scale = (area / b < area / h) ? area / b : area / h;
    final bw = b * scale,
        bh = h * scale,
        tw = (t * scale).clamp(2.4, 100.0),
        tf = (tg * scale).clamp(2.6, 100.0);
    final ox = (vb - bw) / 2, oy = (vb - bh) / 2;
    final path = Path()
      ..moveTo(ox, oy)
      ..lineTo(ox + bw, oy)
      ..lineTo(ox + bw, oy + tf)
      ..lineTo(ox + tw, oy + tf)
      ..lineTo(ox + tw, oy + bh - tf)
      ..lineTo(ox + bw, oy + bh - tf)
      ..lineTo(ox + bw, oy + bh)
      ..lineTo(ox, oy + bh)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    _dimV(canvas, oy, oy + bh, ox + bw + 22, '${_fmtDim(h)} mm');
    _dimH(canvas, ox, ox + bw, oy + bh + 18, '${_fmtDim(b)} mm');
    _leader(canvas, Offset(ox + tw / 2, oy + bh / 2),
        Offset(ox + tw + 22, oy + bh * 0.5 - 16), 's=${_fmtDim(t)}');
  }

  void _drawAngle(Canvas canvas, Paint fill, Paint stroke) {
    final a = _n('a'), t = _n('t');
    final scale = area / a,
        A = a * scale,
        T = (t * scale).clamp(2.6, 100.0),
        ox = (vb - A) / 2,
        oy = (vb - A) / 2;
    final path = Path()
      ..moveTo(ox, oy)
      ..lineTo(ox + T, oy)
      ..lineTo(ox + T, oy + A - T)
      ..lineTo(ox + A, oy + A - T)
      ..lineTo(ox + A, oy + A)
      ..lineTo(ox, oy + A)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    _dimV(canvas, oy, oy + A, ox + A + 22, '${_fmtDim(a)} mm');
    _dimH(canvas, ox, ox + A, oy + A + 18, '${_fmtDim(a)} mm');
    _leader(canvas, Offset(ox + T / 2, oy + A * 0.32),
        Offset(ox + T + 24, oy + A * 0.32 - 16), 't=${_fmtDim(t)}');
  }

  void _drawTee(Canvas canvas, Paint fill, Paint stroke) {
    final a = _n('a'), t = _n('t');
    final scale = area / a,
        A = a * scale,
        T = (t * scale).clamp(2.6, 100.0),
        ox = (vb - A) / 2,
        oy = (vb - A) / 2,
        midX = ox + A / 2;
    final path = Path()
      ..moveTo(ox, oy)
      ..lineTo(ox + A, oy)
      ..lineTo(ox + A, oy + T)
      ..lineTo(midX + T / 2, oy + T)
      ..lineTo(midX + T / 2, oy + A)
      ..lineTo(midX - T / 2, oy + A)
      ..lineTo(midX - T / 2, oy + T)
      ..lineTo(ox, oy + T)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    _dimH(canvas, ox, ox + A, oy - 14, '${_fmtDim(a)} mm', below: false);
    _dimV(canvas, oy, oy + A, ox + A + 22, '${_fmtDim(a)} mm');
  }

  void _drawRebar(Canvas canvas, Paint fill, Paint stroke) {
    final d = _n('d'),
        scale = area / d,
        r = (d * scale) / 2,
        c = const Offset(vb / 2, vb / 2);
    canvas.drawCircle(c, r, fill);
    canvas.drawCircle(c, r, stroke);
    canvas.drawLine(
        Offset(c.dx - r - 8, c.dy),
        Offset(c.dx + r + 8, c.dy),
        Paint()
          ..color = const Color(0xFF374A5C)
          ..strokeWidth = 0.6);
    canvas.drawLine(
        Offset(c.dx, c.dy - r - 8),
        Offset(c.dx, c.dy + r + 8),
        Paint()
          ..color = const Color(0xFF374A5C)
          ..strokeWidth = 0.6);
    _dimH(canvas, c.dx - r, c.dx + r, c.dy + r + 18, 'Ø${_fmtDim(d)} mm');
  }

  void _drawBox(Canvas canvas, Paint fill, Paint stroke) {
    final h = _n('h'), b = _n('b'), s = _n('s');
    final scale = (area / b < area / h) ? area / b : area / h;
    final bw = b * scale,
        bh = h * scale,
        wt = (s * scale).clamp(2.4, 100.0),
        ox = (vb - bw) / 2,
        oy = (vb - bh) / 2;
    final outer = Path()..addRect(Rect.fromLTWH(ox, oy, bw, bh));
    final inner = Path()
      ..addRect(Rect.fromLTWH(ox + wt, oy + wt, bw - wt * 2, bh - wt * 2));
    canvas.drawPath(Path.combine(PathOperation.difference, outer, inner), fill);
    canvas.drawPath(outer, stroke);
    canvas.drawPath(inner, stroke);
    _dimV(canvas, oy, oy + bh, ox + bw + 22, '${_fmtDim(h)} mm');
    _dimH(canvas, ox, ox + bw, oy + bh + 18, '${_fmtDim(b)} mm');
  }

  @override
  bool shouldRepaint(covariant ProfileShapePainter old) =>
      old.type != type || old.item != item;
}
