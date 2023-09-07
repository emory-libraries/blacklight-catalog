## Podman Setup

The following instructions will help you setup [Podman](https://github.com/containers/podman) and create containers for Solr and MySQL on your machine:

1. Install `podman` and `podman-compose`

```bash
# update brew
brew update

# install podman
brew install podman

# install podman-compose
brew install podman-compose
```

2. Initialize and start podman machine

```bash
# initialize podman machine
podman machine init

# start podman machine
podman machine start
```

3. Create and start containers

```bash
# create and start containers in detached mode. This may take a few minutes.
podman-compose up -d
```

#### Additional Instructions

To check which containers are currently running:

```bash
podman ps
```

To stop all running containers:

```bash
podman-compose down
```

To shutdown podman machine
```bash
podman machine stop
```
