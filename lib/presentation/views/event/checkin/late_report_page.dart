import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;
import '../../../viewmodels/late_report_viewmodel.dart';
import '../../../../common_layout.dart';
import '../../../../widgets/time_input_box.dart';
import '../../../../style/app_color.dart';
import 'member_check_in_page.dart' show GroupNameDropdown, EventNameDropdown;

const _borderColor = Color(0xFF1A1C1C);
const _subLabelColor = Color(0xFF9EA3AD);

class LateReportPage extends StatefulWidget {
  final String reportId;
  final String eventId;
  final String? groupName;
  final String? eventTitle;

  const LateReportPage({
    super.key,
    required this.reportId,
    required this.eventId,
    this.groupName,
    this.eventTitle,
  });

  @override
  State<LateReportPage> createState() => _LateReportPageState();
}

class _LateReportPageState extends State<LateReportPage> {
  late final LateReportViewModel _viewModel;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = LateReportViewModel(
      reportId: widget.reportId,
      eventId: widget.eventId,
    );
    _reasonController.addListener(() {
      _viewModel.setReason(_reasonController.text);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final success = await _viewModel.submitReport();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('遅刻報告を保存・送信しました！', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted && _viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return CommonLayout(
          body: Container(
            color: const Color(0xFFF8F7F7),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GroupEventRow(
                    groupName: widget.groupName,
                    eventTitle: widget.eventTitle,
                  ),
                  const SizedBox(height: 12),
                  const _PostTypeStatusRow(),
                  const SizedBox(height: 16),
                  const _SectionLabel(label: 'PHOTO', subLabel: '遅刻者用写真'),
                  const SizedBox(height: 6),
                  _PhotoUploadBox(viewModel: _viewModel),
                  const SizedBox(height: 18),
                  const _SectionLabel(label: 'LATE REASON', subLabel: '遅刻理由'),
                  const SizedBox(height: 6),
                  _ReasonInputBox(controller: _reasonController, viewModel: _viewModel),
                  const SizedBox(height: 18),
                  const _SectionLabel(label: 'CURRENT LOCATION', subLabel: '遅刻時の現在地'),
                  const SizedBox(height: 6),
                  _LocationBox(locationName: _viewModel.locationName),
                  const SizedBox(height: 18),
                  const _SectionLabel(label: 'TIMELINE', subLabel: '自動入力'),
                  const SizedBox(height: 6),
                  _TimelineRow(
                    arrivalEstimate: _viewModel.arrivalEstimate,
                    onArrivalEstimateChanged: _viewModel.setArrivalEstimate,
                  ),
                  const SizedBox(height: 18),
                  _PostButton(
                    isUploading: _viewModel.isUploading,
                    onTap: _viewModel.isUploading ? null : _onSubmit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GroupEventRow extends StatelessWidget {
  final String? groupName;
  final String? eventTitle;

  const _GroupEventRow({this.groupName, this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: GroupNameDropdown(
            title: groupName ?? 'GROUP NAME',
            width: null,
            height: 50,
            borderWidth: 3,
            uppercase: true,
            fontSize: 12,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: EventNameDropdown(
            title: eventTitle ?? 'EVENT NAME',
          ),
        ),
      ],
    );
  }
}

class _PostTypeStatusRow extends StatelessWidget {
  const _PostTypeStatusRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _borderColor, width: 3),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LATE REPORT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _borderColor, letterSpacing: 0.6)),
                Icon(Icons.keyboard_arrow_down, color: _borderColor, size: 20),
              ],
            ),
          ),
        ),
        Container(
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFFACC14),
            border: Border(
              top: BorderSide(color: _borderColor, width: 3),
              right: BorderSide(color: _borderColor, width: 3),
              bottom: BorderSide(color: _borderColor, width: 3),
            ),
            borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
          ),
          child: const Text('5: LATE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _borderColor)),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String subLabel;

  const _SectionLabel({required this.label, required this.subLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSub, letterSpacing: 1)),
        const SizedBox(width: 6),
        Text(subLabel, style: const TextStyle(fontSize: 10, color: _subLabelColor)),
      ],
    );
  }
}

