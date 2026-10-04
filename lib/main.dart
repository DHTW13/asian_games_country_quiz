import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/countries.dart';
import 'models/country.dart';

void main() => runApp(const AsianGamesQuizApp());

class AsianGamesQuizApp extends StatelessWidget {
  const AsianGamesQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asian Games Country Quiz · 亞洲運動會國家測驗',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157D5)),
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 36, 30, 34),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3157D5), Color(0xFF6C83E8)],
                          ),
                        ),
                        child: const Icon(Icons.public, color: Colors.white, size: 52),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        '亞洲運動會國家測驗\nAsian Games Country Quiz',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.2),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '2026 愛知・名古屋 · 45 個參賽 NOC\n2026 Aichi-Nagoya · 45 participating NOCs',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Color(0xFF5F6B7A), height: 1.5),
                      ),
                      const SizedBox(height: 26),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: const [
                          FeatureChip(icon: Icons.map_outlined, text: '可點擊地圖 · Interactive Map'),
                          FeatureChip(icon: Icons.shape_line, text: '國家輪廓 · Outlines'),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage()));
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text('開始測驗 · Start Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const FeatureChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(text));
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final List<Country> questions;
  final Map<String, GeometryData> shapes = {};
  int index = 0;
  int score = 0;
  String? selected;
  bool answered = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final cn = countries.firstWhere((c) => c.code == 'cn');
    final tw = countries.firstWhere((c) => c.code == 'tw');
    final others = countries.where((c) => c.code != 'cn' && c.code != 'tw').toList()..shuffle();
    final groups = <List<Country>>[for (final c in others) [c], [tw, cn]]..shuffle();
    questions = groups.expand((g) => g).toList();
    loadShapes();
  }

  Future<void> loadShapes() async {
    final raw = await rootBundle.loadString('assets/geo/asian_games_45.geojson');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    for (final feature in (json['features'] as List)) {
      final f = feature as Map<String, dynamic>;
      final props = f['properties'] as Map<String, dynamic>;
      shapes[props['code'] as String] = GeometryData.fromGeoJson(f['geometry'] as Map<String, dynamic>);
    }
    if (mounted) setState(() => loading = false);
  }

  void choose(String code) {
    if (answered || !shapes.containsKey(code)) return;
    setState(() {
      selected = code;
      answered = true;
      if (code == questions[index].code) score++;
    });
  }

  void next() {
    if (index == questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultPage(score: score, total: questions.length)),
      );
      return;
    }
    setState(() {
      index++;
      selected = null;
      answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[index];
    return Scaffold(
      appBar: AppBar(
        title: const Text('亞洲運動會國家測驗 · Asian Games Country Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      QuizHeader(index: index, total: questions.length, score: score),
                      const SizedBox(height: 14),
                      wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      QuestionCard(country: q),
                                      const SizedBox(height: 10),
                                      if (answered) AnswerBanner(selected: selected, correct: q),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: FilledButton.icon(
                                          onPressed: answered ? next : null,
                                          icon: Icon(index == questions.length - 1 ? Icons.flag_rounded : Icons.arrow_forward_rounded),
                                          label: Text(index == questions.length - 1 ? '完成 · Finish' : '下一題 · Next'),
                                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(flex: 6, child: MapPanel(shapes: shapes, selected: selected, correct: answered ? q.code : null, onTap: choose, loading: loading)),
                              ],
                            )
                          : Column(
                              children: [
                                QuestionCard(country: q),
                                const SizedBox(height: 10),
                                MapPanel(shapes: shapes, selected: selected, correct: answered ? q.code : null, onTap: choose, loading: loading),
                                if (answered) ...[
                                  const SizedBox(height: 8),
                                  Align(alignment: Alignment.centerLeft, child: AnswerBanner(selected: selected, correct: q)),
                                  const SizedBox(height: 8),
                                  Align(alignment: Alignment.centerLeft, child: FilledButton.icon(
                                    onPressed: next,
                                    icon: Icon(index == questions.length - 1 ? Icons.flag_rounded : Icons.arrow_forward_rounded),
                                    label: Text(index == questions.length - 1 ? '完成 · Finish' : '下一題 · Next'),
                                  )),
                                ],
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class QuizHeader extends StatelessWidget {
  final int index, total, score;
  const QuizHeader({super.key, required this.index, required this.total, required this.score});

  @override
  Widget build(BuildContext context) {
    final progress = (index + 1) / total;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                Text('第 ${index + 1} / $total 題 · Question ${index + 1} / $total', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('得分 $score · Score $score', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3157D5))),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 9)),
          ],
        ),
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final Country country;
  const QuestionCard({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: const Color(0x223157D5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '代表隊名稱 · NOC NAME',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .5, color: Color(0xFF3157D5)),
              ),
            ),
            const SizedBox(height: 12),
            const SelectableText(
              '請找出這個代表隊所在的國家或地區',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            const SelectableText(
              'Find this NOC on the Asia map',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF687386)),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF8FAFF), Color(0xFFEFF4FF)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFDDE5F7)),
              ),
              child: Column(
                children: [
                  SelectableText(country.nameEn,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Color(0xFF263B70), height: 1.15)),
                  const SizedBox(height: 9),
                  SelectableText(country.nameZh,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF344054))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '請在右側地圖點擊位置',
              style: TextStyle(fontSize: 13, color: Color(0xFF667085), fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class MapPanel extends StatelessWidget {
  final Map<String, GeometryData> shapes;
  final String? selected, correct;
  final void Function(String) onTap;
  final bool loading;

  const MapPanel({super.key, required this.shapes, required this.selected, required this.correct, required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.touch_app_rounded, color: Color(0xFF3157D5), size: 20),
                SizedBox(width: 7),
                Expanded(child: Text('點擊亞洲地圖作答 · Tap the Asia map', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 380,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : InteractiveCountryMap(shapes: shapes, selected: selected, correct: correct, onTap: onTap),
            ),
            const SizedBox(height: 5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendDot(color: Color(0xFFFFFFFF), border: Color(0xFF98A2B3), text: '未選擇'),
                SizedBox(width: 12),
                LegendDot(color: Color(0xFFFFD6D6), border: Color(0xFFE05252), text: '你的答案'),
                SizedBox(width: 12),
                LegendDot(color: Color(0xFFC8F7D5), border: Color(0xFF36A269), text: '正確'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color, border;
  final String text;
  const LegendDot({super.key, required this.color, required this.border, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: border))), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF667085)))]);
  }
}

