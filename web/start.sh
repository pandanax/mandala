podman build -f Dockerfile.local -t my-app-dev .
podman run -p 5173:5173 -v $(pwd):/app -v /app/node_modules my-app-dev
