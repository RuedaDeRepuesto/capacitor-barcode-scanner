import { WebPlugin } from '@capacitor/core';
import type { BarcodeScannerPlugin, MultiScanOptions, MultiScanResult, ScanResult } from './definitions';
export declare class BarcodeScannerWeb extends WebPlugin implements BarcodeScannerPlugin {
    multiScan(opts: MultiScanOptions): Promise<MultiScanResult>;
    scan(): Promise<ScanResult>;
    private readInternal;
    private blobToImageData;
}
