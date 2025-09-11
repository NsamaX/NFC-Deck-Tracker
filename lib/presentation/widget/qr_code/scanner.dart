import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../bloc/record/bloc.dart';
import '../../locale/localization.dart';

class QRCodeScanner extends StatefulWidget {
  final RecordBloc recordBloc;

  QRCodeScanner({
    super.key,
    required this.recordBloc,
  });

  @override
  State<QRCodeScanner> createState() => _JoinRoomScannerPageState();
}

class _JoinRoomScannerPageState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? result;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      controller.scannedDataStream.listen((scanData) {
        setState(() {
          result = scanData.code;
        });
        if (result != null) {
          widget.recordBloc.add(ImportRecordEvent(userId: result!));
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 10,
              borderLength: 20,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          Positioned(
            top: 10.0,
            left: 16.0,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 40.0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                locale.translate('page_scsanner.tip'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
