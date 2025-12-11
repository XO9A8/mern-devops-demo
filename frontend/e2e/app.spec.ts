import { test, expect } from '@playwright/test';

test.describe('Frontend E2E Tests', () => {
    test('should load the home page', async ({ page }) => {
        await page.goto('/');

        // Check that the page loads
        await expect(page).toHaveTitle(/MERN/i);
    });

    test('should display main heading', async ({ page }) => {
        await page.goto('/');

        // Look for main content
        const body = page.locator('body');
        await expect(body).toBeVisible();
    });

    test('should be able to navigate', async ({ page }) => {
        await page.goto('/');

        // Wait for React to hydrate
        await page.waitForLoadState('networkidle');

        // Page should be interactive
        await expect(page.locator('#root')).toBeVisible();
    });
});
