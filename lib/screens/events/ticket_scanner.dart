import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _flashOn = false;
  Barcode? _lastScannedCode;
  String? selectedFeature;

  final List<Map<String, dynamic>> ticketFeatures = [
    {
      'name': 'Entry',
      'icon': Icons.door_front_door_outlined,
    },
    {
      'name': 'Breakfast',
      'icon': Icons.free_breakfast_outlined,
    },
    {
      'name': 'Lunch',
      'icon': Icons.lunch_dining_outlined,
    },
    {
      'name': 'Dinner',
      'icon': Icons.dinner_dining_outlined,
    },
    {
      'name': 'Gift',
      'icon': Icons.card_giftcard_outlined,
    },
    {
      'name': 'T-Shirt',
      'icon': Icons.checkroom_outlined,
    },
    {
      'name': 'Snack',
      'icon': Icons.fastfood_outlined,
    },
  ];

  void _toggleFlash() {
    _flashOn = !_flashOn;
    _controller.toggleTorch();
    setState(() {});
  }

  void _manualScan() {
    if (selectedFeature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a feature first!')),
      );
      return;
    }

    if (_lastScannedCode != null && _lastScannedCode!.rawValue != null) {
      final String qrResult = _lastScannedCode!.rawValue!;
      _verifyTicket(qrResult);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code detected!')),
      );
    }
  }

  void _verifyTicket(String qrResult) {
    // Pause camera while verifying
    _controller.stop();

    // Show verification dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.pending_outlined,
          color: Color(0xFF003675),
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF003675),
            ),
            const SizedBox(height: 16),
            Text(
              'Verifying $selectedFeature access...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    // Simulate verification (replace with actual verification logic)
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close verification dialog

      // Show result dialog
      showResultDialog(true, 'Ticket validated successfully!');
    });
  }

  void showResultDialog(bool success, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? Colors.green : Colors.red,
          size: 48,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Feature: $selectedFeature',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF003675),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _lastScannedCode = null;
              });
              _controller.start(); // Resume camera
            },
            child: const Text('Scan Next'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Scanner'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Feature to Scan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003675),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ticketFeatures.length,
                    itemBuilder: (context, index) {
                      final feature = ticketFeatures[index];
                      final isSelected = selectedFeature == feature['name'];

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedFeature = feature['name'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF003675)
                                  : const Color(0xFF003675).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  feature['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF003675),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  feature['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF003675),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    setState(() {
                      _lastScannedCode = capture.barcodes.isNotEmpty
                          ? capture.barcodes.first
                          : null;
                    });
                  },
                  scanWindow: const Rect.fromLTWH(50, 200, 300, 300),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 220.h,
                    width: 220.h,
                    margin: const EdgeInsets.only(top: 200),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFF003675), width: 2.w),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            _flashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleFlash,
                        ),
                        FloatingActionButton(
                          onPressed: _manualScan,
                          backgroundColor: Colors.white,
                          shape: CircleBorder(
                            side: BorderSide(
                                color: const Color(0xFF003675), width: 2.w),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF003675),
                            size: 30,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_front,
                              color: Colors.white, size: 30),
                          onPressed: () => _controller.switchCamera(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
