# Laravel Starter Kit (Dockerized)

> A containerized fork of [nunomaduro/laravel-starter-kit](https://github.com/nunomaduro/laravel-starter-kit) — ultra-strict, type-safe Laravel wrapped in a production-ready Docker environment.

<p align="center">
    <a href="https://github.com/nunomaduro/laravel-starter-kit/actions"><img src="https://github.com/nunomaduro/laravel-starter-kit/actions/workflows/tests.yml/badge.svg" alt="Build Status"></a>
    <a href="https://packagist.org/packages/nunomaduro/laravel-starter-kit"><img src="https://img.shields.io/packagist/v/nunomaduro/laravel-starter-kit" alt="Latest Stable Version"></a>
</p>

---

## Why This Fork?

The original kit provides an excellent foundation. This version adds a full Docker environment so you spend zero time configuring PHP extensions, databases, or browser-testing binaries.

- **Instant setup**: one `make setup` installs everything
- **Pre-baked Playwright**: Chromium is baked into the Docker image - no host/container permission fights
- **Full service stack**: PostgreSQL, Redis, Meilisearch, Mailpit, pgAdmin, Bun, and Vite all wired up
- **Strict code quality**: PHPStan, Rector, Pint, and Peck run inside the container with no local installs needed

---

## Stack

| Service | Image | Port |
| :--- | :--- | :--- |
| PHP 8.5-rc FPM | Custom Dockerfile | — |
| Nginx | nginx:1.25-alpine | 80 |
| PostgreSQL 16 | postgres:16-alpine | 5432 |
| Redis 7 | redis:7-alpine | 6379 |
| Mailpit | axllent/mailpit:latest | 1025 / 8025 |
| pgAdmin 4 | dpage/pgadmin4:latest | 5050 |
| Bun / Vite | oven/bun:1 | 5173 |
| Queue worker | Custom Dockerfile | — |
| Scheduler | Custom Dockerfile | — |

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with at least **4GB memory** allocated (required for Chromium build step)
- `make`

---

## Getting Started

### 1. Clone and configure

```bash
git clone https://github.com/arquizade/laravel-starter-kit.git example-app
cd example-app
cp .env.docker .env
```

### 2. Build images

```bash
make build
```

This step takes 3–5 minutes on first run. Chromium downloads during the build as root, which avoids runtime permission and memory issues.

### 3. Start containers

```bash
make up
```

### 4. Run setup

```bash
make setup
```

This runs composer install, key generation, migrations, storage link, and asset build in sequence.

### 5. Verify everything works

```bash
./tester.sh
```

All 18 checks should pass green.

---

## URLs

| Service | URL |
| :--- | :--- |
| Laravel app | http://localhost |
| pgAdmin | http://localhost:5050 |
| Mailpit | http://localhost:8025 |
| Meilisearch | http://localhost:7700 |
| Vite dev server | http://localhost:5173 |

**pgAdmin credentials**: set via `PGADMIN_EMAIL` and `PGADMIN_PASSWORD` in `.env`.  
Add a new server in pgAdmin pointing to host `postgres`, port `5432`.

---

## Makefile Commands

Run `make help` to see all available make commands.

---

## Browser Testing

Chromium is pre-baked into the app image at `/usr/local/ms-playwright` during the Docker build. No manual install needed after `make build`.

```bash
# Run all tests including browser tests
make test
```

If you see a `PlaywrightNotInstalledException` after wiping `node_modules`, run:

```bash
make playwright-install
```

---

## Xdebug

Xdebug is installed but off by default. Toggle it without rebuilding:

```bash
make debug-on    # enables debug mode on port 9003
make debug-off   # turns it back off
```

IDE key is set to `PHPSTORM`. Change it in `.docker/php/xdebug.ini` if you use VS Code.

---

## Tester Script

`tester.sh` validates all 18 aspects of the stack in one command:

```bash
./tester.sh
```

Checks include: container health, HTTP responses, database connection, Redis, Meilisearch, queue worker, scheduler, Mailpit delivery, Vite, Playwright binary, code linting (Rector, Pint, Peck), PHPStan, Pest type coverage, full test suite, and Xdebug toggle.

---

## Credits

This project is a fork of the original [Laravel Starter Kit](https://github.com/nunomaduro/laravel-starter-kit) created by [Nuno Maduro](https://x.com/enunomaduro).

## License

[MIT](https://opensource.org/licenses/MIT)