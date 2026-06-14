# Docker project
Проект генерирует CSV со статистикой матчей Dota 2 и создаёт по нему HTML-отчёт.
Генератор и аналитик запускаются в отдельных Docker-контейнерах, а результаты
сохраняются на хосте в папке `data`.

## Проверка

```bash
chmod +x run.sh
./run.sh build_generator
./run.sh run_generator
./run.sh build_reporter
./run.sh run_reporter
```
После выполнения появятся:
```text
data/data.csv
data/report.html
```

## Команды

```bash
./run.sh build_generator
./run.sh run_generator
./run.sh create_local_data
./run.sh build_reporter
./run.sh run_reporter
./run.sh structure
./run.sh clear_data
./run.sh inside_generator
./run.sh inside_reporter
```
