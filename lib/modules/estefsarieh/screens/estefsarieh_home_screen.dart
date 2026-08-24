import 'package:flutter/material.dart';

import '../data/faq_repository.dart';
import '../data/faq_search.dart';
import '../models/faq_models.dart';
import '../theme/estefsarieh_theme.dart';
import 'estefsarieh_detail_screen.dart';

/* ------------------------------------------------------------------ */
/*  خط‌چین عمودی سبزآبی برای ساختار درختی                              */
/* ------------------------------------------------------------------ */
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  _DashedLinePainter({
    required this.color,
    this.dashWidth = 4,
    this.dashGap = 4,
    this.strokeWidth = 1.7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dashWidth).clamp(0, size.height)),
        paint,
      );
      y += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.dashGap != dashGap ||
      old.strokeWidth != strokeWidth;
}

class _DashedVerticalLine extends StatelessWidget {
  final double height;
  final Color color;
  final double width;

  const _DashedVerticalLine({
    required this.height,
    this.color = _UiColors.teal,
    this.width = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/*  رنگ‌های اختصاصی این صفحه                                          */
/* ------------------------------------------------------------------ */
class _UiColors {
  static const Color sky = Color(0xFFEAF6FF);
  static const Color skyBorder = Color(0xFFC9E6F7);
  static const Color material = Color(0xFFF6F8FA);
  static const Color materialBorder = Color(0xFFDDE4EA);
  static const Color question = Colors.white;
  static const Color questionBorder = Color(0xFFE6EBF0);
  static const Color teal = Color(0xFF00BFA5);
  static const Color tealSoft = Color(0x1A00BFA5);
  static const Color searchHighlight = Color(0xFFD9FF4A);
  static const Color shadow = Color(0x180D47A1);
  static const Color shadowSoft = Color(0x100D47A1);
}

/* ------------------------------------------------------------------ */
/*  صفحه اصلی استفساریه                                               */
/* ------------------------------------------------------------------ */
class EstefsariehHomeScreen extends StatefulWidget {
  EstefsariehHomeScreen({super.key, FaqRepository? repository})
      : repository = repository ?? FaqRepository();

  final FaqRepository repository;

  @override
  State<EstefsariehHomeScreen> createState() => _EstefsariehHomeScreenState();
}

class _EstefsariehHomeScreenState extends State<EstefsariehHomeScreen> {
  List<FaqCategory> _data = [];
  bool _loading = true;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  // Expansion state is controlled explicitly instead of relying on
  // ExpansionTile. This avoids nested-layout issues and guarantees taps
  // on category/material cards open their children.
  final Set<int> _expandedCategories = <int>{};
  final Set<String> _expandedMaterials = <String>{};

  @override
  void initState() {
    super.initState();
    widget.repository.load().then((data) {
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    });
  }

  int get _totalQuestions => _data.fold(0, (sum, c) => sum + c.questionCount);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(FaqCategory category, FaqMaterial material, FaqItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstefsariehDetailScreen(
          category: category,
          material: material,
          item: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: EstefsariehColors.bgBase,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: EstefsariehColors.primary,
                        ),
                      )
                    : _query.trim().isEmpty
                        ? _buildTree()
                        : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: EstefsariehDecor.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x220D47A1),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/logo/10.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_tree_rounded,
                      color: EstefsariehColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'رهپیمان',
                      style: TextStyle(
                        fontFamily: EstefsariehTypography.brand,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'بانک پرسش و پاسخ نظام فنی و اجرایی کشور',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: EstefsariehTypography.medium,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              _countBadge(_totalQuestions),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchBox(),
        ],
      ),
    );
  }

  /* ---------------- نوار جستجو ------------------------------------ */
  Widget _buildSearchBox() {
    final hasQuery = _query.trim().isNotEmpty;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          if (hasQuery)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 48,
                    end: 44,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: RichText(
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          text: _query,
                          style: const TextStyle(
                            fontFamily: EstefsariehTypography.body,
                            fontSize: 13.5,
                            height: 1.1,
                            color: EstefsariehColors.textPrimary,
                            backgroundColor: Color(0xFFE3FF64),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            cursorColor: _UiColors.teal,
            cursorWidth: 2,
            style: const TextStyle(
              fontFamily: EstefsariehTypography.body,
              fontSize: 13.5,
              color: Colors.transparent,
            ),
            decoration: InputDecoration(
              hintText: 'جستجو در پرسش‌ها، پاسخ‌ها یا کد ماده...',
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(
                fontFamily: EstefsariehTypography.medium,
                color: EstefsariehColors.textDim,
                fontSize: 12.5,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: EstefsariehColors.primary,
                size: 23,
              ),
              suffixIcon: hasQuery
                  ? IconButton(
                      tooltip: 'پاک کردن جستجو',
                      icon: const Icon(
                        Icons.close_rounded,
                        color: EstefsariehColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: _UiColors.teal,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- ساختار درختی --------------------------------- */
  Widget _buildTree() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
      itemCount: _data.length,
      itemBuilder: (context, categoryIndex) {
        final cat = _data[categoryIndex];
        return _buildCategoryCard(
          cat: cat,
          categoryIndex: categoryIndex,
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required FaqCategory cat,
    required int categoryIndex,
  }) {
    final isExpanded = _expandedCategories.contains(categoryIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _UiColors.sky,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _UiColors.skyBorder,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: _UiColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: _UiColors.tealSoft,
          highlightColor: _UiColors.tealSoft,
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedCategories.remove(categoryIndex);

                // وقتی سرشاخه بسته شد، وضعیت مواد آن هم پاک می‌شود.
                _expandedMaterials.removeWhere(
                  (key) => key.startsWith('$categoryIndex-'),
                );
              } else {
                _expandedCategories.add(categoryIndex);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _UiColors.skyBorder,
                        ),
                      ),
                      child: const Icon(
                        Icons.folder_rounded,
                        size: 19,
                        color: EstefsariehColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.category,
                            style: const TextStyle(
                              fontFamily: EstefsariehTypography.heading,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: EstefsariehColors.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${cat.questionCount} پرسش • ${cat.materials.length} ماده',
                            style: const TextStyle(
                              fontFamily: EstefsariehTypography.medium,
                              fontSize: 10.5,
                              color: EstefsariehColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 25,
                        color: EstefsariehColors.primary,
                      ),
                    ),
                  ],
                ),

                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    color: _UiColors.skyBorder,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      for (int materialIndex = 0;
                          materialIndex < cat.materials.length;
                          materialIndex++)
                        _buildMaterial(
                          cat: cat,
                          mat: cat.materials[materialIndex],
                          categoryIndex: categoryIndex,
                          materialIndex: materialIndex,
                          depth: 1,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterial({
    required FaqCategory cat,
    required FaqMaterial mat,
    required int categoryIndex,
    required int materialIndex,
    required int depth,
  }) {
    final materialKey = '$categoryIndex-$materialIndex';
    final isExpanded = _expandedMaterials.contains(materialKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 2,
              top: 5,
              bottom: 5,
            ),
            child: _DashedVerticalLine(
              height: isExpanded
                  ? ((mat.items.length * 54.0) + 78)
                  : 52,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _UiColors.material,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _UiColors.materialBorder,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: _UiColors.shadowSoft,
                    blurRadius: 7,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  splashColor: _UiColors.tealSoft,
                  highlightColor: _UiColors.tealSoft,
                  onTap: () {
                    if (mat.items.isEmpty) return;

                    setState(() {
                      if (isExpanded) {
                        _expandedMaterials.remove(materialKey);
                      } else {
                        _expandedMaterials.add(materialKey);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _UiColors.tealSoft,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                size: 17,
                                color: _UiColors.teal,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mat.title.isEmpty
                                        ? 'ماده ${mat.materialId}'
                                        : mat.title,
                                    style: const TextStyle(
                                      fontFamily: EstefsariehTypography.heading,
                                      fontSize: 12.8,
                                      fontWeight: FontWeight.w700,
                                      color: EstefsariehColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${mat.items.length} پرسش',
                                    style: const TextStyle(
                                      fontFamily: EstefsariehTypography.medium,
                                      fontSize: 10,
                                      color: EstefsariehColors.textDim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 180),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 22,
                                color: _UiColors.teal,
                              ),
                            ),
                          ],
                        ),

                        if (isExpanded && mat.items.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Column(
                            children: mat.items
                                .map(
                                  (item) => _buildItem(
                                    cat: cat,
                                    mat: mat,
                                    item: item,
                                    depth: depth + 1,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required FaqCategory cat,
    required FaqMaterial mat,
    required FaqItem item,
    required int depth,
  }) {
    final q = item.question.length > 105
        ? '${item.question.substring(0, 105)}...'
        : item.question;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => _openDetail(cat, mat, item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: _UiColors.question,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _UiColors.questionBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: _UiColors.teal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  q,
                  style: const TextStyle(
                    fontFamily: EstefsariehTypography.medium,
                    fontSize: 12.1,
                    height: 1.65,
                    color: EstefsariehColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: EstefsariehColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _searchWords(String query) => query
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  TextSpan _highlightSpan(
    String text,
    String query, {
    TextStyle? baseStyle,
  }) {
    final words = _searchWords(query);
    if (words.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final pattern = words.map(RegExp.escape).join('|');
    final regex = RegExp(pattern, caseSensitive: false);
    final matches = regex.allMatches(text).toList();

    if (matches.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final children = <TextSpan>[];
    var cursor = 0;

    for (final match in matches) {
      if (match.start > cursor) {
        children.add(
          TextSpan(
            text: text.substring(cursor, match.start),
            style: baseStyle,
          ),
        );
      }

      children.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: (baseStyle ?? const TextStyle()).copyWith(
            backgroundColor: _UiColors.searchHighlight,
            fontWeight: FontWeight.w800,
            color: EstefsariehColors.textPrimary,
          ),
        ),
      );

      cursor = match.end;
    }

    if (cursor < text.length) {
      children.add(
        TextSpan(
          text: text.substring(cursor),
          style: baseStyle,
        ),
      );
    }

    return TextSpan(children: children);
  }

  Widget _highlightedText(
    String text,
    String query, {
    required TextStyle style,
    int? maxLines,
  }) {
    return RichText(
      maxLines: maxLines,
      overflow:
          maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      textDirection: TextDirection.rtl,
      text: _highlightSpan(text, query, baseStyle: style),
    );
  }

  Widget _buildSearchResults() {
    final results = FaqSearch.search(_data, _query);

    if (results.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _UiColors.questionBorder),
            boxShadow: const [
              BoxShadow(
                color: _UiColors.shadowSoft,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _UiColors.tealSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: _UiColors.teal,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'نتیجه‌ای یافت نشد',
                style: TextStyle(
                  fontFamily: EstefsariehTypography.heading,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: EstefsariehColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'برای «$_query» موردی در بانک پرسش و پاسخ پیدا نشد.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: EstefsariehTypography.body,
                  fontSize: 11.5,
                  height: 1.7,
                  color: EstefsariehColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final r = results[i];
        final questionStyle = const TextStyle(
          fontFamily: EstefsariehTypography.body,
          fontSize: 12.3,
          height: 1.75,
          color: EstefsariehColors.textPrimary,
        );

        final answerStyle = const TextStyle(
          fontFamily: EstefsariehTypography.medium,
          fontSize: 11.2,
          height: 1.75,
          color: EstefsariehColors.textMuted,
        );

        final materialStyle = const TextStyle(
          fontFamily: EstefsariehTypography.medium,
          fontSize: 10.5,
          color: EstefsariehColors.textMuted,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: _UiColors.tealSoft,
              onTap: () => _openDetail(r.category, r.material, r.item),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _UiColors.questionBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _UiColors.tealSoft,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.question_mark_rounded,
                            size: 17,
                            color: _UiColors.teal,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.matchSource == MatchSource.answer
                                    ? 'پاسخ مرتبط'
                                    : 'پرسش مرتبط',
                                style: const TextStyle(
                                  fontFamily: EstefsariehTypography.heading,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: EstefsariehColors.primary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              _highlightedText(
                                r.item.question,
                                _query,
                                style: questionStyle,
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: _UiColors.questionBorder,
                        ),
                      ),
                      child: _highlightedText(
                        FaqSearch.snippetAround(
                          r.item.answer,
                          _query,
                          radius: 80,
                        ),
                        _query,
                        style: answerStyle,
                        maxLines: 4,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 15,
                          color: _UiColors.teal,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            r.material.title.isEmpty
                                ? 'ماده ${r.material.materialId}'
                                : r.material.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: materialStyle,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_left_rounded,
                          size: 19,
                          color: EstefsariehColors.textFaint,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _UiColors.teal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$count پرسش',
        style: const TextStyle(
          fontFamily: EstefsariehTypography.medium,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
