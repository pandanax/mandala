podman build -f Dockerfile.local -t my-api-dev .
podman run -p 3000:3000 -v $(pwd):/app -v /app/node_modules my-api-dev
