# Clean Install

A Flutter + Android security utility that lists your installed apps, scans them against the [VirusTotal](https://www.virustotal.com) database using SHA-256 hashes, and helps you uninstall them safely.

> **Privacy-first:** Only the APK's SHA-256 hash is sent to VirusTotal — no files, no personal data, no uploads.

---

## Features

- **App list** — Shows all user-installed apps (system apps excluded) with icons, names, and package IDs. Supports live search by name or package name.
- **VirusTotal scan** — Computes the SHA-256 hash of the APK natively on-device and queries the VirusTotal v3 API. Results are classified as Clean, Suspicious, or Dangerous with a visual verdict banner and per-engine breakdown.
- **Safe uninstall** — Triggers Android's built-in uninstall flow and detects the result via lifecycle observation. On success, displays a Cleanup Report with APK, data, and OBB paths for any manual cleanup.
- **Pull-to-refresh** — Reload the app list at any time.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter (Dart), Material 3 Dark theme |
| Native bridge | Flutter MethodChannel → Java (`MainActivity.java`) |
| Hash computation | Java `MessageDigest` (SHA-256), streamed in 8 KB chunks |
| Threat intelligence | VirusTotal API v3 (`/files/{sha256}`) |
| Config | `flutter_dotenv` — API key loaded from `.env` at runtime |

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, dotenv init
├── core/
│   ├── models/
│   │   ├── app_info.dart              # App metadata + base64 icon decoding
│   │   └── scan_result.dart           # VirusTotal stats (malicious/suspicious/harmless/undetected)
│   └── services/
│       ├── native_app_service.dart    # MethodChannel calls to Android native layer
│       └── virus_total_service.dart   # VirusTotal REST client
└── features/
    ├── home/
    │   ├── home_screen.dart           # Main app list, search, uninstall lifecycle
    │   └── app_tile.dart              # Per-app row with Scan / Uninstall actions
    ├── scan_report/
    │   └── scan_report_screen.dart    # Verdict banner, score breakdown, VT deep link
    └── cleanup_report/
        └── cleanup_report_screen.dart # Post-uninstall path summary

android/app/src/main/java/com/cleaninstall/cleaninstall/
├── MainActivity.java                  # MethodChannel handler: getInstalledApps, getSha256, uninstallApp, isPackageInstalled
└── VirusScanReceiver.java
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Android device or emulator (API 21+)
- A [VirusTotal API key](https://www.virustotal.com/gui/join-us) (free tier works)

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/your-username/clean-install.git
   cd clean-install
   ```

2. **Add your API key**

   Create a `.env` file in the project root:
   ```env
   VIRUSTOTAL_API_KEY=your_api_key_here
   ```

   > The `.env` file is listed in `.gitignore` — do not commit your key.

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## How the Scan Works

1. The native Android layer (`MainActivity.java`) reads the APK file from its path on disk and computes its SHA-256 hash using `MessageDigest`, streaming the file in 8 KB chunks to avoid memory pressure.
2. The hash is sent to the VirusTotal `/api/v3/files/{sha256}` endpoint via a GET request — no file upload occurs.
3. The response's `last_analysis_stats` block is parsed into a `ScanResult` and displayed with per-category counts and progress bars.
4. If the file is not found in the VirusTotal database (HTTP 404), the app reports it as unknown rather than clean.

---

## Permissions

Declared in `AndroidManifest.xml`:

| Permission | Purpose |
|---|---|
| `QUERY_ALL_PACKAGES` | Enumerate installed user apps |
| `REQUEST_DELETE_PACKAGES` | Trigger the system uninstall dialog |
| `INTERNET` | VirusTotal API calls |

---

## Dependencies

```yaml
http: ^1.2.0           # HTTP client for VirusTotal API
flutter_dotenv: ^5.1.0 # .env file loading
url_launcher: ^6.2.5   # Open VirusTotal report in browser
```

---

## Notes

- **VirusTotal free tier** has a rate limit of 4 requests/minute. Scanning many apps in quick succession may result in API errors.
- **OBB and data directories** are listed in the Cleanup Report after uninstall for reference, but must be removed manually using a file manager — Android does not delete them automatically.
- This app is Android-only. The iOS and macOS targets in the repo are Flutter scaffolding and are not functional.
