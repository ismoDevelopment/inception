*This project has been created as part of the 42 curriculum by ibenne*

# Inception

## Description

> The 42 school Inception project teaches you about Docker

- **Goal:** The goal of this project is to implement an LEMP (Linux, Nginx, Mariadb, PHP) stack in Docker.
- **Overview:** The docker compose file is made of 3 custom service implementations, one for the Database (MariaDB), one for installing Wordpress files and PHP-fpm, and lastly Nginx for Proxying PHP-fpm and serving certificates using OpenSSL

## Instructions

### Prerequisites

- Docker
- make
- Internet connection (for installing Debian image from docker hub)

### Installation

```bash
# Clone the repository
git clone https://github.com/ismoDevelopment/inception/
cd inception

# Set up environment variables and secrets (see Secrets vs Environment Variables below)

# .env example:
WP_DB_USER = YOUR_DB_USER
WP_DB_ROOTUSER = YOUR_ROOT_USER
WP_DB_NAME = YOUR_DB_NAME
DB_HOSTNAME = YOUR_DB_HOSTNAME
DOMAIN_NAME = ibenne.42.fr
DATA_FOLDER = /home/ismo/data

# insert your secrets into these files (without newline):
./secrets/db_root_password.txt 
./secrets/db_password.txt

```

### Build / execution

```bash
make

```

### Stopping / Cleaning

```bash
make down
make fclean
```

## Project Description

> This section explains key differences between Docker and VMs. Aswell the individual services in my docker-compose.yml

### Why docker?
Docker is used in this project to isolate the project from the  server/host computer's filesystem while still running on the same kernel. This secures 

### General Architecture

- Describe the overall architecture: which services/containers are used, how they communicate, and why they are structured this way.
- List the sources/images used (official images, custom Dockerfiles, base images, etc.) and justify the choices.

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker |
|---|---|---|
| Isolation | Full OS-level isolation (own kernel) | Process-level isolation (shared host kernel) |
| Resource usage | Heavier (allocates CPU/RAM/disk per VM) | Lightweight (shares host resources) |
| Startup time | Slow (boots a full OS) | Fast (starts a process) |
| Portability | Less portable, larger images | Highly portable, small images |
| Use case in this project | — | — |

> Explain why Docker was chosen (or required) for this project instead of VMs.

### Secrets vs Environment Variables

| Aspect | Secrets | Environment Variables |
|---|---|---|
| Storage | Encrypted, managed by orchestrator (e.g., Docker Secrets, Vault) | Stored in plain text (`.env`, shell, Compose file) |
| Visibility | Not exposed in `docker inspect` or process list | Visible via `docker inspect`, `/proc`, logs |
| Use case | Passwords, API keys, certificates | Non-sensitive configuration values |
| Approach used in this project | — | — |

> State which approach is used for which values in this project and why.

### Docker Network vs Host Network

| Aspect | Docker Network (bridge/custom) | Host Network |
|---|---|---|
| Isolation | Containers isolated from host network | Container shares host's network stack directly |
| Port mapping | Explicit port mapping required | No mapping needed, uses host ports directly |
| Security | More isolated, safer by default | Less isolated, higher exposure |
| Inter-container communication | Via container names/DNS on the same network | Relies on localhost, less container-friendly |
| Approach used in this project | — | — |

> Explain which network mode is used and why it fits the project's requirements.

### Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|---|---|---|
| Managed by | Docker | Host filesystem (explicit path) |
| Location | `/var/lib/docker/volumes/...` | Anywhere on the host |
| Portability | More portable, decoupled from host paths | Tied to host directory structure |
| Use case | Persistent data managed by Docker (databases, etc.) | Sharing host files/configs, development workflows |
| Approach used in this project | — | — |

> Explain which mechanism is used for persistence in this project and why.

## Resources

### Classic References

- [Official Docker Documentation](https://docs.docker.com/)
- Add relevant articles, tutorials, RFCs, or documentation specific to the project's topic.

### AI Usage

> Describe how AI tools were used during the project, specifying:
> - For which tasks (e.g., debugging, documentation drafting, boilerplate generation, research assistance)
> - Which parts of the project were impacted
> - To what extent the output was reviewed/modified by the team

Example:
- AI was used to help draft this README template and to clarify Docker networking concepts.
- AI was used to debug a specific error message during container startup.
- All AI-suggested code was reviewed, tested, and adapted by the team before inclusion.

## Additional Sections

> Add any project-specific sections required by the subject (e.g., Usage Examples, Feature List, Technical Choices).
