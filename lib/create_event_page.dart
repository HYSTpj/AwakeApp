import 'package:flutter/material.dart';
import 'style/app_color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'common_layout.dart';
import 'select_participants_page.dart';
import 'data/event_repository.dart';


const _kBorderSide = BorderSide(width: 3, color: Color(0xFF475569));
const _kLabelStyle = TextStyle(
  fontSize: 14,
  fontFamily: 'Noto Sans JP',
  fontWeight: FontWeight.w700,
  height: 1.43,
  letterSpacing: 0.70,
);
const _kValueStyle = TextStyle(
  fontSize: 14,
  fontFamily: 'Noto Sans JP',
  fontWeight: FontWeight.w700,
  color: Colors.black,
);


class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: _kLabelStyle),
    );
  }
}

// 枠付きの入力フィールドコンテナ
class _InputBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _InputBox({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(side: _kBorderSide),
      ),
      child: child,
    );
  }
}

// 枠付きの選択ボタン（時間・日付）
class _PickerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PickerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 152,
          height: 48,
          alignment: Alignment.center,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(side: _kBorderSide),
          ),
          child: Text(label, style: _kValueStyle),
        ),
      ),
    );
  }
}

class CreateEventPage extends StatefulWidget {
  final String groupId; 

  const CreateEventPage({
    super.key,
    required this.groupId,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _scheduledTime = DateTime.now();

  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(35.136405122360785, 136.97564747897678);
  Set<Marker> _markers = {};

  // 時刻表示文字列
  String get _timeLabel {
    final h = _scheduledTime.hour % 12 == 0 ? 12 : _scheduledTime.hour % 12;
    final m = _scheduledTime.minute.toString().padLeft(2, '0');
    final period = _scheduledTime.hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')} : $m $period';
  }

  // 日付表示文字列
  String get _dateLabel {
    final month = _scheduledTime.month.toString().padLeft(2, '0');
    final day = _scheduledTime.day.toString().padLeft(2, '0');
    return '$month / $day / ${_scheduledTime.year}';
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledTime),
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = DateTime(
          _scheduledTime.year,
          _scheduledTime.month,
          _scheduledTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _scheduledTime.hour,
          _scheduledTime.minute,
        );
      });
    }
  }

  Future<void> _searchLocation(String address) async {
    if (address.isEmpty) return;
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final target = LatLng(locations.first.latitude, locations.first.longitude);
        if (!mounted) return;
        setState(() {
          _selectedLocation = target;
          _markers = {
            Marker(markerId: const MarkerId('selected_location'), position: target),
          };
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 15)),
        );
      }
    } catch (e) {
      debugPrint('検索エラー: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 戻るボタン
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 9),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(side: _kBorderSide),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 0,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                ),
              ),
            ),

            // タイトル
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: Center(
                child: Text(
                  'Create Event',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: -0.96,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // イベント名
                  const _LabelText('EVENT NAME'),
                  const SizedBox(height: 4),
                  _InputBox(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _nameController,
                      textAlignVertical: TextAlignVertical.center,
                      style: _kValueStyle,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // 時間
                  const _LabelText('TIME'),
                  _PickerButton(label: _timeLabel, onTap: _pickTime),

                  // 日付
                  const _LabelText('DATE'),
                  _PickerButton(label: _dateLabel, onTap: _pickDate),

                  // 場所
                  const _LabelText('Location'),
                  const SizedBox(height: 4),
                  _InputBox(
                    child: TextField(
                      controller: _locationController,
                      textAlignVertical: TextAlignVertical.center,
                      style: _kValueStyle,
                      decoration: const InputDecoration(
                        hintText: 'Search location...',
                        border: InputBorder.none,
                        isDense: true,
                        suffixIcon: Icon(Icons.search, color: Color(0xFF475569)),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),

                  // Google Map
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 250,
                    clipBehavior: Clip.antiAlias,
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(side: _kBorderSide),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 15),
                      onMapCreated: (controller) => _mapController = controller,
                      markers: _markers,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                      },
                    ),
                  ),

                  // Confirm Participantボタン
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 32),
                    child: InkWell(
                      onTap: () async {
                        // 1. 入力チェック
                        if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill in all fields.')),
                          );
                          return;
                        }

                        // 2. EventRepositoryを使ってFirestoreに保存
                        final eventId = await EventRepository().setEvent(
                          groupId: widget.groupId,
                          title: _nameController.text,
                          destinationName: _locationController.text, // 目的地名として使用
                          location: '${_selectedLocation.latitude},${_selectedLocation.longitude}', // 座標を文字列で保存
                          qrcodeId: 'dummy_qr', // 必要に応じて生成ロジックを追加
                          password: 'default_password', 
                          arrivalTime: _scheduledTime.toIso8601String(), // 文字列型で保存
                          status: 'planning',
                        );

                        // 3. 次の画面（参加者選択ページ）へ遷移
                        if (eventId != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectParticipantsPage(
                                eventId: eventId,
                                groupId: widget.groupId,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: AppColors.orange,
                          shape: const RoundedRectangleBorder(side: _kBorderSide),
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(4, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Confirm Participant',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}