class AnswerBanner extends StatelessWidget {
  final String? selected;
  final Country correct;
  const AnswerBanner({super.key, required this.selected, required this.correct});

  @override
  Widget build(BuildContext context) {
    final isCorrect = selected == correct.code;
    return Card(
      color: isCorrect ? const Color(0xFFEAF9EF) : const Color(0xFFFFF0F0),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(isCorrect ? Icons.check_circle_rounded : Icons.info_rounded, color: isCorrect ? const Color(0xFF2E9B5B) : const Color(0xFFD04B4B), size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isCorrect
                    ? '答對了！ · Correct!'
                    : '答錯了 · Incorrect',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score, total;
  const ResultPage({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (score / total * 100).round();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 7,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.all(34),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_rounded, size: 88, color: Color(0xFFF2A900)),
                      const SizedBox(height: 16),
                      const Text('測驗完成 · Quiz Complete', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Text('$score / $total', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Color(0xFF3157D5))),
                      Text('$percent%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const QuizPage()), (_) => false),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('再玩一次 · Play Again', style: TextStyle(fontSize: 17))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('回到首頁 · Home')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GeometryData {
  final List<List<Offset>> polygons;
  GeometryData(this.polygons);

  factory GeometryData.fromGeoJson(Map<String, dynamic> geometry) {
    final type = geometry['type'];
    final coords = geometry['coordinates'];
    final out = <List<Offset>>[];

    void addRing(dynamic ring) {
      out.add([for (final p in ring) Offset((p[0] as num).toDouble(), (p[1] as num).toDouble())]);
    }

    if (type == 'Polygon') {
      for (final ring in coords) addRing(ring);
    } else {
      for (final polygon in coords) {
        for (final ring in polygon) addRing(ring);
      }
    }
    return GeometryData(out);
  }
}

class InteractiveCountryMap extends StatefulWidget {
  final Map<String, GeometryData> shapes;
  final String? selected, correct;
  final void Function(String) onTap;

  const InteractiveCountryMap({super.key, required this.shapes, required this.selected, required this.correct, required this.onTap});

  @override
  State<InteractiveCountryMap> createState() => _InteractiveCountryMapState();
}

class _InteractiveCountryMapState extends State<InteractiveCountryMap> {
  String? hovered;
  double zoom = 1.0;
  Offset pan = Offset.zero;

  void resetView() => setState(() { zoom = 1.0; pan = Offset.zero; });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return Stack(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onHover: (event) {
              final p = event.localPosition;
              final code = MapGeometry.findCountryAt(p, size, widget.shapes, zoom: zoom, pan: pan);
              setState(() { hovered = code; });
            },
            onExit: (_) => setState(() { hovered = null; }),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final code = MapGeometry.findCountryAt(details.localPosition, size, widget.shapes, zoom: zoom, pan: pan);
                if (code != null) widget.onTap(code);
              },
              onScaleStart: (_) {},
              onScaleUpdate: (details) {
                if (details.scale != 1.0) {
                  setState(() => zoom = (zoom * details.scale).clamp(1.0, 4.0));
                }
                if (details.focalPointDelta != Offset.zero) setState(() => pan += details.focalPointDelta);
              },
              child: CustomPaint(
                painter: MapPainter(widget.shapes, widget.selected, widget.correct, hovered, zoom, pan),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Card(
              elevation: 3,
              child: Column(children: [
                IconButton(tooltip: '放大', icon: const Icon(Icons.add), onPressed: () => setState(() => zoom = (zoom + .35).clamp(1.0, 4.0))),
                Text('${zoom.toStringAsFixed(1)}×', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                IconButton(tooltip: '縮小', icon: const Icon(Icons.remove), onPressed: () => setState(() => zoom = (zoom - .35).clamp(1.0, 4.0))),
                IconButton(tooltip: '重設地圖', icon: const Icon(Icons.center_focus_strong), onPressed: resetView),
              ]),
            ),
          ),
        ],
      );
    });
  }

}

class MapGeometry {
  static const minLon = 20.0;
  static const maxLon = 150.0;
  static const minLat = -12.0;
  static const maxLat = 55.0;
  static const padding = 18.0;

