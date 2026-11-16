"""
Production Stealth Web Scraper with Playwright
"""

import asyncio
from playwright.async_api import async_playwright

async def scrape_target(url: str):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
            viewport={"width": 1920, "height": 1080},
            locale="en-US",
            timezone_id="America/New_York"
        )
        
        # Inject stealth scripts
        await context.add_init_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
        
        page = await context.new_page()
        await page.goto(url, wait_until="networkidle")
        title = await page.title()
        print(f"✅ Scraped Title: {title}")
        
        await browser.close()

if __name__ == "__main__":
    asyncio.run(scrape_target("https://httpbin.org/headers"))
