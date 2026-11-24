/**
 * ==============================================================================
 * 🛡️ FREEBUFF CHROME STEALTH SHIELD — In-Page Anti-Fingerprinting Engine
 * Runs at document_start in MAIN world to neutralize bot & canvas detection.
 * ==============================================================================
 */
(function () {
  'use strict';

  // 1. Neutralize Navigator Webdriver (Automated Browser Detection)
  try {
    const newProto = Object.getPrototypeOf(navigator);
    delete newProto.webdriver;
    Object.defineProperty(navigator, 'webdriver', {
      get: () => undefined,
      configurable: true,
      enumerable: true
    });
  } catch (e) {}

  // 2. Normalize Languages, Platform & US Geolocation / Timezone
  try {
    Object.defineProperty(navigator, 'languages', {
      get: () => ['en-US', 'en'],
      configurable: true
    });
    Object.defineProperty(navigator, 'language', {
      get: () => 'en-US',
      configurable: true
    });
  } catch (e) {}

  // Spoof Intl Timezone & Date Offset to US Eastern (America/New_York)
  try {
    const origResolvedOptions = Intl.DateTimeFormat.prototype.resolvedOptions;
    Intl.DateTimeFormat.prototype.resolvedOptions = function () {
      const opts = origResolvedOptions.apply(this, arguments);
      return Object.assign(opts, {
        timeZone: 'America/New_York',
        locale: 'en-US'
      });
    };
  } catch (e) {}

  // Generate deterministic subtle session shift based on load time
  const shift = (Math.floor(Date.now() / 1000) % 5) + 1;

  // 3. Canvas Farbling (Add micro-jitter to prevent cross-session hashing)
  try {
    const origToDataURL = HTMLCanvasElement.prototype.toDataURL;
    HTMLCanvasElement.prototype.toDataURL = function (type, ...args) {
      const ctx = this.getContext('2d');
      if (ctx && this.width > 8 && this.height > 8) {
        try {
          const img = ctx.getImageData(0, 0, 1, 1);
          img.data[0] = (img.data[0] + shift) % 256;
          ctx.putImageData(img, 0, 0);
        } catch (err) {}
      }
      return origToDataURL.apply(this, [type, ...args]);
    };

    const origGetImageData = CanvasRenderingContext2D.prototype.getImageData;
    CanvasRenderingContext2D.prototype.getImageData = function (sx, sy, sw, sh, ...args) {
      const result = origGetImageData.apply(this, [sx, sy, sw, sh, ...args]);
      if (result && result.data && result.data.length > 4) {
        result.data[0] = (result.data[0] + shift) % 256;
      }
      return result;
    };
  } catch (e) {}

  // 4. WebGL Vendor & Renderer Masking (Clean High-End Retail GPU Profile)
  try {
    const maskWebGL = function (proto) {
      if (!proto) return;
      const origGetParameter = proto.getParameter;
      proto.getParameter = function (parameter) {
        // UNMASKED_VENDOR_WEBGL
        if (parameter === 37445) {
          return 'Google Inc. (Intel)';
        }
        // UNMASKED_RENDERER_WEBGL
        if (parameter === 37446) {
          return 'ANGLE (Intel, Mesa Intel(R) UHD Graphics (CML GT2), OpenGL 4.6)';
        }
        return origGetParameter.apply(this, arguments);
      };
    };

    if (window.WebGLRenderingContext) {
      maskWebGL(WebGLRenderingContext.prototype);
    }
    if (window.WebGL2RenderingContext) {
      maskWebGL(WebGL2RenderingContext.prototype);
    }
  } catch (e) {}

  // 5. AudioContext Farbling (Prevent acoustic hardware fingerprinting)
  try {
    if (window.AudioBuffer) {
      const origGetChannelData = AudioBuffer.prototype.getChannelData;
      AudioBuffer.prototype.getChannelData = function (channel) {
        const data = origGetChannelData.apply(this, arguments);
        if (data && data.length > 0) {
          data[0] = data[0] + (shift * 0.0000001);
        }
        return data;
      };
    }
    if (window.AnalyserNode) {
      const origGetFloatFreq = AnalyserNode.prototype.getFloatFrequencyData;
      AnalyserNode.prototype.getFloatFrequencyData = function (array) {
        origGetFloatFreq.apply(this, arguments);
        if (array && array.length > 0) {
          array[0] = array[0] + (shift * 0.0001);
        }
      };
    }
  } catch (e) {}

  // 6. Ensure Chrome Object & Permissions look authentic
  try {
    if (!window.chrome) {
      window.chrome = {
        app: { isInstalled: false },
        runtime: { PlatformOs: { LINUX: 'linux' } }
      };
    }
  } catch (e) {}
})();
