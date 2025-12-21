## Web

- Flutter's `html` web renderer is deprecated. The project now prefers the CanvasKit renderer for better compatibility and rendering. The app's `web/index.html` includes a meta tag to select CanvasKit by default:

  `<meta name="flutter-web-renderer" content="canvaskit">`

If you need to run locally with a different renderer, use `flutter run -d web-server --web-renderer canvaskit`.

---