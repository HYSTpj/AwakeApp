import 'package:flutter/material.dart';
import '../../../../style/app_color.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import '../../../../common_layout.dart';
import 'select_participants_page.dart';

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

// 地図の初期表示フォールバック位置（東京）
const _kDefaultMapCenter = LatLng(35.681236, 139.767125);

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
  final int myRole;

  const CreateEventPage({
    super.key,
    required this.groupId,
    required this.myRole,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime _scheduledTime = DateTime.now();

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};

  int _searchGeneration = 0;

  bool _isNavigating = false;

  String get _timeLabel {
    final h = _scheduledTime.hour % 12 == 0 ? 12 : _scheduledTime.hour % 12;
    final m = _scheduledTime.minute.toString().padLeft(2, '0');
    final period = _scheduledTime.hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')} : $m $period';
  }

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
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2030, 12, 31),
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
    final query = address.trim();
    if (query.isEmpty) return;

    // 検索開始時に世代番号を進め、リクエスト時の世代を保持
    final currentGeneration = ++_searchGeneration;

    try {
      final locations = await locationFromAddress(query);

      // 非同期待機中に地名が変更された、または別の検索が走った場合は破棄
      if (!mounted) return;
      if (currentGeneration != _searchGeneration ||
          _locationController.text.trim() != query) {
        return;
      }

      if (locations.isNotEmpty) {
        final target = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        setState(() {
          _selectedLocation = target;
          _markers = {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: target,
            ),
          };
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 15),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('場所が見つかりませんでした')));
      }
    } catch (e) {
      debugPrint('検索エラー: $e');
      if (!mounted) return;
      if (currentGeneration != _searchGeneration ||
          _locationController.text.trim() != query) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('場所の検索に失敗しました。住所や地名を確認してください')),
      );
    }
  }

  Future<void> _onNextPressed() async {
    if (_isNavigating) return;

    final title = _nameController.text.trim();
    final location = _locationController.text.trim();
    final password = _passwordController.text.trim();

    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('イベント名と場所を入力してください')));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('チェックイン用パスコードを入力してください')));
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目的地の場所をキーボードの「検索」で確定してください')),
      );
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectParticipantsPage(
            groupId: widget.groupId,
            title: title,
            destinationName: location,
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
            arrivalTime: _scheduledTime,
            password: password,
            myRole: widget.myRole,
          ),
        ),
      );

      if (!mounted) return;
      if (result == true) {
        Navigator.pop(context, true);
      }
    } finally {
      // 画面から戻ってきた場合に再度タップできるようにフラグを解除
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      groupId: widget.groupId,
      myRole: widget.myRole,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
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
                  const _LabelText('TIME'),
                  _PickerButton(label: _timeLabel, onTap: _pickTime),
                  const _LabelText('DATE'),
                  _PickerButton(label: _dateLabel, onTap: _pickDate),
                  const _LabelText('CHECK-IN PASSWORD'),
                  const SizedBox(height: 4),
                  _InputBox(
                    child: TextField(
                      controller: _passwordController,
                      textAlignVertical: TextAlignVertical.center,
                      style: _kValueStyle,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter backup numeric passcode...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
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
                        suffixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF475569),
                        ),
                      ),
                      onChanged: (value) {
                        // テキスト変更時に世代番号を進めて先行リクエストを無効化
                        _searchGeneration++;
                        if (_selectedLocation != null) {
                          setState(() {
                            _selectedLocation = null;
                            _markers = {};
                          });
                        }
                      },
                      onSubmitted: _searchLocation,
                    ),
                  ),
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
                      // null の場合はフォールバック座標を使用
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation ?? _kDefaultMapCenter,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      markers: _markers,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 32),
                    child: InkWell(
                      onTap: _isNavigating ? null : _onNextPressed,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: _isNavigating ? Colors.grey : AppColors.orange,
                          shape: const RoundedRectangleBorder(
                            side: _kBorderSide,
                          ),
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
