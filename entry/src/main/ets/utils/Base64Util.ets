import util from '@ohos.util';

export class Base64Util {
  static encode(str: string): string {
    if (!str) return '';
    try {
      let textEncoder = new util.TextEncoder();
      let uint8Array = textEncoder.encodeInto(str);
      let base64 = new util.Base64Helper();
      return base64.encodeToStringSync(uint8Array);
    } catch (e) {
      console.error('Base64 Encode Error:', e);
      return '';
    }
  }

  static decode(base64Str: string): string {
    if (!base64Str) return '';
    try {
      let base64 = new util.Base64Helper();
      let uint8Array = base64.decodeSync(base64Str);
      let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      return textDecoder.decodeWithStream(uint8Array);
    } catch (e) {
      console.error('Base64 Decode Error:', e);
      return 'Error: Invalid Base64 String';
    }
  }
}
