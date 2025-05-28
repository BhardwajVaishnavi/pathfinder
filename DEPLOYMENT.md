# Deployment Guide for PathfinderAI

This guide covers deployment options for the PathfinderAI application across different platforms.

## 🌐 Web Deployment

### Option 1: Firebase Hosting (Recommended)

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Build the web app**
   ```bash
   flutter build web --release
   ```

3. **Initialize Firebase**
   ```bash
   firebase login
   firebase init hosting
   ```

4. **Deploy**
   ```bash
   firebase deploy
   ```

### Option 2: Netlify

1. **Build the web app**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Netlify**
   - Drag and drop the `build/web` folder to Netlify
   - Or connect your GitHub repository for automatic deployments

## 📱 Mobile Deployment

### Android Deployment

#### Google Play Store

1. **Prepare for release**
   ```bash
   flutter build appbundle --release
   ```

2. **Upload to Google Play Console**
   - Create a new app in Google Play Console
   - Upload the AAB file from `build/app/outputs/bundle/release/`

#### Direct APK Distribution

1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Distribute the APK**
   - APK location: `build/app/outputs/flutter-apk/app-release.apk`

### iOS Deployment

1. **Build for iOS**
   ```bash
   flutter build ios --release
   ```

2. **Open in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Archive and upload to App Store**

## 🗄️ Database Setup

### NeonDB Configuration

1. **Create NeonDB account** at [neon.tech](https://neon.tech)
2. **Create a new project**
3. **Copy the PostgreSQL connection string**
4. **Update the connection string in your app**

## 🚀 Quick Deployment

Use the provided deployment script:

```bash
# Build web version
./deploy.sh web

# Build Android APK
./deploy.sh android

# Deploy to Firebase
./deploy.sh firebase

# Show help
./deploy.sh help
```

## 🔒 Security Considerations

- Enable HTTPS for all endpoints
- Secure database connections with SSL
- Implement proper authentication
- Validate all user inputs
- Encrypt sensitive data (identity proofs)

## 📊 Environment Configuration

Update database connection strings for different environments:
- Development: Local or development database
- Production: NeonDB or production database

For detailed deployment instructions, see the deployment script and documentation.
