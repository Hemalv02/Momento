import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:momento/screens/events/ticket_verification.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _flashOn = false;
  Barcode? _lastScannedCode;

  void _toggleFlash() {
    _flashOn = !_flashOn;
    _controller.toggleTorch();
    setState(() {});
  }

  // In QRScannerPage
  void _manualScan() {
    if (_lastScannedCode != null && _lastScannedCode!.rawValue != null) {
      final String qrResult = _lastScannedCode!.rawValue!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketVerificationScreen(qrResult: qrResult),
        ),
      ).then((result) {
        if (result == 'reset') {
          setState(() {
            _lastScannedCode = null; // Reset QR result
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code detected!')),
      );
    }
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
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              setState(() {
                _lastScannedCode =
                    capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
              });
            },
            scanWindow: const Rect.fromLTWH(
                50, 200, 300, 300), // Define the restricted scan area
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 220.h,
              width: 220.h,
              margin: const EdgeInsets.only(top: 200),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF003675), width: 2),
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
                    shape: const CircleBorder(
                      side: BorderSide(color: Color(0xFF003675), width: 2),
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
    );
  }
}
