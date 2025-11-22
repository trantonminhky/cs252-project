FROM gmeligio/flutter-android:3.35.7

WORKDIR /app

# 1. Copy the essential files (Excluding android folder)
COPY --chown=flutter:flutter pubspec.yaml ./
COPY --chown=flutter:flutter pubspec.lock ./
COPY --chown=flutter:flutter analysis_options.yaml ./
COPY --chown=flutter:flutter lib ./lib
COPY --chown=flutter:flutter assets ./assets
COPY --chown=flutter:flutter android ./android

# 2. Switch to flutter user to avoid permission issues
USER flutter

# 3. Generate fresh Android files
# 4. Get Dart dependencies
RUN flutter pub get

# 5. WARM-UP BUILD (The Fix)
# This command forces Gradle to download all Android dependencies
# and compile the app during the Docker build process.
# This moves the "10 minute wait" to the "docker build" step,
# so your "flutter run" will be instant.
RUN flutter build apk --debug
CMD ["bash"]