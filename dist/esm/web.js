import { WebPlugin } from '@capacitor/core';
export class BarcodeScannerWeb extends WebPlugin {
    async multiScan() {
        let result = window.prompt('Leer', undefined);
        if (result) {
            return {
                result: true,
                count: result.split(',').length,
                codes: result.split(',')
            };
        }
        else {
            let codes = [];
            return { result: false, count: 0, codes: codes };
        }
    }
    async scan() {
        let result = window.prompt('Leer', undefined);
        if (result) {
            return { result: true, code: result };
        }
        else {
            return { result: false };
        }
    }
}
//# sourceMappingURL=web.js.map