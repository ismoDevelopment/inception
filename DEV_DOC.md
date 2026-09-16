# Developer Documentation

> **Draft** — placeholders are marked `<LIKE_THIS>`. Replace them with the real values for your project before handing this in.

This document is for developers working on the stack itself. For day-to-day usage of the running site, see [USER_DOC.md](./USER_DOC.md).

---

## 1. Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Docker Engine | `29.7` or newer | Must include the `compose` plugin (`docker compose`, not `docker-compose`) |
| GNU Make | any recent | All workflows go through the Makefile |
| Git | any recent | |
| `openssl` | any recent | Used to generate the self-signed certificate |

Your user must be able to run Docker. On Linux, either add yourself to the `docker` group or prefix commands with `sudo`:

```bash
sudo usermod -aG docker $USER   # log out and back in afterwards
```

Add the domain to your hosts file (`/etc/hosts`), otherwise nothing will resolve:

```
127.0.0.1    <your-domain>
```

Ports `443` must be free on the host.

---

## 2. Repository layout

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                    # not in git — created by `make init`
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── wp_admin_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env                    # not in git — created by `make init`
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/          # entrypoint / setup scripts
        └── mariadb/
            ├── Dockerfile
            └── conf/
```

Each service has its own directory under `srcs/requirements/` containing a Dockerfile written from a `debian:bookworm` base image, its configuration files, and any entrypoint script. Images are built locally; no pre-built application image is pulled from a registry.

---

## 3. Setting up from scratch

### 3.1 Clone

```bash
git clone https://github.com/ismoDevelopment/inception.git
cd inception
```

### 3.2 Configuration files and secrets

Neither `srcs/.env` nor `secrets/` is tracked by git. They live in the host data directory and are copied into the project by:

```bash
make init
```

which performs:

```make
init:
	cp -r <DATA_DIR>/secrets ./secrets
	cp <DATA_DIR>/.env ./srcs/.env
```

`<DATA_DIR>` is currently hard-coded as `/home/ismo/data`. On any other machine, change it before running the rule — ideally make it overridable:

```make
DATA_DIR ?= $(HOME)/data
```

Note that `cp -r` overwrites without asking: treat the data directory as the source of truth and edit credentials there, not in the working copy.

#### Creating the files by hand

If you do not have the data directory, create them yourself.

`srcs/.env`:

| Variable | Used by | Meaning |
|---|---|---|
| `DOMAIN_NAME` | nginx | Public domain of the site |
| `WP_DB_NAME` | mariadb | Name of the mariadb |
| `WP_DB_USER` | mariadb, wordpress | Non-root mariadb user |
| `WP_ADMIN_USER` | wordpress | Administrator login for the admin panel |

`secrets/` — one password per file, no trailing newline:

| File | Used by | Meaning |
|---|---|---|
| `secrets/db_password.txt` | mariadb, wordpress | Password of that user |
| `secrets/db_root_password.txt` | mariadb | Database root password |
| `secrets/wp_admin_password.txt` | wordpress | Administrator password |


```bash
mkdir -p secrets
printf '%s' "$(openssl rand -base64 24)" > secrets/db_password.txt
printf '%s' "$(openssl rand -base64 24)" > secrets/db_root_password.txt
printf '%s' "$(openssl rand -base64 24)" > secrets/wp_admin_password.txt
printf '%s' "$(openssl rand -base64 24)" > secrets/wp_user_password.txt
```

Secrets are mounted into the containers through the Compose `secrets:` section and read from `/run/secrets/<name>` by the entrypoint scripts. They are deliberately **not** passed as environment variables, so they do not appear in `docker inspect` or in the image history.

### 3.3 Host data directories

The bind-mounted volumes point at directories that must exist before the first start:

```bash
mkdir -p <DATA_DIR>/mariadb <DATA_DIR>/wordpress
```

### 3.4 TLS certificate

The nginx image generates a self-signed certificate at build time via `openssl req -x509`, valid for `<DOMAIN_NAME>`. Nothing to do manually; expect a browser warning.

---

## 4. Building and launching

Everything goes through the Makefile, which wraps `docker compose -f srcs/docker-compose.yml`.

| Rule | What it does |
|---|---|
| `make` / `make all` | Build images if needed and start the stack detached |
| `make init` | Copy `.env` and `secrets/` from the data directory |
| `make up` | Start containers from existing images |
| `make re` | `down` then `all` — the usual rebuild loop |
| `make clean` | `down` plus remove the project's volumes |
| `make fclean` | `clean` plus purges the project's images |
Underlying commands, if you prefer to run Compose directly:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml down -v
```

### Build notes

