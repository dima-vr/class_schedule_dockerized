terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.20.0"  # або останню доступну версію
    }
  }
}

provider "docker" {}

# PostgreSQL
resource "docker_image" "postgres" {
  name = "postgres:13"
}

resource "docker_container" "db" {
  image = docker_image.postgres.latest
  name  = "class_schedule_db"

  env = [
    "POSTGRES_USER=username",
    "POSTGRES_PASSWORD=password",
    "POSTGRES_DB=database"
  ]

  ports {
    internal = 5432
    external = 5432
  }
}

# Redis
resource "docker_image" "redis" {
  name = "redis:alpine"
}

resource "docker_container" "redis" {
  image = docker_image.redis.latest
  name  = "class_schedule_redis"

  ports {
    internal = 6379
    external = 6379
  }
}

# Backend
resource "docker_image" "backend" {
  name = "dimavr/class_schedule_backend:latest"
}

resource "docker_container" "backend" {
  image = docker_image.backend.latest
  name  = "class_schedule_backend"

  env = [
    "DB_URL=postgres://username:password@db:5432/database",
    "REDIS_URL=redis://redis:6379"
  ]

  ports {
    internal = 8080
    external = 8080
  }

  depends_on = [docker_container.db, docker_container.redis]
}

# Frontend
resource "docker_image" "frontend" {
  name = "dimavr/class_schedule_frontend:latest"
}

resource "docker_container" "frontend" {
  image = docker_image.frontend.latest
  name  = "class_schedule_frontend"

  ports {
    internal = 3000
    external = 3000
  }
}
