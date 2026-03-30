import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'common_layout.dart';
import 'create_add_delete.dart';
import 'member_check_in.dart';
import '../data/group_repository.dart';
import '../data/event_repository.dart';

class EventSelectionHome extends StatefulWidget {
  const EventSelectionHome({super.key});

  @override
  State<EventSelectionHome> createState() => _EventSelectionHomeState();
}

class _EventSelectionHomeState extends State<EventSelectionHome> {
  final user = FirebaseAuth.instance.currentUser;
  String? selectedGroupId;
  List<Map<String, dynamic>> _myGroups = [];
  bool _isLoadingGroups = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final uid = user?.uid;
    if (uid == null) {
      setState(() => _isLoadingGroups = false);
      return;
    }
    
    try {
      final groups = await GroupRepository().getGroups(uid);
      if (mounted) {
        setState(() {
          _myGroups = groups;
          _isLoadingGroups = false;
          if (groups.isNotEmpty) {
            selectedGroupId = groups.first['group_id'];
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading groups: $e');
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      // 緑の追加ボタン（FAB）
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[900],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrAddOrDeletePage()),
          );
        },
        shape: CircleBorder(
          side: const BorderSide(color: Colors.black, width: 2), // Neo-Brutalism
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Column(
        children: [
          _buildGroupDropdown(),
          Expanded(
            child: _buildEventListArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGroupId,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 28),
          hint: const Text(
            'GROUP NAME', // Groupsがない場合のデフォルト表記
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1C),
              letterSpacing: 0.5,
            ),
          ),
          items: _myGroups.map((group) {
            return DropdownMenuItem<String>(
              value: group['group_id'],
              child: Text(
                group['group_name'] ?? 'Unnamed Group',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C1C),
                  letterSpacing: 0.5,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newGroupId) {
            if (newGroupId != null) {
              setState(() {
                selectedGroupId = newGroupId;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildEventListArea() {
    if (_isLoadingGroups) {
      return const Center(child: CircularProgressIndicator());
    }
    if (selectedGroupId == null) {
      return const Center(
        child: Text(
          'Select or Create a Group first.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: EventRepository().getEvents(selectedGroupId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return const Center(
            child: Text(
              'No events found for this group.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }

        return _buildCategorizedList(events);
      },
    );
  }

  Widget _buildCategorizedList(List<Map<String, dynamic>> events) {
    // 日付でイベントを分類 (`arrival_time` を使用)
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));

    List<Map<String, dynamic>> todayEvents = [];
    List<Map<String, dynamic>> tomorrowEvents = [];
    List<Map<String, dynamic>> otherEvents = [];

    for (var ev in events) {
      final arrivalTime = ev['arrival_time'];
      DateTime? dt;
      if (arrivalTime is Timestamp) {
        dt = arrivalTime.toDate();
      }
      
      if (dt != null) {
        final evDateStr = DateFormat('yyyy-MM-dd').format(dt);
        if (evDateStr == todayStr) {
          todayEvents.add(ev);
        } else if (evDateStr == tomorrowStr) {
          tomorrowEvents.add(ev);
        } else {
          otherEvents.add(ev);
        }
      } else {
        // Timestampが無い場合はすべてOtherに逃がす
        otherEvents.add(ev);
      }
    }

    // Listを作成
    return ListView(
      padding: const EdgeInsets.only(bottom: 100), // BottomNavのスペース用
      children: [
        if (todayEvents.isNotEmpty) ...[
          _buildSectionHeader('TODAY', DateFormat('MMM dd').format(now)), // ex: "TODAY OCT 24"
          ...todayEvents.map((e) => _buildEventCard(e)),
        ],
        if (tomorrowEvents.isNotEmpty) ...[
          _buildSectionHeader('TOMORROW', ''), // 明日の場合は文字を薄くするスタイルを適用
          ...tomorrowEvents.map((e) => _buildEventCard(e)),
        ],
        if (otherEvents.isNotEmpty) ...[
          _buildSectionHeader('UPCOMING', ''),
          ...otherEvents.map((e) => _buildEventCard(e)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, String dateSubtitle) {
    final isTomorrow = title == 'TOMORROW';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900, // Black/Heavy font weight
              letterSpacing: -1.0,
              color: isTomorrow ? const Color(0xFFC4C4C4) : const Color(0xFF1A1C1C),
            ),
          ),
          if (dateSubtitle.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              dateSubtitle.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFF5C00), // Orange
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFFFF5C00),
                decorationThickness: 2,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final title = event['title'] ?? 'NO TITLE';
    final location = event['destination_name'] ?? 'SECTOR 7G - COMMAND CENTER';
    final arrivalTime = event['arrival_time'];
    
    String meetingTimeStr = '08:15 AM'; // default fallback
    if (arrivalTime != null && arrivalTime is Timestamp) {
      meetingTimeStr = DateFormat("hh:mm a").format(arrivalTime.toDate());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1A1C1C), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4), // デザインのように少しだけずらす太い影
            blurRadius: 0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1C1C),
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Arrow Button
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberCheckInPage(
                        eventId: event['event_id'],
                        eventTitle: title,
                        groupId: selectedGroupId ?? '',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF1A1C1C), width: 3),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_forward, color: Color(0xFF1A1C1C), size: 24),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          // Location text
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF6B7280), size: 16), // gray icon
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280), // gray text
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Time Schedule Lines
          _buildTimeRow('WAKE-UP', '06:30 AM', Colors.black),
          _buildDivider(),
          _buildTimeRow('DEPARTURE', '07:15 AM', const Color(0xFFFF5C00)),
          _buildDivider(),
          _buildTimeRow('MEETING', meetingTimeStr, Colors.black),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, String timeString, Color timeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9CA3AF), // Lighter gray for label
              letterSpacing: 0.5,
            ),
          ),
          Text(
            timeString,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: timeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: const Color(0xFFE5E7EB), // faint gray line
    );
  }
}
