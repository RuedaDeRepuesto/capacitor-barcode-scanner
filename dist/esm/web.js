import { WebPlugin } from '@capacitor/core';
import * as _jsQR from './jsqr.js';
const jsQR = _jsQR.default || _jsQR;
export class BarcodeScannerWeb extends WebPlugin {
    async multiScan(opts) {
        const scans = await this.readInternal(opts.maxScans);
        if (scans.length > 0) {
            return { result: true, codes: scans, count: scans.length };
        }
        else {
            return { result: false, count: 0, codes: [] };
        }
    }
    async scan() {
        const scans = await this.readInternal();
        if (scans.length > 0) {
            return { result: true, code: scans[0] };
        }
        else {
            return { result: false };
        }
    }
    async readInternal(reads = 1) {
        const fInput = document.createElement('input');
        fInput.type = 'file';
        fInput.accept = '.png';
        if (reads > 1) {
            fInput.multiple = true;
        }
        const promise = new Promise((resolve) => {
            fInput.addEventListener('change', async () => {
                if (fInput.files && fInput.files.length > 0) {
                    const scans = [];
                    const min = Math.min(fInput.files.length, reads);
                    for (let i = 0; i < min; i++) {
                        const img = fInput.files[i];
                        const imgData = await this.blobToImageData(img);
                        const code = jsQR(imgData.data, imgData.width, imgData.height);
                        //console.log(code);
                        if (code && code.data) {
                            scans.push(code.data);
                        }
                    }
                    resolve(scans);
                }
                else {
                    return [];
                }
            });
        });
        fInput.click();
        return promise;
    }
    async blobToImageData(blob) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsDataURL(blob);
            reader.onloadend = () => {
                const image = new Image();
                image.src = reader.result;
                image.onload = () => {
                    const canvas = document.createElement('canvas');
                    canvas.width = image.width;
                    canvas.height = image.height;
                    const ctx = canvas.getContext('2d');
                    ctx.drawImage(image, 0, 0);
                    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
                    resolve(imageData);
                };
                image.onerror = reject;
            };
            reader.onerror = reject;
        });
    }
}
//# sourceMappingURL=web.js.map