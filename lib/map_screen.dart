import 'package:flutter/material.dart';

// Google Mapを利用するためのパッケージ
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// 緯度経度を取得するためのパッケージ
import 'package:geocoding/geocoding.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;

  // 地図の初期位置
  final LatLng center = const LatLng(35.4053, 139.4558);

  // 現在地を保持する変数
  Position? position;

  // 空のマーカー用リスト作成
  // Setはリストと違い，重複しない
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // 位置情報の許可を求める
    _determinePosition();
  }

  // 位置情報の権限確認と取得をセットで行うメソッド
  Future<void>_determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 位置情報サービスが有効かチェック
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('位置情報サービスが無効です');
      return;
    }

    // 権限の確認
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('位置情報の権限が拒否されました');
        return;
      }
    }

    // 位置情報の取得
    Position positionData = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    
    setState(() {
      position = positionData;
    });

    // 現在地にカメラ移動
    mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(positionData.latitude, positionData.longitude),
      ),
    );
  }

  // 住所から場所を特定して移動する関数
  Future<void> _searchAndMove(String address) async {
    try {
      // 住所を座標リストに変換
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        // リストの第一候補を取り出す
        Location loc = locations.first;
        LatLng target = LatLng(loc.latitude, loc.longitude);

        // マーカーを作成して地図置き換えてセット
        setState(() {
          _markers = {
            Marker(
              // マーカーに名前をつける
              markerId: const MarkerId('destination'),
              // マーカー場所指定
              position : target,
              // マーカータップで名称表示
              infoWindow: InfoWindow(title: address),
            ),
          };
        });

        // カメラをスムーズに移動
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(target, 15.0),
        );
      }
    } catch (e) {
      // 見つからなかった場合
      print("見つかりません： $e");
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('集合場所を選択'),
        elevation: 2,
      ),
      // Stackによって地図の上に検索窓を重ねる
      body: Stack(
        children: [
          // 地図
          GoogleMap(
            onMapCreated: onMapCreated,
            // カメラ設定
            initialCameraPosition: CameraPosition(
              target: center,
              zoom: 11.0,
            ),

            // 現在地に青い点が出る
            myLocationEnabled: true,

            // 右上に現在地に戻るボタン（検索窓と重なってしまうためオフ）
            myLocationButtonEnabled: false,

            // マーカー表示
            markers: _markers,
          ),

          // 検索窓
          // Positionedで表示場所指定
          Positioned(
            // 余白
            top: 10,
            left: 15,
            right: 15,
            // 箱作成
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                // 背景色
                color: Colors.white,
                // 角を丸く
                borderRadius: BorderRadius.circular(10),
                // 影追加
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))
                ],
              ),
              child: TextField(
                decoration: const InputDecoration(
                  // うっすら文字
                  hintText: 'ここで検索',
                  border: InputBorder.none,
                  // 余白
                  contentPadding: EdgeInsets.only(left: 15, top: 15),
                  // 検索アイコン
                  suffixIcon: Icon(Icons.search),
                ),
                // 文字を打ち込み改行したら実行される
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchAndMove(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),

      // 場所決定ボタン
      // 浮いている少し横長のボタン
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          if (_markers.isNotEmpty) {
            // マーカーがある時
            // 検索窓に入力された地名を取得
            final destinationName = _markers.first.infoWindow.title ?? "不明な場所";
            // 座標を取り出す
            final location = _markers.first.position;

            // データ保持
            Navigator.pop(context, {
              'destination_name': destinationName,
              'location': location,
            });
          } else {
            // マーカーがない時
            // スナックバー
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('まずは目的地を検索してピンを立ててください')),
            );
          }
        },
        label: const Text(
          'この場所に決定', style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.check_circle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // 中央配置
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
