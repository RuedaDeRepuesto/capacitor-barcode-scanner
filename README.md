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

| Plugin Version | Capacitor Version |
|----------------|-------------------|
| 0.0.2          | Capacitor 3       |
| 1.0.1          | Capacitor 5       |
| 2.0.0          | Capacitor 5       |
| 2.1.1          | Capacitor 5       |
| 2.1.2          | Capacitor 5       |
| 2.2.0          | Capacitor 5       |
| 2.3.0          | Capacitor 6       |
| 2.3.1          | Capacitor 6       |
| 2.3.3          | Capacitor 6       |


### Changelog
version 1.0.1 updated for capacitor 5
version 2.1.2 updated MLKit version in android
version 2.3.0 capacitor 6 support
version 2.3.3 Fix Android ladybug build

#### iOS
In XCode -> App info.plist add key NSCameraUsageDescription

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
