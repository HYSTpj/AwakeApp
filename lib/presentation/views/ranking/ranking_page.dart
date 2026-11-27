import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common_layout.dart';
import '../../../models/ranking_user.dart';
import '../../viewmodels/ranking_view_model.dart';

class RankingPage extends StatefulWidget {
  final String groupId;

  const RankingPage({super.key, required this.groupId});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  static const Color _orange = Color(0xFFEC5B13);
  static const Color _peach = Color(0xFFFBDDCF);
  static const BoxBorder _border = Border.fromBorderSide(
    BorderSide(color: Colors.black, width: 2.5),
  );
  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Colors.black, offset: Offset(4, 4)),
  ];

  bool _waitingForInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadGroupRankings(widget.groupId);
  }

  @override
  void didUpdateWidget(covariant RankingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupId != widget.groupId) {
      _loadGroupRankings(widget.groupId);
    }
  }

  void _loadGroupRankings(String groupId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final future = context.read<RankingViewModel>().loadRankings(groupId);
      if (_waitingForInitialLoad) {
        setState(() => _waitingForInitialLoad = false);
      }
      unawaited(future);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      groupId: widget.groupId,
      body: Consumer<RankingViewModel>(
        builder: (context, viewModel, _) =>
            _buildBody(context, viewModel.state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RankingState state) {
    final users = state.rankings;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_alt_outlined, size: 28),
              SizedBox(width: 8),
              Text(
                'Ranking',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_waitingForInitialLoad || state.isLoading)
            const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.errorMessage != null)
            _buildError(context, state.errorMessage!)
          else if (users.isEmpty)
            const SizedBox(
              height: 240,
              child: Center(child: Text('ランキングデータがありません。')),
            )
          else ...[
            _buildTopCard(users.first),
            for (var index = 1; index < users.length; index++) ...[
              const SizedBox(height: 15),
              _buildListItem(users[index], index + 1),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ランキングを取得できませんでした。'),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<RankingViewModel>().loadRankings(widget.groupId),
              child: const Text('再読み込み'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(RankingUser user) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: _border,
            boxShadow: _shadow,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildAvatar(user.avatarUrl, size: 120),
              const SizedBox(height: 15),
              Text(
                user.nickname,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LATE CHAMP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _orange, border: _border),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'STREAK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        '${user.streak} EVENTS',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildMetricBox(
                    'TOTAL DELAY',
                    _formatDuration(user.totalDelayMinutes),
                  ),
                  const SizedBox(width: 10),
                  _buildMetricBox('AVG. DELAY', '${user.avgDelayMinutes} MIN'),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -10,
          left: -5,
          child: Transform.rotate(
            angle: -0.1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _orange,
                border: _border,
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                ],
              ),
              child: const Text(
                '#1',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          border: _border,
          boxShadow: _shadow,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(RankingUser user, int rank) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: _border,
        boxShadow: _shadow,
      ),
      child: Row(
        children: [
          Text(
            '#$rank',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(width: 10),
          _buildAvatar(user.avatarUrl, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user.nickname,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Text(
              _formatDuration(user.totalDelayMinutes),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _peach,
        border: _border,
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
      ),
      child: ClipOval(
        child: avatarUrl == null || avatarUrl.isEmpty
            ? _avatarFallback(size)
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _avatarFallback(size),
              ),
      ),
    );
  }

  Widget _avatarFallback(double size) {
    return Container(
      color: _peach,
      alignment: Alignment.center,
      child: Icon(Icons.person, color: Colors.black, size: size * 0.55),
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}H ${remainingMinutes}M';
  }
}
