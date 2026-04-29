DC = docker compose

.PHONY: up down build restart shell artisan composer setup migrate seed fresh bun bun-dev bun-build debug-on debug-off logs logs-app logs-nginx prune playwright-install

# ─── Lifecycle ────────────────────────────────────────────────────────────────
up:
	$(DC) up -d

down:
	$(DC) down

build:
	$(DC) build --no-cache

restart:
	$(DC) restart

# ─── App ──────────────────────────────────────────────────────────────────────
shell:
	$(DC) exec app bash

artisan:
	$(DC) exec app php artisan $(filter-out $@,$(MAKECMDGOALS))

composer:
	$(DC) exec app composer $(filter-out $@,$(MAKECMDGOALS))

# ─── Laravel setup ────────────────────────────────────────────────────────────
setup:
	$(DC) exec app composer install --no-scripts
	$(DC) exec app composer dump-autoload
	$(DC) exec app php artisan package:discover --ansi
	$(DC) exec app php artisan key:generate
	$(DC) exec app php artisan migrate --force
	$(DC) exec app php artisan storage:link --force
	$(DC) exec node bun install
	$(DC) exec node bun run build

# Run this any time Playwright npm package needs reinstalling
# Browser binary is baked into the image at /usr/local/ms-playwright
playwright-install:
	$(DC) exec app npm install playwright
	$(DC) exec -e PLAYWRIGHT_BROWSERS_PATH=/usr/local/ms-playwright app npx playwright install chromium

migrate:
	$(DC) exec app php artisan migrate

seed:
	$(DC) exec app php artisan db:seed

fresh:
	$(DC) exec app php artisan migrate:fresh --seed

# ─── Bun ──────────────────────────────────────────────────────────────────────
bun:
	$(DC) exec node bun $(filter-out $@,$(MAKECMDGOALS))

bun-dev:
	$(DC) exec node bun run dev -- --host

bun-build:
	$(DC) exec node bun run build

# ─── Debug ────────────────────────────────────────────────────────────────────
debug-on:
	XDEBUG_MODE=debug $(DC) up -d app

debug-off:
	XDEBUG_MODE=off $(DC) up -d app

# ─── Logs ─────────────────────────────────────────────────────────────────────
logs:
	$(DC) logs -f

logs-app:
	$(DC) logs -f app

logs-nginx:
	$(DC) logs -f nginx

# ─── Cleanup ──────────────────────────────────────────────────────────────────
prune:
	$(DC) down -v --remove-orphans

%:
	@:
