/// アラームの経過時間に応じてバイブレーション強度を段階的に引き上げる。
///
/// [currentIntensity] が [max] 未満であれば [step] だけ強度を上げ、[step] から [max] の
/// 範囲にクランプする。[max] に達している場合はそのまま返す。
int nextVibrationIntensity(
  int currentIntensity, {
  int step = 50,
  int max = 255,
}) {
  if (currentIntensity >= max) {
    return currentIntensity;
  }
  return (currentIntensity + step).clamp(step, max);
}
