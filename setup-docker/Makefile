DC = docker compose

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
	$(DC) exec app composer install
	$(DC) exec app php artisan key:generate
	$(DC) exec app php artisan migrate --force
	$(DC) exec app php artisan storage:link

migrate:
	$(DC) exec app php artisan migrate

seed:
	$(DC) exec app php artisan db:seed

fresh:
	$(DC) exec app php artisan migrate:fresh --seed

# ─── Node ─────────────────────────────────────────────────────────────────────
npm:
	$(DC) exec node npm $(filter-out $@,$(MAKECMDGOALS))

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
