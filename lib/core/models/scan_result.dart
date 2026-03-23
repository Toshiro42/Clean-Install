class ScanResult {
  final int malicious;
  final int suspicious;
  final int harmless;
  final int undetected;

  ScanResult({
    required this.malicious,
    required this.suspicious,
    required this.harmless,
    required this.undetected,
  });
}
