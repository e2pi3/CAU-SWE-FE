// lib/screens/home_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/cocktail_service.dart';
import '../widgets/app_dialog.dart';
import 'cocktail_info.dart';

class HomeTabScreen extends StatefulWidget {
  final ValueNotifier<int> tabNotifier;

  const HomeTabScreen({super.key, required this.tabNotifier});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> with TickerProviderStateMixin {
  List<CocktailRandomItem> _randomCocktails = [];
  List<CocktailViewItem> _viewRanking = [];
  List<CocktailRatingItem> _ratingRanking = [];

  bool _randomLoading = true;
  bool _viewsLoading = true;
  bool _ratingLoading = true;

  static const _homeTabIndex = 0;

  late final AnimationController _randomAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final AnimationController _viewsAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _ratingAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _loadRandom();
    _loadViewsRanking();
    _loadRatingRanking();
    widget.tabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabNotifier.removeListener(_onTabChanged);
    _randomAnimController.dispose();
    _viewsAnimController.dispose();
    _ratingAnimController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.tabNotifier.value == _homeTabIndex) {
      _loadRandom();
      _loadViewsRanking();
      _loadRatingRanking();
    }
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadRandom(), _loadViewsRanking(), _loadRatingRanking()]);
  }

  Future<void> _loadRandom() async {
    setState(() => _randomLoading = true);
    final items = await CocktailService.getRandomCocktails(count: 3);
    if (!mounted) return;
    setState(() {
      _randomCocktails = items;
      _randomLoading = false;
    });
    _randomAnimController.forward(from: 0);
  }

  Future<void> _loadViewsRanking() async {
    setState(() => _viewsLoading = true);
    final items = await CocktailService.getViewsRanking(limit: 10);
    if (!mounted) return;
    setState(() {
      _viewRanking = items;
      _viewsLoading = false;
    });
    _viewsAnimController.forward(from: 0);
  }

  Future<void> _loadRatingRanking() async {
    setState(() => _ratingLoading = true);
    final items = await CocktailService.getRatingRanking(limit: 10);
    if (!mounted) return;
    setState(() {
      _ratingRanking = items;
      _ratingLoading = false;
    });
    _ratingAnimController.forward(from: 0);
  }

  void _showInfoDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        content: Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.6),
          textAlign: TextAlign.center,
        ),
        actions: [
          AppDialogAction(
            label: '확인',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _openCocktail(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CocktailInfoScreen(id: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadRandom,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRandomSection(),
            const Divider(thickness: 6, color: Color(0xFFEEEEEE), height: 6),
            _buildViewsSection(),
            const Divider(thickness: 6, color: Color(0xFFEEEEEE), height: 6),
            _buildRatingSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── 랜덤 추천 섹션 ──────────────────────────────────────────
  Widget _buildRandomSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Text('오늘의 랜덤 칵테일', style: AppTextStyles.sectionTitle),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: kIsWeb
                ? Row(
                    children: [
                      const Text(
                        '새로고침 버튼으로 무작위 칵테일을 추천받으세요!',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: _loadAll,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.refresh, size: 15, color: AppColors.subtitleText),
                        ),
                      ),
                    ],
                  )
                : const Row(
                    children: [
                      Icon(Icons.refresh, size: 15, color: AppColors.subtitleText),
                      SizedBox(width: 5),
                      Text(
                        '아래로 당겨서 무작위로 칵테일을 추천받으세요!',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
          ),
          _buildHorizontalList(
            loading: _randomLoading,
            count: _randomCocktails.length,
            builder: (i) => _buildAnimatedCard(
              controller: _randomAnimController,
              index: i,
              staggerStep: 0.18,
              child: _buildCard(
                id: _randomCocktails[i].id,
                imageUrl: _randomCocktails[i].imageUrl,
                nameKo: _randomCocktails[i].nameKo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 조회수 랭킹 섹션 ────────────────────────────────────────
  Widget _buildViewsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
            child: Row(
              children: [
                const Expanded(child: Text('사람들이 많이 찾아본 칵테일', style: AppTextStyles.sectionTitle)),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 18, color: AppColors.subtitleText),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showInfoDialog(
                    '조회수 기반 랭킹',
                    '사용자들이 많이 조회한 칵테일 순으로\n표시됩니다.',
                  ),
                ),
              ],
            ),
          ),
          _buildHorizontalList(
            loading: _viewsLoading,
            count: _viewRanking.length,
            builder: (i) {
              final item = _viewRanking[i];
              return _buildAnimatedCard(
                controller: _viewsAnimController,
                index: i,
                staggerStep: 0.07,
                child: _buildCard(
                  id: item.id,
                  imageUrl: item.imageUrl,
                  nameKo: item.nameKo,
                  badge: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, size: 12, color: AppColors.subtitleText),
                      const SizedBox(width: 3),
                      Text(
                        _formatViewCount(item.viewCount),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 평점 랭킹 섹션 ──────────────────────────────────────────
  Widget _buildRatingSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
            child: Row(
              children: [
                const Expanded(child: Text('평점이 높은 칵테일', style: AppTextStyles.sectionTitle)),
                IconButton(
                  icon: const Icon(Icons.help_outline, size: 18, color: AppColors.subtitleText),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showInfoDialog(
                    '평점 기반 랭킹',
                    '사용자들이 남긴 평점의 평균을 기준으로\n표시됩니다.',
                  ),
                ),
              ],
            ),
          ),
          _buildHorizontalList(
            loading: _ratingLoading,
            count: _ratingRanking.length,
            builder: (i) {
              final item = _ratingRanking[i];
              return _buildAnimatedCard(
                controller: _ratingAnimController,
                index: i,
                staggerStep: 0.07,
                child: _buildCard(
                  id: item.id,
                  imageUrl: item.imageUrl,
                  nameKo: item.nameKo,
                  badge: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        item.avgRating.toStringAsFixed(1),
                        style: AppTextStyles.abvBadge,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 공통: 가로 스크롤 리스트 ────────────────────────────────
  Widget _buildHorizontalList({
    required bool loading,
    required int count,
    required Widget Function(int) builder,
  }) {
    if (loading) {
      return SizedBox(
        height: 196,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (_, _) => _buildSkeletonCard(),
        ),
      );
    }
    if (count == 0) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text('데이터를 불러올 수 없습니다.', style: AppTextStyles.placeholder),
        ),
      );
    }
    return SizedBox(
      height: 196,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        itemBuilder: (_, i) => builder(i),
      ),
    );
  }

  // ── 카드 등장 애니메이션 래퍼 ────────────────────────────────
  // staggerStep: 카드 간 시작 지연 비율 (3장=0.18, 10장=0.07)
  // easeOutBack 커브로 살짝 오버슈트 후 제자리 복귀
  Widget _buildAnimatedCard({
    required AnimationController controller,
    required int index,
    required double staggerStep,
    required Widget child,
  }) {
    final start = (index * staggerStep).clamp(0.0, 0.9);
    final end = (start + 0.55).clamp(0.0, 1.0);
    final fadeEnd = (start + 0.35).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: controller,
      builder: (_, w) {
        final slide = Interval(start, end, curve: Curves.easeOutBack)
            .transform(controller.value);
        final fade = Interval(start, fadeEnd, curve: Curves.easeOut)
            .transform(controller.value);
        return Opacity(
          opacity: fade.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 32 * (1 - slide)),
            child: w,
          ),
        );
      },
      child: child,
    );
  }

  // ── 칵테일 카드 ─────────────────────────────────────────────
  Widget _buildCard({
    required String id,
    required String imageUrl,
    required String nameKo,
    int? rank,
    Widget? badge,
  }) {
    return GestureDetector(
      onTap: () => _openCocktail(id),
      child: Container(
        width: 128,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 128,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 128,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_bar_outlined,
                        color: Colors.grey,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                if (rank != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              nameKo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (badge != null) ...[
              const SizedBox(height: 2),
              badge,
            ],
          ],
        ),
      ),
    );
  }

  // ── 스켈레톤 카드 (로딩 중) ─────────────────────────────────
  Widget _buildSkeletonCard() {
    return Container(
      width: 128,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 128,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 80,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  String _formatViewCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}만';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}천';
    }
    return '$count';
  }
}
