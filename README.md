# Wine on Docker

A Docker image for [Wine](https://www.winehq.org) based on [Xubuntu on Docker](https://github.com/hectorm/docker-xubuntu).

## Start an instance

```sh
docker run \
  --name wine \
  --detach \
  --shm-size 2g \
  --publish 3322:3322/tcp \
  --publish 3389:3389/tcp \
  --device /dev/dri:/dev/dri \
  hectormolinero/wine:latest
```

> You will be able to connect to the container via SSH through 3322/tcp port and RDP through 3389/tcp port.

> **Important:** some software (like Firefox) need the shared memory to be increased, if you
encounter any problem related to this you may use the `--shm-size` option.

## Environment variables

* `UNPRIVILEGED_USER_UID`: unprivileged user UID (`1000` by default).
* `UNPRIVILEGED_USER_GID`: unprivileged user GID (`1000` by default).
* `UNPRIVILEGED_USER_NAME`: unprivileged user name (`wine` by default).
* `UNPRIVILEGED_USER_PASSWORD`: unprivileged user password (`password` by default).
* `UNPRIVILEGED_USER_GROUPS`: comma-separated list of additional GIDs for the unprivileged user (none by default).
* `UNPRIVILEGED_USER_SHELL`: unprivileged user shell (`/bin/bash` by default).
* `ENABLE_XDUMMY`: enable an X dummy server (`false` by default and requires the `--privileged` option).

## License

See the [license](LICENSE.md) file.
