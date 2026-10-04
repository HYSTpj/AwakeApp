import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../common_layout.dart';
import '../group/create_add_delete_view.dart';
import 'checkin/member_check_in.dart';
import '../../views/member_settime.dart';

class EventSelectionHome extends StatefulWidget {
  final String groupId;
  final String groupName;
  final int myRole;

  const EventSelectionHome({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.myRole,
  });

  @override
  State<EventSelectionHome> createState() => _EventSelectionHomeState();
}

class _EventSelectionHomeState extends State<EventSelectionHome> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? selectedGroupId;
  String? selectedGroupName;
  List<Map<String, dynamic>> _myGroups = [];
  bool _isLoadingGroups = true;
  Future<List<Map<String, dynamic>>>? _eventsFuture;
  late int myRole;

  @override
  void initState() {
    super.initState();
    myRole = widget.myRole;
    selectedGroupId = widget.groupId;
    selectedGroupName = widget.groupName;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) setState(() => _isLoadingGroups = false);
      return;
    }

    try {
      final response = await _supabase
          .from('groups_memberships')
          .select('group_id, role, groups ( id, group_name, invitation_code )')
          .eq('user_id', uid);

      final groupList = (response as List<dynamic>).map((item) {
        final g = item['groups'] as Map<String, dynamic>? ?? {};
        return {
          'group_id': item['group_id'] as String,
          'group_name': (g['group_name'] ?? 'Unnamed Group') as String,
          'invitation_code': (g['invitation_code'] ?? '') as String,
          'role': item['role'] as int? ?? 1,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _myGroups = groupList;
          _isLoadingGroups = false;
          if (groupList.isNotEmpty) {
            final currentGroup = groupList.firstWhere(
              (g) => g['group_id'] == widget.groupId,
              orElse: () => groupList.first,
            );
            selectedGroupId = currentGroup['group_id'] as String?;
            selectedGroupName = currentGroup['group_name'] as String?;
            myRole = (currentGroup['role'] as int?) ?? 1;
            _eventsFuture = _fetchEvents(selectedGroupId!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading groups: $e');
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEvents(String groupId) async {
    try {
      final response = await _supabase
          .from('events_view')
          .select()
          .eq('group_id', groupId)
          .order('arrival_time', ascending: true);

      return (response as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      debugPrint('Error loading events: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      groupId: selectedGroupId,
      groupName: selectedGroupName,
      myRole: myRole,
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
            'GROUP NAME',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1C),
              letterSpacing: 0.5,
            ),
          ),
          items: [
            ..._myGroups.map((group) {
              return DropdownMenuItem<String>(
                value: group['group_id'],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      group['group_name'] ?? 'Unnamed Group',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1C1C),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final code = group['invitation_code'] ?? '';
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied the invitation code')),
                        );
                      },
                      child: const Icon(Icons.content_copy, color: Colors.black, size: 20),
                    ),
                  ],
                ),
              );
            }),
            const DropdownMenuItem<String>(
              value: 'create_add_delete',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CREATE OR ADD OR DELETE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF5C00),
                    ),
                  ),
                  Icon(Icons.add_box, color: Color(0xFFFF5C00)),
                ],
              ),
            ),
          ],
          onChanged: (String? newGroupId) {
            if (newGroupId == null) return;

            if (newGroupId == 'create_add_delete') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateOrAddOrDeletePage()),
              );
            } else {
              final group = _myGroups.firstWhere((g) => g['group_id'] == newGroupId);
              setState(() {
                selectedGroupId = newGroupId;
                selectedGroupName = group['group_name'];
                myRole = group['role'];
                _eventsFuture = _fetchEvents(newGroupId);
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
    if (selectedGroupId == null || _eventsFuture == null) {
      return const Center(
        child: Text(
          'Select or Create a Group first.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _eventsFuture,
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
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));

    List<Map<String, dynamic>> todayEvents = [];
    List<Map<String, dynamic>> tomorrowEvents = [];
    List<Map<String, dynamic>> otherEvents = [];

    for (var ev in events) {
      final rawArrival = ev['arrival_time'];
      DateTime? dt;

      if (rawArrival != null) {
        if (rawArrival is DateTime) {
          dt = rawArrival;
        } else if (rawArrival is String) {
          dt = DateTime.tryParse(rawArrival);
        }
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
        otherEvents.add(ev);
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (todayEvents.isNotEmpty) ...[
          _buildSectionHeader('TODAY', DateFormat('MMM dd').format(now)),
          ...todayEvents.map((e) => _buildEventCard(e)),
        ],
        if (tomorrowEvents.isNotEmpty) ...[
          _buildSectionHeader('TOMORROW', ''),
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
              fontWeight: FontWeight.w900,
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
                color: Color(0xFFFF5C00),
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
    final rawArrival = event['arrival_time'];

    String meetingTimeStr = '--:--';
    if (rawArrival != null) {
      DateTime? dt;
      if (rawArrival is DateTime) {
        dt = rawArrival;
      } else if (rawArrival is String) {
        dt = DateTime.tryParse(rawArrival);
      }
      if (dt != null) {
        meetingTimeStr = DateFormat("hh:mm a").format(dt);
      }
    }

    String formatTime(dynamic rawTime) {
      if (rawTime == null) return '--:--';
      DateTime? dt = rawTime is DateTime ? rawTime : DateTime.tryParse(rawTime.toString());
      return dt != null ? DateFormat("hh:mm a").format(dt) : '--:--';
    }

    final wakeupTimeStr = formatTime(event['planned_wakeup_time']);
    final departureTimeStr = formatTime(event['planned_departure_time']);

    final eventId = (event['id'] ?? event['event_id'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1A1C1C), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF1A1C1C), width: 3),
                ),
                child: IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.settings, color: Color(0xFF1A1C1C), size: 24),
                  onPressed: () async {
                    final arrivalTime = event['arrival_time'];
                    DateTime arrivalDateTime = DateTime.now();

                    if (arrivalTime is String && arrivalTime.isNotEmpty) {
                      try {
                        arrivalDateTime = DateTime.parse(arrivalTime);
                      } catch (e) {
                        debugPrint('時刻パースエラー: $e');
                      }
                    } else if (arrivalTime is DateTime) {
                      arrivalDateTime = arrivalTime;
                    }

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetTimePage(
                          groupId: selectedGroupId ?? widget.groupId,
                          eventId: eventId,
                          eventTitle: title,
                          myRole: myRole,
                          arrivalTime: arrivalDateTime,
                        ),
                      ),
                    );

                    if (mounted && selectedGroupId != null) {
                      setState(() {
                        _eventsFuture = _fetchEvents(selectedGroupId!);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberCheckInPage(
                        eventId: eventId,
                        eventTitle: title,
                        groupId: selectedGroupId ?? widget.groupId,
                        groupName: selectedGroupName ?? widget.groupName,
                        myRole: myRole,
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
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF6B7280), size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimeRow('WAKE-UP', wakeupTimeStr, Colors.black),
          _buildDivider(),
          _buildTimeRow('DEPARTURE', departureTimeStr, const Color(0xFFFF5C00)),
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
              color: Color(0xFF9CA3AF),
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
      color: const Color(0xFFE5E7EB),
    );
  }
}