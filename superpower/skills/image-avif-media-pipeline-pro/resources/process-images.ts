import sharp from 'sharp';

export async function convertToAvif(inputBuffer: Buffer): Promise<Buffer> {
  return sharp(inputBuffer).avif({ quality: 80, effort: 6 }).toBuffer();
}
