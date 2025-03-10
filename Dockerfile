FROM swift:latest
WORKDIR /app
COPY . .
RUN swift build
