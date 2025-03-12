# Use Swift on Linux
FROM swift:latest

# Set working directory
WORKDIR /app

# Copy the package manifest
COPY Package.swift ./

# Copy only the source code (not test files)
COPY Sources/ ./Sources/

# Copy test files to the correct location
COPY Tests/ ./Tests/

# Test file existence
RUN ls -la /app/Sources/GroqSwift/

# Build the project on Linux
RUN swift build

# Create a release build
RUN swift build -c release

# Run to test
CMD ["swift", "run"]
