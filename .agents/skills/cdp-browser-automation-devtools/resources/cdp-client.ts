import { chromium } from 'playwright';
export async function runCdpSession() {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const client = await page.context().newCDPSession(page);
  await client.send('Network.enable');
}
