# Laravel Starter Kit (Dockerized)

> This is a containerized fork of [nunomaduro/laravel-starter-kit](https://github.com/nunomaduro/laravel-starter-kit).

<p align="center">
    <a href="https://github.com/nunomaduro/laravel-starter-kit/actions"><img src="https://github.com/nunomaduro/laravel-starter-kit/actions/workflows/tests.yml/badge.svg" alt="Build Status"></a>
    <a href="https://packagist.org/packages/nunomaduro/laravel-starter-kit"><img src="https://img.shields.io/packagist/v/nunomaduro/laravel-starter-kit" alt="Latest Stable Version"></a>
</p>

**Laravel Starter Kit (Dockerized)** takes the ultra-strict, type-safe skeleton engineered by Nuno Maduro and wraps it in a production-ready Docker environment. This fork is designed for developers who want the highest level of code quality without spending hours configuring PHP extensions, databases, or browser-testing binaries.

## Why This Fork?

While the original kit provides an excellent foundation, this version adds:

- **Instant Containerization**: Pre-configured Docker Compose setup for PHP 8.5, PostgreSQL, Redis, Mailpit, and Bun.
- **Zero-Config Browser Testing**: Playwright and Chromium are **pre-baked** into the Docker image. No more "host vs container" permission issues.
- **Unified Workflow**: A comprehensive `Makefile` replaces long Docker commands with simple aliases.
- **Strict Development Environment**: Optimized for the latest PHP 8.5 features and strict static analysis (PHPStan Level 9).

## Infrastructure Stack

- **PHP 8.5-rc** (FPM)
- **PostgreSQL 16** (Database)
- **Redis 7** (Cache/Queue)
- **Bun 1.x** (Fastest Frontend Tooling)
- **Nginx 1.25** (Web Server)
- **Mailpit** (Email Testing)
- **pgAdmin 4** (Database Management)

## Getting Started

### 1. Prerequisites
Ensure you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) and `make` installed on your machine.

### 2. Installation
Clone this repository and run the automated setup:

```bash
git clone https://github.com/your-username/your-repo-name.git example-app
cd example-app

# Copy environment file
cp .env.example .env

# Build and setup everything (Composer, Migrations, Keys, Bun, etc.)
make setup
```

### 3. Start Developing
Once setup is complete, start the services:

```bash
make up
```

Your app will be available at [http://localhost](http://localhost).  
Access **pgAdmin** at [http://localhost:5050](http://localhost:5050) and **Mailpit** at [http://localhost:8025](http://localhost:8025).

## The Makefile Workflow

This project uses `make` to interact with the Docker containers. You should rarely need to run `docker compose` directly.

| Command | Description |
| :--- | :--- |
| `make setup` | Initial install: builds images, installs dependencies, runs migrations. |
| `make up` / `make down` | Start or stop the Docker containers. |
| `make shell` | Jump into the PHP application container bash. |
| `make artisan ...` | Run any artisan command (e.g., `make artisan make:model Post`). |
| `make composer ...` | Run composer commands (e.g., `make composer update`). |
| `make test` | Run the full Pest test suite inside the container. |
| `make fresh` | Wipe the database and re-seed it. |
| `make playwright-install` | Re-sync Playwright binaries if node_modules are wiped. |
| `make debug-on` | Restart the app container with **Xdebug** enabled. |

## Browser Testing

Pest's browser testing works out of the box. Because Chromium is pre-installed in the Docker image, tests are fast and reliable:

```bash
# Run all tests, including browser tests
make artisan test
```

## Credits

This project is a fork of the original [Laravel Starter Kit](https://github.com/nunomaduro/laravel-starter-kit) created by **[Nuno Maduro](https://x.com/enunomaduro)**.

## License

Standard **[MIT license](https://opensource.org/licenses/MIT)**.