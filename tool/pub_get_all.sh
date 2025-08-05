#!/bin/bash

# Script to run 'fvm flutter pub get' in each package directory that contains a pubspec.yaml

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🚀 Running fvm flutter pub get and build_runner in all packages..."
echo "================================================"

# Get the root directory (one level up from script directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="${ROOT_DIR}/packages"

# Check if packages directory exists
if [ ! -d "$PACKAGES_DIR" ]; then
    echo -e "${RED}Error: packages directory not found at $PACKAGES_DIR${NC}"
    exit 1
fi

# Counter for tracking
total_packages=0
successful_packages=0
failed_packages=0

# Navigate to each folder in packages directory
for package_dir in "$PACKAGES_DIR"/*; do
    if [ -d "$package_dir" ]; then
        package_name=$(basename "$package_dir")
        pubspec_file="$package_dir/pubspec.yaml"
        
        if [ -f "$pubspec_file" ]; then
            echo -e "${YELLOW}📦 Processing package: $package_name${NC}"
            total_packages=$((total_packages + 1))
            
            # Navigate to package directory and run fvm flutter pub get
            cd "$package_dir" || { echo -e "${RED}Failed to navigate to $package_dir${NC}"; continue; }
            
            # Run pub get first
            if fvm flutter pub get; then
                echo -e "${GREEN}✅ Successfully ran pub get for $package_name${NC}"
                
                # Check if build_runner is a dependency and run it
                if grep -q "build_runner:" pubspec.yaml; then
                    echo "🔨 Running build_runner for $package_name..."
                    if fvm dart run build_runner build; then
                        echo -e "${GREEN}✅ Successfully ran build_runner for $package_name${NC}"
                    else
                        echo -e "${RED}❌ Failed to run build_runner for $package_name${NC}"
                        failed_packages=$((failed_packages + 1))
                        continue
                    fi
                fi
                
                successful_packages=$((successful_packages + 1))
            else
                echo -e "${RED}❌ Failed to run pub get for $package_name${NC}"
                failed_packages=$((failed_packages + 1))
            fi
            
            echo ""
        else
            echo "⏭️  Skipping $package_name (no pubspec.yaml found)"
        fi
    fi
done

# Return to original directory
cd "$ROOT_DIR/tool" || exit 1

# Summary
echo "================================================"
echo "📊 Summary:"
echo "   Total packages processed: $total_packages"
echo -e "   ${GREEN}Successful: $successful_packages${NC}"
if [ $failed_packages -gt 0 ]; then
    echo -e "   ${RED}Failed: $failed_packages${NC}"
fi
echo "🎉 Done!"

# Exit with error code if any packages failed
if [ $failed_packages -gt 0 ]; then
    exit 1
fi