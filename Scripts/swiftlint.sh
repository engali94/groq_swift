#!/bin/bash

if ! command -v swiftlint &> /dev/null; then
    echo "SwiftLint not found. Installing with Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Please install Homebrew first."
        exit 1
    fi
    brew install swiftlint
fi

if [ -f "Package.swift" ]; then
    swiftlint --config .swiftlint.yml
else
    cd "${SRCROOT}/../" || exit 1
    swiftlint --config .swiftlint.yml
fi