- Images are built from a Dockerfile per service; `image:` is set so Compose reuses the local build instead of pulling.
- Layer caching means editing a config file usually does not trigger a rebuild of the package-install layer. When you suspect a stale layer: `make build` with `--no-cache`, or `make fclean && make`.
- `docker compose config` is the fastest way to check that `.env` substitution and secret paths resolved the way you expect.
- Startup order is handled by health checks and by the entrypoints retrying, not by assuming `depends_on` waits for readiness.

---

## 5. Managing containers and volumes

### Containers

```bash
docker ps -a                                 # what is running
docker compose -f srcs/docker-compose.yml ps # same, scoped to the project
docker exec -it <container> bash             # shell inside a container
docker logs -f --tail 100 <container>        # logs of one container
docker inspect <container>                   # full config, mounts, health
docker stats                                 # live CPU / memory
docker compose -f srcs/docker-compose.yml restart <service>
```

Useful one-offs:

```bash
# Check the database from inside the network
docker exec -it mariadb mariadb -u root -p

# Check what the app container resolves and reaches
docker exec -it wordpress ping -c1 <mariadb>

# Validate the nginx config after editing it
docker exec -it nginx nginx -t
```

### Volumes

```bash
docker volume ls
docker volume inspect srcs_<volume-name>
docker volume rm srcs__<volume-name>     # container must be stopped first
```

### Cleaning up

```bash
docker system df                 # how much space everything takes
docker image prune -f            # dangling images
docker system prune -af --volumes  # DESTRUCTIVE: everything not in use, on the whole machine
```

`make fclean` is the project-scoped version and should be preferred over `system prune`, which also removes unrelated work on your machine.

---

## 6. Where the data lives and how it persists

### The two volumes

| Volume | Mounted in | Container path | Host path |
|---|---|---|---|
| `mariadb-data` | database | `/var/lib/mysql` | `$DATA_FOLDER/mariadb` |
| `wordpress-data` | application, web server | `/var/www/html` | `$DATA_FOLDER/wordpress` |

Both are declared as named volumes with a `driver_opts` bind to a host directory:

```yaml
volumes:
  wordpress-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: $DATA_FOLDER/wordpress
```

This means the files are plain directories on the host — you can inspect and back them up with ordinary tools, and the host directory must exist before `up`, otherwise Docker fails with a mount error.

The application volume is shared between the app container (which writes PHP files and uploads) and the web server (which serves the static files), which is why both mount the same volume.

### What persists and what does not

| Action | Containers | Images | Volume data |
|---|---|---|---|
| `make down` | removed | kept | **kept** |
| `make re` | rebuilt | rebuilt | **kept** |
| `make clean` | removed | removed | **kept** |
| `make fclean` | removed | removed | **erased** |
| Host reboot | restarted per `restart:` policy | kept | **kept** |

Everything that matters — posts, pages, users, uploads, plugin state — is in those two directories. Anything written elsewhere inside a container (logs in `/var/log`, files in `/tmp`, packages installed by hand) is lost the moment the container is recreated. If a change needs to survive, it belongs in the Dockerfile, in a config file under `srcs/requirements/`, or in a volume.

### Verifying persistence

```bash
# create some content in the admin panel, then:
make down && make
# reload the site — the content must still be there
```

### Backup and restore

```bash
# Database dump
docker exec <mariadb> mariadb-dump -u root -p"$(cat secrets/db_root_password.txt)" \
  --all-databases > backup-$(date +%F).sql

# Files
tar czf wp-files-$(date +%F).tar.gz -C $DATA_FOLDER wordpress

# Restore the database into a running container
docker exec -i <mariadb> mariadb -u root -p"$(cat secrets/db_root_password.txt)" < backup.sql
```

A full reset from scratch, for testing that a clean install works end to end:

```bash
make fclean
mkdir -p $DATA_FOLDER$/mariadb $DATA_FOLDER/wordpress
make init && make
```

---

## 7. Conventions and gotchas

- Do not commit `srcs/.env`, `secrets/`, or anything under `<DATA_DIR>`. Check `.gitignore` before every commit.
- No hard-coded passwords in Dockerfiles, Compose files or scripts — the whole point of the secrets mechanism.
- Entrypoint scripts must run the service in the foreground (PID 1). No `systemd`, no background daemon plus `tail -f /dev/null`, or the container reports healthy while the service is dead.
- Use `restart: unless-stopped` (not `always`) so `make down` behaves predictably.
- The domain in `.env` must match the certificate's CN, otherwise the browser warning gets noisier than it needs to be.
- Only the web server publishes port 443; everything else communicates over the project's internal network.
