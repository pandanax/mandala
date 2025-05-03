# Dockerfile.builder

## удаляем старое
podman rmi -f miniapp-builder:latest

## строим новое
podman build -t miniapp-builder:latest -f Dockerfile.builder .

## помещаем сбилденое в папку src
podman run -it --rm \
  -v $(pwd):/app \
  -w /app \
  miniapp-builder:latest \
  create-vite src --template react-ts

## переходим в src и билдим dist
podman run -it --rm \
  -v $(pwd):/app \
  -w /app \
  miniapp-builder:latest \
  npm run build

# Dockerfile.prod

## Build Dockerfile.prod
podman build --platform=linux/amd64 -t miniapp-prod:latest -f Dockerfile.prod .

## Тегирование образа
podman tag miniapp-prod:latest cr.yandex/crp48jn0d8i97rou3u0r/miniapp-prod:latest

## Загрузка образа
podman push cr.yandex/crp48jn0d8i97rou3u0r/miniapp-prod:latest

# Проверка локально (в конфиге nginx установить localhost)

## Stop old (optionally)
podman rm -f test-app
podman stop test-app && podman rm test-app

## Run
podman run -d --name test-app -p 8080:80 miniapp-prod:latest

# YC

## Авторизация в Container Registry
podman login cr.yandex/crp48jn0d8i97rou3u0r \
  --username iam \
  --password "$(yc iam create-token)"


