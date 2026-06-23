# SenseMyMusic

A self-hosted music analysis and recommendation platform focused on **clean architecture, explicit domain modeling, and backend independence**.

SenseMyMusic analyzes music libraries and exposes structured metadata, moods, audio characteristics, and playlist generation capabilities through a REST API.

This repository contains the **full application workspace**, centered around a Laravel backend and an independent frontend client.

---

# Project Goals

* Build a maintainable music analysis platform.
* Keep domain rules centralized in the backend.
* Allow frontend technology to evolve independently.
* Support Docker-first local development.
* Maintain clear boundaries between infrastructure and business logic.

---

# Architecture Philosophy

SenseMyMusic follows a **backend-centered architecture**.

Unlike the previous TypeScript prototype, domain entities are intentionally **not shared directly between frontend and backend**.

The backend owns the business rules.

Clients consume the system through API contracts.

This avoids:

* frontend coupling to backend implementation
* leaking internal domain structures
* forced synchronized deployments
* accidental dependency cycles

The frontend should treat the backend as an external service.

---

# High-Level Architecture

```text
Frontend (Vue / Angular / TBD)
            │
            ▼
       HTTP / JSON API
            │
            ▼
Laravel Application
├── Application Layer
├── Domain Layer
├── Infrastructure Layer
└── Persistence Layer
            │
            ▼
       PostgreSQL
```

---

# Repository Layout

```text
app_src/
├── backend/
│   ├── app/
│   │   ├── Domain/
│   │   ├── Application/
│   │   ├── Infrastructure/
│   │   └── Http/
│   │
│   ├── database/
│   ├── routes/
│   ├── tests/
│   └── storage/
│
├── frontend/
│
└── media/
    └── seeder_assets/

docker/
├── backend/
├── frontend/
└── postgres/

docker-compose.yml
```

---

# Backend

Backend responsibilities:

* Music library indexing
* Audio metadata extraction
* Recommendation logic
* Playlist generation
* Authentication
* Persistence
* API exposure

Implemented using:

* Laravel
* PHP
* PostgreSQL
* Docker

---

# Frontend

Frontend responsibilities:

* User interaction
* Visualization
* Search
* Playback UI
* Dashboard

Frontend technology is intentionally undecided.

Possible candidates:

* Vue
* Angular
* React

The frontend should communicate exclusively through the API.

---

# Development Environment

Everything runs inside Docker.

Host machine requirements:

* Docker
* Docker Compose
* Git

No local runtime installation should be required.

Start:

```bash
docker compose up --build
```

Stop:

```bash
docker compose down
```

Rebuild:

```bash
docker compose up --build --force-recreate
```

---

# Environment Variables

Copy:

```bash
cp .env.example .env
```

Then configure:

```env
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=

BACKEND_PORT=
FRONTEND_PORT=
```

---

# Design Decision: No Shared Domain Model

This project previously experimented with sharing TypeScript domain classes across frontend and backend.

That approach was intentionally abandoned.

Reasons:

* frontend and backend evolve at different speeds
* API contracts are more stable than implementation classes
* backend entities should not become frontend state containers
* transport models and domain models solve different problems

Instead:

```text
Domain Entity
    ↓
Application DTO
    ↓
API Response
    ↓
Frontend State
```

Each layer owns its own representation.

This duplication is intentional.

---

# Current Status

Prototype stage.

Core infrastructure and architecture are being established before feature implementation.
