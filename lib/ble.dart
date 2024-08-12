import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // listen to scan results
// Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
//  `scanResults` if you want live scan results *or* the results from a previous scan.
  var subscription = FlutterBluePlus.onScanResults.listen(
    (results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device
        print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
      }
    },
    onError: (e) => print(e),
  );

// cleanup: cancel subscription when scanning stops
  FlutterBluePlus.cancelWhenScanComplete(subscription);

// Wait for Bluetooth enabled & permission granted
// In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;

// Start scanning w/ timeout
// Optional: use `stopScan()` as an alternative to timeout
  await FlutterBluePlus.startScan(
      withServices: [
        Guid("b572a6e7-6b0d-4963-9fb8-43a38a18013b")
      ], // match any of the specified services
      // *or* any of the specified names
      timeout: Duration(seconds: 15));

// wait for scanning to stop
  await FlutterBluePlus.isScanning.where((val) => val == false).first;
}
