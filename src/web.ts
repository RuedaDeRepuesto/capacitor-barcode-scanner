import { WebPlugin } from '@capacitor/core';

import type { BarcodeScannerPlugin, MultiScanOptions, MultiScanResult, ScanResult } from './definitions';

import * as _jsQR from './jsqr.js';

const jsQR = (_jsQR as any).default || _jsQR;

export class BarcodeScannerWeb extends WebPlugin implements BarcodeScannerPlugin {


  async multiScan(opts:MultiScanOptions): Promise<MultiScanResult> {


    const scans = await this.readInternal(opts.maxScans);

    if(scans.length > 0){
      return {result:true,codes:scans,count:scans.length};
    }else{
      return {result:false,count:0,codes:[]};
    }

  }


  async scan():Promise<ScanResult>{

    const scans = await this.readInternal();

    if(scans.length > 0){
      return {result:true,code:scans[0]};
    }else{
      return {result:false};
    }

  }


  private async readInternal(reads = 1){
    const fInput = document.createElement('input');
    fInput.type = 'file';
    fInput.accept = 'image/*';
    if(reads > 1){
      fInput.multiple = true;
    }
    fInput.style.display = 'none';

    document.body.appendChild(fInput);

    const promise = new Promise<string[]>((resolve)=>{
      fInput.addEventListener('change', async () => {
        try {
          if (fInput.files && fInput.files.length > 0) {

            const scans:string[]= [];
            const min = Math.min(fInput.files.length,reads);
            for (let i = 0; i < min; i++) {
              const img = fInput.files[i];
              const imgData = await this.blobToImageData(img);    
              const code = jsQR(imgData.data, imgData.width, imgData.height);
              //console.log(code);
              if(code && code.data){
                scans.push(code.data);
              }else{
                console.error('jsQR return null',code);
              }
            }
            
            resolve(scans);
          } else {
            resolve([])
          }
        } catch (error) {
          console.error(error);
        }
        document.body.removeChild(fInput);
      });
    });

    fInput.click();
    return promise;
  }

  private async blobToImageData(blob: Blob, maxWidth = 1500, maxHeight = 1500): Promise<ImageData> {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.readAsDataURL(blob);

        reader.onloadend = () => {
            const image = new Image();
            image.src = reader.result as string;

            image.onload = () => {
                const scale = Math.min(maxWidth / image.width, maxHeight / image.height, 1); 

                const canvas = document.createElement('canvas');
                canvas.width = image.width * scale;
                canvas.height = image.height * scale;

                const ctx = canvas.getContext('2d')!;
                ctx.drawImage(image, 0, 0, canvas.width, canvas.height);

                const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);

                // Libera la memoria de la imagen y del canvas
                canvas.width = 0;
                canvas.height = 0;

                resolve(imageData);
            };

            image.onerror = (e) => reject(new Error("Error al cargar la imagen."+e));
        };

        reader.onerror = (e) => reject(new Error("Error al leer el blob."+e));
    });
}
}