class _PhotoUploadBox extends StatelessWidget {
  final LateReportViewModel viewModel;

  const _PhotoUploadBox({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = viewModel.evidencePhoto != null;

    return GestureDetector(
      onTap: viewModel.isUploading ? null : viewModel.capturePhoto,
      child: _DashedBorderBox(
        height: 170,
        child: hasPhoto
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: kIsWeb
                        ? Image.network(viewModel.evidencePhoto!.path, fit: BoxFit.cover)
                        : Image.file(File(viewModel.evidencePhoto!.path), fit: BoxFit.cover),
                  ),
                  if (viewModel.isUploading)
                    Container(
                      color: const Color(0x80000000),
                      child: const Center(child: CircularProgressIndicator(color: AppColors.orange)),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD9),
                      border: Border.all(color: _borderColor, width: 3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text('+', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _borderColor)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('写真を追加', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _borderColor)),
                  const SizedBox(height: 4),
                  const Text('タップして撮影 / 選択', style: TextStyle(fontSize: 11, color: AppColors.textSub)),
                ],
              ),
      ),
    );
  }
}

class _DashedBorderBox extends StatelessWidget {
  final double height;
  final Widget child;

  const _DashedBorderBox({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    final path = Path()..addRRect(rrect);
    final dashPath = Path();
    const dashWidth = 8.0;
    const dashGap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashPath.addPath(metric.extractPath(distance, next.clamp(0, metric.length)), Offset.zero);
        distance = next + dashGap;
      }
    }
    canvas.drawPath(
      dashPath,
      Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReasonInputBox extends StatelessWidget {
  final TextEditingController controller;
  final LateReportViewModel viewModel;

  const _ReasonInputBox({required this.controller, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !viewModel.isUploading,
              maxLines: null,
              maxLength: 200,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              style: const TextStyle(fontSize: 14, color: _borderColor),
              decoration: const InputDecoration(
                hintText: '遅刻した理由を入力してください',
                hintStyle: TextStyle(fontSize: 14, color: _subLabelColor),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) => Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${controller.text.length} / 200',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _subLabelColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationBox extends StatelessWidget {
  final String locationName;

  const _LocationBox({required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.only(left: 14, right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              locationName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _borderColor),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E2E2),
              border: Border.all(color: _borderColor, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('GPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _borderColor)),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimeOfDay? arrivalEstimate;
  final ValueChanged<TimeOfDay> onArrivalEstimateChanged;

  const _TimelineRow({required this.arrivalEstimate, required this.onArrivalEstimateChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        const _TimelineItem(label: '出発実績', value: '--:--'),
        _TimelineEditableItem(
          label: '到着予定',
          value: arrivalEstimate,
          onChanged: onArrivalEstimateChanged,
        ),
        const _TimelineItem(label: '到着実績', value: '--:--'),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String value;

  const _TimelineItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 173,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSub)),
          const SizedBox(height: 4),
          Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E2E2),
              border: Border.all(color: _borderColor, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _borderColor)),
          ),
        ],
      ),
    );
  }
}

class _TimelineEditableItem extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;

  const _TimelineEditableItem({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 173,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSub)),
          const SizedBox(height: 4),
          TimeInputBox(
            value: value,
            onChanged: onChanged,
            pickerLabel: 'ARRIVAL',
            pickerTitle: '到着予定を設定',
            height: 40,
            backgroundColor: const Color(0xFFE2E2E2),
            borderColor: _borderColor,
            borderWidth: 3,
          ),
        ],
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  final bool isUploading;
  final VoidCallback? onTap;

  const _PostButton({required this.isUploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isUploading ? const Color(0xFFE2E2E2) : AppColors.orange,
          border: Border.all(color: _borderColor, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('投稿する', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _borderColor)),
            const SizedBox(width: 10),
            isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _borderColor),
                  )
                : const Icon(Icons.chevron_right, color: _borderColor, size: 22),
          ],
        ),
      ),
    );
  }
}
