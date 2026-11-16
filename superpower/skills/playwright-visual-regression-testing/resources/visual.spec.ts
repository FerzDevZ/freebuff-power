import { test, expect } from '@playwright/test';
test('homepage snapshot', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('home.png');
});
