# VHAL — PROJECT MEMORY

Última actualización: 2026-08-21

## 1. Propósito

VHAL es un proyecto MMORPG desarrollado con una arquitectura server-authoritative.

El proyecto se divide actualmente en tres repositorios:

- Client:
  https://github.com/schmidtoctavio/vhal

- Game Server:
  https://github.com/schmidtoctavio/vhal_game_server

- Backend:
  https://github.com/schmidtoctavio/vhal_backend

Rama activa de desarrollo:

- `dev`

Principio arquitectónico principal:

> Scalability, maintainability, consistency, and clear responsibilities before speed of implementation.

El cliente expresa intención y representa estado.

El Game Server es la autoridad de gameplay.

Laravel administra identidad, API y persistencia durable.

MySQL conserva el estado persistente.

---

# 2. Arquitectura actual

```text
Godot Client
    |
    | ENet
    v
Godot Game Server
    |
    | HTTP interno
    v
Laravel Backend
    |
    v
MySQL