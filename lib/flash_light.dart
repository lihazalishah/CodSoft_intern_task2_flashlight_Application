// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, unused_field

import 'package:flashlight_app/utils/colors.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter/material.dart';

class FlashLight extends StatefulWidget {
  const FlashLight({super.key});

  @override
  State<FlashLight> createState() => _FlashLightState();
}

class _FlashLightState extends State<FlashLight> with WidgetsBindingObserver {
  late AppLifecycleState _appLifecycleState;

  bool _isFlashon = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });
    if (state == AppLifecycleState.paused) {
      TorchLight.disableTorch();
    } else if (state == AppLifecycleState.resumed) {
      if (_isFlashon == true) {
        TorchLight.enableTorch();
      } else {
        TorchLight.disableTorch();
      }
    } else if (state == AppLifecycleState.inactive) {
      TorchLight.disableTorch();
    } else if (state == AppLifecycleState.detached) {}
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flash Light',
          style: TextStyle(
              color: Appcolors.titleColor,
              fontSize: 40,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Appcolors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              minRadius: 30,
              maxRadius: 45,
              child: Transform.scale(
                // for size of icon
                scale: 2, //
                child: IconButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Appcolors.iconButtonColor)),
                  onPressed: () async {
                    if (await _isTorchAvailable(context)) {
                      toggleFlashLight();
                    } else {
                      _showMessage('no avaliable', context);
                    }
                  },
                  icon: Icon(
                    _isFlashon == true
                        ? Icons.flash_on_outlined
                        : Icons.flash_off_outlined,
                    color: _isFlashon == true
                        ? Appcolors.iconOnColor
                        : Appcolors.iconOffColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _isTorchAvailable(BuildContext context) async {
    try {
      return await TorchLight.isTorchAvailable();
    } on Exception catch (_) {
      _showMessage(
        'the device has no available torch',
        context,
      );
      rethrow;
    }
  }

  Future<void> toggleFlashLight() async {
    try {
      setState(() {
        _isFlashon = !_isFlashon;
      });
      if (_isFlashon) {
        await TorchLight.enableTorch();
        _showMessage('Flash on', context);
      } else {
        await TorchLight.disableTorch();
        _showMessage('Flash off', context);
      }
    } catch (e) {
      _showMessage('$e', context);
    }
  }

  void _showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
      ),
    ));
  }
}
