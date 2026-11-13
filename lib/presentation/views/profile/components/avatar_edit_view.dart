import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../style/app_color.dart';
import '../../../viewmodels/auth_view_model.dart';

class AvatarEditView extends StatefulWidget {
  final double size;

  const AvatarEditView({super.key, this.size = 110});

  @override
  State<AvatarEditView> createState() => _AvatarEditViewState();
}

class _AvatarEditViewState extends State<AvatarEditView> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.state.isLoading) return;

    final XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      // 画像ピッカーのプラットフォームエラーなど
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像の選択に失敗しました: ${e.message ?? '権限を確認してください'}')),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('画像の取得中に予期せぬエラーが発生しました')));
      return;
    }

    // ユーザーが選択をキャンセルした場合は何もせず終了
    if (!mounted || pickedFile == null) return;

    final file = File(pickedFile.path);
    final success = await authViewModel.updateAvatar(file);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('プロフィール画像を変更しました')));
    } else {
      final errorMsg = authViewModel.state.errorMessage ?? '画像の更新に失敗しました';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthViewModel>().state;
    final currentAvatarUrl = state.user?.avatarUrl;
    final isLoading = state.isLoading;

    final hasValidUrl = currentAvatarUrl != null && currentAvatarUrl.isNotEmpty;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: isLoading ? null : _pickAndUploadImage,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 3),
                  ),
                  child: ClipOval(
                    child: hasValidUrl
                        ? Image.network(
                            currentAvatarUrl,
                            fit: BoxFit.cover,
                            width: widget.size,
                            height: widget.size,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: widget.size * 0.6,
                              color: Colors.grey,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: widget.size * 0.6,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),
            ),

            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black38,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),

            Positioned(
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  padding: const EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