  static double baseScaleFor(Size s) {
    final sx = (s.width - padding * 2) / (maxLon - minLon);
    final sy = (s.height - padding * 2) / (maxLat - minLat);
    return math.min(sx, sy);
  }

  static Offset project(Offset p, Size s, {double zoom = 1.0, Offset pan = Offset.zero}) {
    final scale = baseScaleFor(s) * zoom;
    final mapW = (maxLon - minLon) * scale;
    final mapH = (maxLat - minLat) * scale;
    final left = (s.width - mapW) / 2 + pan.dx;
    final top = (s.height - mapH) / 2 + pan.dy;
    return Offset(left + (p.dx - minLon) * scale, top + (maxLat - p.dy) * scale);
  }

  static double pointToSegmentDistance(Offset p, Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    if (dx == 0 && dy == 0) return (p - a).distance;
    final t = (((p.dx - a.dx) * dx) + ((p.dy - a.dy) * dy)) / (dx * dx + dy * dy);
    final clamped = t.clamp(0.0, 1.0);
    final q = Offset(a.dx + dx * clamped, a.dy + dy * clamped);
    return (p - q).distance;
  }

  static bool pointInPolygon(Offset point, List<Offset> polygon, Size size, {double zoom = 1.0, Offset pan = Offset.zero}) {
    if (polygon.length < 3) return false;
    final pts = polygon.map((p) => project(p, size, zoom: zoom, pan: pan)).toList();
    bool inside = false;
    for (int i = 0, j = pts.length - 1; i < pts.length; j = i++) {
      final xi = pts[i].dx, yi = pts[i].dy;
      final xj = pts[j].dx, yj = pts[j].dy;
      final intersect = ((yi > point.dy) != (yj > point.dy)) && (point.dx < (xj - xi) * (point.dy - yi) / ((yj - yi) == 0 ? 0.000001 : (yj - yi)) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  static double distanceToGeometry(Offset point, GeometryData geometry, Size size, {double zoom = 1.0, Offset pan = Offset.zero}) {
    var best = double.infinity;
    for (final ring in geometry.polygons) {
      final pts = ring.map((p) => project(p, size, zoom: zoom, pan: pan)).toList();
      for (var i = 0; i < pts.length; i++) {
        final d = pointToSegmentDistance(point, pts[i], pts[(i + 1) % pts.length]);
        if (d < best) best = d;
      }
    }
    return best;
  }

  static const smallCountryCodes = {'mo','hk','sg','bn','mv','bh','qa','kw','lb','ps','bt','tl','tw'};

  static String? findCountryAt(Offset point, Size size, Map<String, GeometryData> shapes, {double zoom = 1.0, Offset pan = Offset.zero}) {
    for (final entry in shapes.entries) {
      for (final polygon in entry.value.polygons) {
        if (pointInPolygon(point, polygon, size, zoom: zoom, pan: pan)) return entry.key;
      }
    }
    String? nearest;
    var best = double.infinity;
    for (final entry in shapes.entries) {
      if (!smallCountryCodes.contains(entry.key.toLowerCase())) continue;
      final d = distanceToGeometry(point, entry.value, size, zoom: zoom, pan: pan);
      final threshold = 22 / math.sqrt(zoom);
      if (d <= threshold && d < best) { best = d; nearest = entry.key; }
    }
    return nearest;
  }
}

class MapPainter extends CustomPainter {
  final Map<String, GeometryData> shapes;
  final String? selected, correct, hovered;
  final double zoom;
  final Offset pan;
  MapPainter(this.shapes, this.selected, this.correct, this.hovered, this.zoom, this.pan);

  final Paint fill = Paint()..style = PaintingStyle.fill;
  final Paint stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.15..color = const Color(0xFF98A2B3);

  Path pathFor(List<Offset> ring, Size size, {double z = 1.0, Offset p = Offset.zero}) {
    final path = Path();
    if (ring.isEmpty) return path;
    final first = MapGeometry.project(ring.first, size, zoom: z, pan: p);
    path.moveTo(first.dx, first.dy);
    for (final point in ring.skip(1)) { final q = MapGeometry.project(point, size, zoom: z, pan: p); path.lineTo(q.dx, q.dy); }
    path.close();
    return path;
  }

  void drawCountries(Canvas canvas, Size size, {double z = 1.0, Offset p = Offset.zero}) {
    for (final entry in shapes.entries) {
      final code = entry.key;
      final color = code == correct ? const Color(0xFFC8F7D5) : code == selected ? const Color(0xFFFFD6D6) : Colors.white;
      fill.color = color;
      for (final ring in entry.value.polygons) {
        final path = pathFor(ring, size, z: z, p: p);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
      }
      if (code == hovered) {
        final hi = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.8..color = const Color(0xFF3157D5);
        for (final ring in entry.value.polygons) canvas.drawPath(pathFor(ring, size, z: z, p: p), hi);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE7F0FB));
    drawCountries(canvas, size, z: zoom, p: pan);
  }

  @override
  bool shouldRepaint(covariant MapPainter old) => old.selected != selected || old.correct != correct || old.hovered != hovered || old.zoom != zoom || old.pan != pan || old.shapes != shapes;
}

