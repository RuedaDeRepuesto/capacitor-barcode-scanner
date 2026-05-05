# capacitor-barcode-scanner

Simple Barcode scanner for capacitor, shows popup camera view to scan.
Supports code 128 and QR
Uses Google MLKit in android, and AVFoundation on iOS


## Install

```bash
npm i capacitor-barcode-scanner
npx cap sync
```

### Capacitor Compatibility

| Plugin Version | Capacitor Version   |
|----------------|---------------------|
| 0.0.2          | Capacitor 3         |
| 1.0.1          | Capacitor 5         |
| 2.0.0          | Capacitor 5         |
| 2.1.1          | Capacitor 5         |
| 2.1.2          | Capacitor 5         |
| 2.2.0          | Capacitor 5         |
| 2.3.*          | Capacitor 6         |
| 2.4.0          | Capacitor 6-7       |
| 2.5.0          | Capacitor 6-7       |
| 8.0.0          | Capacitor 8         |


### Changelog
- Version 1.0.1: Updated for Capacitor 5
- Version 2.1.2: Updated MLKit version in Android
- Version 2.3.0: Capacitor 6 support
- Version 2.3.1: Experimental JsQR reading in web
- Version 2.3.3: Fix Android ladybug build
- Version 2.3.4: Fix when QR Format is unknown app crashes
- Version 2.4.0: Capacitor 7 install support
- Version 2.5.0: MLKit updated to v17.3.0
- Version 8.0.0: Capacitor 8 support — versioning aligned to Capacitor major. Android: minSdk 24, compileSdk/targetSdk 36, AGP 8.13, Gradle 8.14.3, Kotlin 2.0.21, CameraX 1.6.0, lifecycle 2.8.7, core-ktx 1.15.0, dropped jcenter(). iOS: minimum deployment target bumped to 15.0, migrated to Swift Package Manager (SPM), removed Obj-C bridge macros, conforming to CAPBridgedPlugin.

#### iOS
In XCode → App info.plist add key `NSCameraUsageDescription`

This plugin requires **Swift Package Manager (SPM)**, the default in Capacitor 8. Run `npx cap sync` after installing.

#### Web implementation on 2.3.1

On versión 2.3.1+ the web versión will call an input image for QR Only detection using JSQR, this feature is experimental and for debuging purposes

## API



<docgen-index>

* [`scan()`](#scan)
* [`multiScan(...)`](#multiscan)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### scan()

```typescript
scan() => Promise<ScanResult>
```

Start scan screen
This promise will fail if permission for camera is denied

**Returns:** <code>Promise&lt;<a href="#scanresult">ScanResult</a>&gt;</code>

--------------------


### multiScan(...)

```typescript
multiScan(opts?: MultiScanOptions | undefined) => Promise<MultiScanResult>
```

Start scan screen
the difference vs scan is this will not close automatically, and continues scannning multiple codes
! Added in v1.1.1

| Param      | Type                                                          |
| ---------- | ------------------------------------------------------------- |
| **`opts`** | <code><a href="#multiscanoptions">MultiScanOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#multiscanresult">MultiScanResult</a>&gt;</code>

--------------------


### Interfaces


#### ScanResult

Represents a Scan Result

| Prop         | Type                 | Description                                   |
| ------------ | -------------------- | --------------------------------------------- |
| **`result`** | <code>boolean</code> | sucess status, its true when scanner got code |
| **`code`**   | <code>string</code>  | scanned code                                  |


#### MultiScanResult

Represents a Multiple scan result

| Prop         | Type                  |
| ------------ | --------------------- |
| **`result`** | <code>boolean</code>  |
| **`count`**  | <code>number</code>   |
| **`codes`**  | <code>string[]</code> |


#### MultiScanOptions

| Prop           | Type                | Description                                                                                                                                    |
| -------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **`maxScans`** | <code>number</code> | Max quantity of codes to scan, when reached the amount activity or viewcontroller will close and return the scanned codes, it defaults to 9999 |

</docgen-api>
