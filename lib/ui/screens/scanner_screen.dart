import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pharos/core/services/scanner_service.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SKANUJ PRODUKT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  ScannerService.handleBarcode(context, barcode.rawValue!);
                  break; 
                }
              }
            },
          ),
          // Maska skanera (UX Enhancement)
          Container(
            decoration: ShapeDecoration(
              shape: _ScannerOverlayShape(
                borderColor: Colors.orange,
                borderRadius: 20,
                borderLength: 40,
                borderWidth: 8,
                cutOutSize: 250,
              ),
            ),
          ),
          const Positioned(
            bottom: 100,
            left: 0, right: 0,
            child: Text(
              'Umieść kod kreskowy w ramce',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const _ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? direction}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? direction}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? direction}) {
    final width = rect.width;
    final height = rect.height;
    final boxRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(boxRect, Radius.circular(borderRadius))),
      ),
      backgroundPaint,
    );

    // Rysowanie rogów ramki
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, Radius.circular(borderRadius)), borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
