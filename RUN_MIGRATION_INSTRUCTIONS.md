# Как запустить миграцию на хостинге

## Вариант 1: Через phpMyAdmin/Adminer (если есть веб-интерфейс)
1. Откройте веб-интерфейс вашей базы данных
2. Выберите базу данных `autosalon`
3. Перейдите во вкладку "SQL"
4. Скопируйте и вставьте содержимое файла `migration_add_string_characteristics.sql`
5. Нажмите "Выполнить"

## Вариант 2: Через командную строку хостинга
Если у вас есть доступ к командной строке:
```bash
psql -U ваш_пользователь -d autosalon -f migration_add_string_characteristics.sql
```

## Вариант 3: Через API endpoint (если нужно)
Можно создать специальный endpoint для выполнения миграции

## Вариант 4: Временно изменить код
Можно временно изменить код, чтобы использовать существующие `_id` колонки

## SQL команды для выполнения:

```sql
-- Добавляем строковые колонки для характеристик (если они не существуют)
ALTER TABLE cars 
ADD COLUMN IF NOT EXISTS fuel_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS transmission_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS drive_type VARCHAR(50);