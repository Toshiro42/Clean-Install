# Clean-Install

"Clean Install” is an Android app which lists user-installed apps, lets you scan them on VirusTotal via sending SHA-256 hashes of the app, and helps you uninstall
safely. We managed asynchronous operations for API communication, also followed Android’s lifecycle and permission model, and focused on Security by using only hash-
based checks — Not uploading any files.

Features

App Management:

Lists all user-installed applications on the device.
Displays app details including name, package, and icon.
Allows searching and filtering installed apps.

Scanning (VirusTotal):

Generates SHA-256 hash of the selected app.
Sends the hash to VirusTotal API for analysis.
Displays scan results such as malicious, suspicious, harmless, and undetected.
Performs scanning without uploading APK files.

Uninstall:

Uses Android’s native uninstall prompt.
Ensures apps are only removed through the official system flow.
Shows cleanup report only after successful uninstall.

Privacy & Security:

No APK files are uploaded.
Only hash-based scanning is used.
No background tracking or data collection.
Follows Android permission and security model.

Requirements

Flutter SDK (3.x or above)
Android SDK
Java / Kotlin support
VirusTotal API Key

Installation

Run the following commands:

--> git clone https://github.com/your-username/clean-install.git

--> cd clean-install
--> flutter pub get

Create a .env file and add:

--> API_KEY=your_virustotal_api_key

Usage

Run the app:

--> flutter run

Controls:

Select an app from the list to view details.

Tap the scan button to analyze the app using VirusTotal.

Tap the uninstall button to remove the app using Android’s system prompt.

Troubleshooting

If apps are not listed, ensure required permissions are granted.

If scanning fails, verify your API key and internet connection.

If uninstall does not trigger, test on a real device instead of an emulator.

Ensure proper device compatibility and Android version support.

License

This project is open-source and can be modified or distributed freely.

Author

Developed by SUYASH YOGI
