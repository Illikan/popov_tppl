Сбор данных с двух серверов с записью в файл.

### Запуск
```bash
lua main.lua
```
Данные пишутся в `data_log.txt`.  
Остановка — **Ctrl+C**.

### Автотесты
Нужен установленный `busted`.

Прогон тестов:
```bash
busted
```

Проверка покрытия (создаст отчет `luacov.report.out`):
```bash
busted --coverage
luacov
```
