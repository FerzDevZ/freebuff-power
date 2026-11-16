import { test, expect } from '@playwright/test';
import { LoginPage } from './login.page';

test.describe('Authentication Flow', () => {
  test('should allow a valid user to log in and redirect to dashboard', async ({ page }) => {
    const loginPage = new LoginPage(page);

    await loginPage.goto();
    await loginPage.login('user@example.com', 'SecurePassword123!');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByRole('heading', { name: 'Welcome Back' })).toBeVisible();
  });
});
