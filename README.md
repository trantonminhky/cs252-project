# Project Setup (with Docker)

This project runs in a self-contained Docker environment.

## Prerequisites

1. **Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).**
    
2. **Install [Android Studio](https://developer.android.com/studio).**
    
3. **Add ADB to your System PATH:** This is required so you can run `adb` commands from your terminal. The `adb` tool is located inside your Android SDK folder, in a sub-directory named `platform-tools`.
    
    - **Find your SDK:**
        
        - **Windows (default):** `C:\Users\<your-username>\AppData\Local\Android\Sdk`
            
        - **macOS (default):** `/Users/<your-username>/Library/Android/sdk`
            
    - The full path you need to add is the `platform-tools` folder (e.g., `...Sdk\platform-tools`).
        
    - **On Windows:** Search for "Edit the system environment variables", go to "Environment Variables...", select `Path` under "User variables", click "Edit", and add the full path to your `platform-tools` folder.
        
    - **On macOS:** Add the following line to your `~/.zshrc` or `~/.bash_profile`: `export PATH="$PATH:/Users/<your-username>/Library/Android/sdk/platform-tools"`
        
    - **Verify:** Close and reopen your terminal, then run `adb version`. You should see the version information.
    

## First-Time Setup

1. **Clone the repo:**
    
    Bash
    
    ```
    git clone [your-repo-url]
    cd [your-project-folder]/frontend
    ```
    
2. **Start your Emulator and Configure ADB:** Inside Android Studio, use the **Device Manager (In "More Actions")** to create and start an Android Emulator. Run this command in your local terminal (PowerShell, CMD, or Terminal) to allow Docker to see your emulator.
    
    Bash
    
    ```
    adb -a start-server
    ```
    
3. **Check Connection:** Run the following command. You should see your emulator listed as a device.
    
    Bash
    
    ```
    adb devices
    ```
    
    _(Note: You may need to run `adb -a start-server` again after restarting your computer.)_
    
4. **Build & Start the Container:**
    
    Bash
    
    ```
    docker-compose up -d
    ```
    
5. **Run the App (First-Time Build):** This will open a terminal inside the container:
    
    Bash
    
    ```
    docker-compose exec flutter-app bash
    ```
    
    Now, run the one-time setup commands inside the container:
    
    Bash
    
    ```
    # Create the local.properties file
    echo "flutter.sdk=/home/mobiledevops/.flutter-sdk" > android/local.properties
    echo "sdk.dir=/home/mobiledevops/android-sdk" >> android/local.properties
    
    # Get all dependencies
    flutter pub get
    
    # Run the app
    flutter run
    ```
    
    The first build will take 5-15 minutes to download Gradle dependencies.
    

## Daily Workflow

1. Make sure your Android Emulator is running.
    
2. Check that ADB can see it: `adb devices`
    
3. Start the container: `docker-compose up -d`
    
4. Get a shell in the container: `docker-compose exec flutter-app bash`
    
5. Run the app: `flutter run`
