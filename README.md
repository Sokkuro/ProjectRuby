# Coworking Booking Service

Веб-приложение на Ruby on Rails для бронирования коворкингов и переговорных комнат.

## Требования

- **Ruby** 4.0.5 (или 3.2.2+)
- **Rails** 7.0.x
- Bundler
- SQLite3

## Быстрый старт

```bash
cd ruby_proj
bin/setup
bin/rails server
```

Откройте http://localhost:3000

Альтернатива по шагам:

```bash
bundle install
cp .env.example .env
# заполните GITHUB_CLIENT_ID и GITHUB_CLIENT_SECRET
rails db:create db:migrate db:seed
rails server
```

## GitHub OAuth

1. Создайте OAuth App: https://github.com/settings/developers  
   - Homepage URL: `http://localhost:3000`  
   - Callback URL: `http://localhost:3000/users/auth/github/callback`
2. Скопируйте Client ID и Client Secret в `.env`:

```env
GITHUB_CLIENT_ID=your_id
GITHUB_CLIENT_SECRET=your_secret
```

3. Вход: `/auth/github` или кнопка «GitHub» в шапке.

При первом входе через GitHub пользователь создаётся с ролью `client`. Роли `owner` и `admin` назначаются в Active Admin или консоли.

## Тестовые учётные данные

| Email | Пароль | Роль |
|-------|--------|------|
| admin@example.com | password | admin |
| owner1@example.com | password | owner |
| owner2@example.com | password | owner |
| client@example.com | password | client |

Админ-панель: http://localhost:3000/admin (только для admin).

## Маршруты

| URL | Описание |
|-----|----------|
| `/` | Главная |
| `/rooms` | Список помещений |
| `/rooms/:id` | Детали + Stimulus-калькулятор |
| `/bookings/new?room_id=` | Форма бронирования |
| `/my_bookings` | Мои брони (авторизация) |
| `/owner/rooms` | Управление помещениями (owner) |
| `/admin` | Active Admin |
| `/auth/github` | Вход через GitHub |

## База данных

Три таблицы: `users`, `rooms`, `bookings`.

Цена брони: `price_per_hour * ((end_time - start_time) / 3600.0)`. Пересекающиеся брони (кроме `canceled`) запрещены.

## Тесты

```bash
bundle exec rspec
```

Unit-тесты моделей (RSpec + FactoryBot + Shoulda Matchers).

## Стек

- Rails 7, importmap, Stimulus, Turbo
- Devise + OmniAuth (GitHub)
- Active Admin
- SQLite