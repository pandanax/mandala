podman-compose -f docker-compose-dev.yml down -v && podman-compose -f docker-compose-dev.yml up --build -d
# Ждем 5 секунд чтобы сервер успел запуститься (можете изменить по необходимости)
sleep 5

# Открываем браузер с указанным URL
open "http://localhost:5173/"
