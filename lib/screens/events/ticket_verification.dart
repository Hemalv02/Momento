import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TicketVerificationScreen extends StatefulWidget {
  final String qrResult; // The scanned QR result

  const TicketVerificationScreen({super.key, required this.qrResult});

  @override
  State<TicketVerificationScreen> createState() =>
      _TicketVerificationScreenState();
}

class _TicketVerificationScreenState extends State<TicketVerificationScreen> {
  final String expectedCode = "1234"; // Predefined valid ticket code
  static final Set<String> scannedTickets =
      {}; // Tracks already scanned tickets

  bool isVerified = false;
  bool isAlreadyScanned = false;

  @override
  void initState() {
    super.initState();
    _verifyTicket();
  }

  void _verifyTicket() {
    final String result = widget.qrResult;

    // Check if the ticket is valid
    if (result == expectedCode) {
      // Check if it has already been scanned
      if (scannedTickets.contains(result)) {
        setState(() {
          isAlreadyScanned = true;
        });
      } else {
        // Add to scanned tickets
        scannedTickets.add(result);
        setState(() {
          isVerified = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ticket Verification'),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Green, Red, or Yellow Tick
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAlreadyScanned
                    ? Colors.orange
                    : isVerified
                        ? Colors.green
                        : Colors.red,
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(
                isAlreadyScanned
                    ? Icons.warning
                    : isVerified
                        ? Icons.check_circle
                        : Icons.cancel,
                size: 80,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h),
            // Title
            Text(
              isAlreadyScanned
                  ? "Ticket Already Scanned"
                  : isVerified
                      ? "Ticket Verified"
                      : "Verification Failed",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            // Message
            Text(
              isAlreadyScanned
                  ? "This ticket has already been scanned."
                  : isVerified
                      ? "Congratulations! Your ticket has been verified."
                      : "Sorry! This ticket is invalid.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30.h),
            // Button to go back
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'reset');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAlreadyScanned
                    ? Colors.orange
                    : isVerified
                        ? Colors.green
                        : Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Back to Scan",
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
