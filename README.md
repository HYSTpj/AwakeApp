<div align="center">

# HYST (ハイスト)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=flat&logo=supabase&logoColor=white)](https://supabase.com)
[![Provider](https://img.shields.io/badge/State-Provider-02569B?style=flat&logo=flutter&logoColor=white)](https://pub.dev/packages/provider)

</div>

<br>

> "7時に駅集合"と決めたのに、
> 当日LINEで「今起きた」「あと10分」が飛び交う。
> 誰が起きていて、誰が向かっているのか分からないまま、
> 結局みんなが遅刻する。
>
> 待ち合わせの"寝坊"と"遅刻"を、
> グループで可視化して解決するアプリが"HYST"です。

<br>

## 目次
- [🛏 課題](#-課題)
- [📱 アプリ概要](#-アプリ概要)
- [✨ 主な機能](#-主な機能)
- [🛠 技術スタック](#-技術スタック)
- [🚀 セットアップ](#-セットアップ)
- [📖 使用方法](#-使用方法)
- [📂 ディレクトリ構造](#-ディレクトリ構造)

<br>

## 🛏 課題

友人同士やサークルで朝早くの待ち合わせをする際、

- 誰が起きているのか／出発したのかが分からない
- 寝坊や遅刻の連絡がLINEなどに流れて埋もれる
- 現地に着いたかどうかを確認する手段がない
- 毎回「誰が一番遅刻したか」で揉める

といった課題があります。個人の目覚ましだけでは「グループで時間に集まる」という問題は解決できません。

<br>

## 📱 アプリ概要

HYSTは、グループでの朝の待ち合わせ（起床・集合）に特化した進行管理アプリです。

1. **グループを作る** — 招待コードでメンバーを集める
2. **イベントを作る** — 集合場所と到着時刻を決め、起床・出発アラームを設定する
3. **アラームが鳴る** — 設定時刻に起床・出発を通知し、スマホ側で止めるとステータスが自動でメンバー全員に共有される
4. **チェックインする** — QRコード or GPSで現地到着を報告する
5. **結果を見る** — 遅刻報告とランキングでその日の進行を振り返る

管理者（admin）がイベントを作成・管理し、メンバーは起床〜到着までのステータスをリアルタイムで共有し合う、というのが基本的な流れです。

<br>

## ✨ 主な機能

| 機能 | 説明 |
| --- | --- |
| 👥 **グループ管理** | 招待コードでのグループ作成・参加・メンバー管理。 |
| 📅 **イベント作成・スケジュール設定** | 集合場所（目的地）・到着時刻・起床／出発アラーム時刻を設定。 |
| ⏰ **起床・出発アラーム** | 設定時刻に鳴動し、徐々に強くなるカスタムバイブレーションで起床を促す。停止操作がそのままステータス報告になる。 |
| 📍 **チェックイン（QR / GPS）** | QRコード読み取りまたは位置情報で現地到着を確認・報告。 |
| 🐢 **遅刻報告・ランキング** | 遅刻理由の報告と、イベントごとの遅刻ランキング表示。 |
| 🔄 **リアルタイム状態共有** | メンバーのステータス変化やイベント完了をリアルタイムに反映（ポーリングなし）。 |

<br>

## 🛠 技術スタック

| カテゴリ | 採用技術 |
| --- | --- |
| 言語 / フレームワーク | Dart / Flutter |
| 状態管理 | Provider（`ChangeNotifier`ベースのViewModel） |
| アーキテクチャ | View / ViewModel / Repository の3層構成 |
| バックエンド | Supabase（Auth, Database, Realtime, RPC） |
| 位置情報 | geolocator, geocoding, google_maps_flutter |
| QRコード | qr_flutter（生成）, mobile_scanner（読み取り） |
| アラーム / 振動 | alarm, vibration |
| ローカルDB（現状未使用） | drift（SQLite） |
| テスト | flutter_test, mocktail |

<br>

## 🚀 セットアップ

### 1. リポジトリをクローンする

```bash
git clone https://github.com/HYSTpj/AwakeApp.git
cd AwakeApp
```

### 2. パッケージのインストール

```bash
flutter pub get
```

### 3. 環境変数の設定

このアプリはSupabaseをバックエンドに利用しています。`env/env.example.json` を参考に、Supabaseプロジェクトの `URL` と `ANON_KEY` を用意してください。

```json
{
    "SUPABASE_URL": "https://your-project.supabase.co",
    "SUPABASE_ANON_KEY": "your-anon-key-here"
}
```

### 4. アプリの実行

`--dart-define` でSupabaseの接続情報を渡して起動します。

```bash
flutter run \
  --dart-define=SUPABASE_URL=your-supabase-url \
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key
```

※ リポジトリ層をモックするユニットテスト（`flutter test`）は、Supabaseへの接続なしで実行できます。

<br>

## 📖 使用方法

1. **ログイン / アカウント作成**
    - メールアドレスでサインアップし、プロフィール（名前・アイコン）を作成。
2. **グループ作成 / 参加**
    - グループを新規作成するか、招待コードを入力して既存グループに参加。
3. **イベント作成（管理者）**
    - 集合場所・到着時刻を設定し、参加メンバーを選択してイベントを作成。起床・出発アラームの時刻もここで設定。
4. **アラーム対応（メンバー）**
    - 設定時刻にアラームが鳴動。停止するとステータス（起床／出発）がグループに共有される。
5. **チェックイン**
    - 現地に着いたらQRコードを読み取る、またはGPSで到着を報告。
6. **結果確認**
    - 遅刻した場合は理由を報告。イベント終了後はランキング画面でその日の結果を確認。

<br>

## 📂 ディレクトリ構造

```text
lib/
├── config/                    # 環境変数の読み込み（Supabase URL/Key）
├── models/                    # データクラス (Group, Event, Profile, EventReport, RankingUser)
├── data/
│   ├── repositories/          # Repositoryインターフェース + Supabase実装
│   └── database/              # Drift(SQLite) 定義（現状未使用）
├── presentation/
│   ├── viewmodels/            # 画面・操作ごとのChangeNotifier
│   └── views/                 # 画面Widget（feature別）
│       ├── event/
│       │   ├── admin/         # イベント作成・参加者選択・QR発行など（管理者向け）
│       │   ├── checkin/       # QR/GPSチェックイン・遅刻報告
│       │   └── schedule/      # アラーム時刻設定
│       ├── group/             # グループ作成・参加・管理
│       ├── login/             # ログイン・サインアップ・プロフィール作成
│       └── ranking/           # 遅刻ランキング
├── services/                  # アラーム・バイブレーションのプラットフォームラッパー
├── style/                     # テーマ・配色など
├── utils/                     # 共通ユーティリティ
└── widgets/                   # 共通Widget

supabase/
└── migrations/                # Postgresスキーマ・RLSポリシー・RPC関数

test/
├── presentation/viewmodels/   # ViewModel単体テスト
└── data/repositories/         # Repository/RPC関連のテスト
```
