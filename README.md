# Лабораторная работа №1 — Нормализация данных в схему «Снежинка»

## Структура репозитория

```
project/
├── docker-compose.yml          # PostgreSQL в Docker
├── README.md
├── data/                       # CSV-файлы с исходными данными (10 шт.)
│   ├── MOCK_DATA_1.csv
│   ├── MOCK_DATA_2.csv
│   ├── ...
│   └── MOCK_DATA_10.csv
└── init/                       # SQL-скрипты (выполняются автоматически при старте)
    ├── 00_raw.sql              # Создание staging-таблицы + загрузка CSV
    ├── 01_ddl_dimensions.sql   # DDL таблиц-измерений
    ├── 02_ddl_facts.sql        # DDL таблицы фактов
    ├── 03_dml_dimensions.sql   # DML заполнения измерений
    └── 04_dml_facts.sql        # DML заполнения фактов
```

---

## Быстрый старт

### 1. Переименуйте CSV-файлы
Скачанные файлы `MOCK_DATA (1).csv` ... `MOCK_DATA (10).csv` переименуйте:
```
MOCK_DATA (1).csv   →  MOCK_DATA_1.csv
MOCK_DATA (2).csv   →  MOCK_DATA_2.csv
...
MOCK_DATA (10).csv  →  MOCK_DATA_10.csv
```
Положите их в папку `data/`.

### 2. Запустите PostgreSQL
```bash
docker-compose up -d
```
PostgreSQL поднимется, автоматически создаст БД `petstore` и выполнит все скрипты из `init/` в алфавитном порядке.

### 3. Подключитесь в DBeaver
| Параметр | Значение |
|---|---|
| Host | localhost |
| Port | 5432 |
| Database | petstore |
| User | postgres |
| Password | postgres |

### 4. Проверьте результат
```sql
-- Кол-во строк в staging
SELECT COUNT(*) FROM mock_data;  -- должно быть 10000

-- Кол-во строк в fact_sales
SELECT COUNT(*) FROM fact_sales;  -- должно быть ~10000

-- Проверка измерений
SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_seller;
SELECT COUNT(*) FROM dim_product;
SELECT COUNT(*) FROM dim_store;
SELECT COUNT(*) FROM dim_supplier;
SELECT COUNT(*) FROM dim_date;
```

---

## Схема «Снежинка»

```
                      dim_location
                     /     |      \
          dim_customer  dim_seller  dim_store  dim_supplier
              |                                     |
         dim_pet_breed                         dim_location
                                                    
          fact_sales
          /  |  |  \  \
    date customer seller product store
                          |
                     dim_product_category
                     dim_pet_category
                     dim_brand
                     dim_supplier → dim_location
          dim_date
```

### Таблицы-измерения

| Таблица | Описание | Зависит от |
|---|---|---|
| `dim_location` | Страна, город, штат, индекс | — |
| `dim_pet_breed` | Тип и порода питомца | — |
| `dim_pet_category` | Категория питомца (Birds, Cats, Dogs, Fish, Reptiles) | — |
| `dim_product_category` | Категория товара (Food, Toy, Cage) | — |
| `dim_brand` | Бренд товара | — |
| `dim_customer` | Покупатель с питомцем | dim_location, dim_pet_breed |
| `dim_seller` | Продавец | dim_location |
| `dim_supplier` | Поставщик | dim_location |
| `dim_product` | Товар | dim_product_category, dim_pet_category, dim_brand, dim_supplier |
| `dim_store` | Магазин | dim_location |
| `dim_date` | Дата со всеми атрибутами | — |

### Таблица фактов

| Таблица | Меры | FK |
|---|---|---|
| `fact_sales` | quantity, total_price | date, customer, seller, product, store |

---

## Примеры аналитических запросов

```sql
-- Топ-10 товаров по выручке
SELECT p.product_name, b.brand_name, SUM(f.total_price) AS revenue
FROM fact_sales f
JOIN dim_product p ON p.id = f.product_id
JOIN dim_brand   b ON b.id = p.brand_id
GROUP BY p.product_name, b.brand_name
ORDER BY revenue DESC
LIMIT 10;

-- Продажи по годам и кварталам
SELECT d.year, d.quarter, COUNT(*) AS cnt, SUM(f.total_price) AS revenue
FROM fact_sales f
JOIN dim_date d ON d.id = f.date_id
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- Топ-5 стран покупателей
SELECT l.country, COUNT(*) AS sales
FROM fact_sales f
JOIN dim_customer c ON c.id = f.customer_id
JOIN dim_location l ON l.id = c.location_id
GROUP BY l.country
ORDER BY sales DESC
LIMIT 5;

-- Продажи по категориям питомцев
SELECT pc.category_name, SUM(f.total_price) AS revenue
FROM fact_sales f
JOIN dim_product     p  ON p.id  = f.product_id
JOIN dim_pet_category pc ON pc.id = p.pet_category_id
GROUP BY pc.category_name
ORDER BY revenue DESC;
```
