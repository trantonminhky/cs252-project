# Project Setup (with Docker)

This project runs in a self-contained Docker environment.

## Prerequisites

1.  Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2.  Install [Android Studio](https://developer.android.com/studio).
3.  Inside Android Studio, use the Device Manager to create and start an **Android Emulator**.

## First-Time Setup

1.  **Clone the repo:**
    ```bash
    git clone [your-repo-url]
    cd [your-project-folder]/frontend
    ```

2.  **Configure ADB:**
    Open your local terminal (PowerShell, CMD, or Terminal) and run this command to allow Docker to see your emulator.
    ```bash
    adb -a start-server
    ```
    *(Note: You may need to run this again after restarting your computer.)*

3.  **Build & Start the Container:**
    ```bash
    docker-compose up -d
    ```

4.  **Run the App (First-Time Build):**
    This will open a terminal inside the container:
    ```bash
    docker-compose exec flutter-app bash
    ```
    Now, run Flutter. The first build will take 5-15 minutes to download Gradle dependencies.
    ```bash
    flutter run
    ```

## Daily Workflow

1.  Make sure your Android Emulator is running.
2.  Start the container: `docker-compose up -d`
3.  Get a shell in the container: `docker-compose exec flutter-app bash`
4.  Run the app: `flutter run`