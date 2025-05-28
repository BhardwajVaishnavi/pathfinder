#!/bin/bash

# PathfinderAI Deployment Script
# This script helps deploy the application to various platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Flutter installation
check_flutter() {
    if ! command_exists flutter; then
        print_error "Flutter is not installed. Please install Flutter first."
        exit 1
    fi
    
    print_status "Flutter version:"
    flutter --version
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing Flutter dependencies..."
    flutter pub get
    print_success "Dependencies installed successfully"
}

# Function to build web
build_web() {
    print_status "Building web application..."
    flutter build web --release
    print_success "Web build completed"
}

# Function to build Android APK
build_android() {
    print_status "Building Android APK..."
    flutter build apk --release
    print_success "Android APK build completed"
    print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
}

# Function to deploy to Firebase Hosting
deploy_firebase() {
    if ! command_exists firebase; then
        print_error "Firebase CLI is not installed. Install with: npm install -g firebase-tools"
        exit 1
    fi
    
    print_status "Deploying to Firebase Hosting..."
    build_web
    firebase deploy --only hosting
    print_success "Deployed to Firebase Hosting successfully"
}

# Function to show help
show_help() {
    echo "PathfinderAI Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  web                 Build web application"
    echo "  android             Build Android APK"
    echo "  firebase            Deploy to Firebase Hosting"
    echo "  help                Show this help message"
}

# Main deployment logic
main() {
    print_status "Starting PathfinderAI deployment process..."
    
    # Check Flutter installation
    check_flutter
    
    # Install dependencies
    install_dependencies
    
    case "$1" in
        "web")
            build_web
            ;;
        "android")
            build_android
            ;;
        "firebase")
            deploy_firebase
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
            print_error "No deployment target specified"
            show_help
            exit 1
            ;;
        *)
            print_error "Unknown deployment target: $1"
            show_help
            exit 1
            ;;
    esac
    
    print_success "Deployment process completed successfully!"
}

# Run main function with all arguments
main "$@"
