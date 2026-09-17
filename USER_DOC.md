# User Documentation

This document is written for end users and administrators. It does not assume knowledge of the internals of the project — only that you can open a terminal and a web browser.

---

## 1. What this stack provides

The project runs as a set of containers, each responsible for one service. They are started together and talk to each other over a private network.

| Service | Role | Reachable from outside? |
|---|---|---|
| `nginx` | Web server / entry point. Terminates TLS and forwards requests to the application. | Yes — `https://ibenne.42.fr` |
| `wordpress` | The website itself and its administration panel. | No — internal network only |
| `mariadb` | Database. Stores pages, posts, users and settings. | No — internal network only |

Persistent data (the database and the uploaded website files) is stored in volumes on the host at `$DATA_FOLDER` so it survives a restart or a rebuild of the containers.

---

## 2. Requirements

Before starting, make sure you have:

- Docker Engine `29.7` or newer, and Docker Compose
- `make` (optional, but recommended for convenience)
- An entry in your hosts file pointing the domain to your machine:

  ```
  127.0.0.1    ibenne.42.fr
  ```

  On Linux and macOS this file is `/etc/hosts`; you need administrator rights to edit it.

---

## 3. Starting and stopping the project

All commands are run from the root of the project.

### First start

On a fresh clone, put the credentials in place first (see [section 5](#5-credentials)):

```bash
make init
```

This assumes that there is a .env file and secret files on the /data/ismo path

### Start

```bash
make
```

The first start takes several minutes: images are built and the database is initialised.

### Stop

```bash
make down
```

This stops and removes the containers. **Your data is kept** — the next `make` will bring the site back exactly as you left it.

### Stop and erase all data

```bash
make clean
```

This removes and erases all named docker volumes registered to the stack. It will also call `make down` before doing anything

```bash
make fclean
```

This does the same as clean, however it also purges the entire project, and erases secrets and env variables

### Restart

```bash
make re
```

If you do not use `make`, the equivalent commands are:

```bash
docker compose -f srcs/docker-compose.yml up -d --build   # start
docker compose -f srcs/docker-compose.yml down            # stop
docker compose -f srcs/docker-compose.yml down -v         # stop and erase data
```

---

## 4. Accessing the website and the administration panel

| What | Address |
|---|---|
| Public website | `https://ibenne.42.fr` |
| Administration panel | `https://ibenne.42.fr/wp-admin` |

The certificate is self-signed, so your browser will show a security warning the first time. This is expected in a local or educational setup: choose *Advanced* → *Continue to the site*.

Log in on the administration page with the administrator account described in the next section. From there you can manage pages, posts, themes, plugins and user accounts.

---

## 5. Credentials

### Where they live

Credentials are **not** written into the code or into `docker-compose.yml`. They are read at start-up from:

```
srcs/.env         # environment variables (database name, hosts, users)
secrets           # password files, one secret per file, no newline
```

Both are excluded from version control by `.gitignore`. If you cloned the project, these files do not exist yet and you will have to create them, or use `make init`

### What has to be set

| Variable / file | Used by | Meaning |
|---|---|---|
| `DOMAIN_NAME` | nginx | Public domain of the site |
| `WP_DB_NAME` | mariadb | Name of the mariadb |
| `WP_DB_USER` | mariadb, wordpress | Non-root mariadb user |
| `WP_ADMIN_USER` | wordpress | Administrator login for the admin panel |
| `secrets/db_password.txt` | mariadb, wordpress | Password of that user |
| `secrets/db_root_password.txt` | mariadb | Database root password |
| `secrets/wp_admin_password.txt` | wordpress | Administrator password |

---

## 6. Checking that everything runs correctly

### Container status

```bash
docker compose -f srcs/docker-compose.yml ps
```

Every service should be `Up`. A container in `Restarting` is failing repeatedly — read its logs.

### Logs

```bash
make logs                                   # all services
docker logs -f <service-name>               # one service
```

### Quick checks

| Check | Command | Expected |
|---|---|---|
| Web server answers | `curl -kI https://ibenne.42.fr` | `HTTP/1.1 200 OK` |
| TLS version | `openssl s_client -connect ibenne.42.fr:443 -tls1_3` | Handshake succeeds |
| Database answers | `docker exec -it <mariadb container> mysqladmin ping -u root -p` | `mysqld is alive` |
| Data persists | `make down` then `make`, reload the site | Your content is still there |

### Common problems

| Symptom | Likely cause | Fix |
|---|---|---|
| Browser cannot reach the site | Domain not in `/etc/hosts` | Add the entry described in section 2 |
| `502 Bad Gateway` | Application container not ready yet, or crashed | Wait, then check its logs |
| "Error establishing a database connection" | Wrong credentials, or database still starting | Compare `.env` and `secrets/`, then `make re` |
| Port already in use on 443 | Another web server is running on the host | Stop it, or change the published port |
| Changes to `.env` have no effect | Containers still running with old values | `make re` |
