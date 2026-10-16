# Baki Khata landing page

A Bengali-first, responsive static landing page for Baki Khata, using actual Flutter app screenshots supplied by the project owner.

## Preview

Open `index.html` in a browser, or run `python3 -m http.server 8000` in this folder and visit `http://localhost:8000`.

## GitHub Pages

Copy the contents of this folder to the branch/folder served by GitHub Pages (for example the repo root on `main`), then enable Pages under repository **Settings → Pages**.

## Before publishing

1. **Replace `https://github.com/`** in `index.html` (`id="source-link"`) with your real GitHub repository link, or replace the CTA entirely with a verified APK download link.
2. Three provided screenshots had an Android "Screenshot captured" notification overlay. The corresponding images were cropped to avoid showing that notification. Replace these with clean, full-height captures when possible.
3. Consider adding a privacy policy, support email, and APK installation instructions once an official download is available.
4. If you offer APK downloads, distribute only signed trusted builds with clear version and installation information.

No build system required. Google Fonts are loaded when online; the page works with system fonts offline.
