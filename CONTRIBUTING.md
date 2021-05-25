# Contributing to Docker Bench for Security

Want to hack on Docker Bench? Awesome! Here are instructions to get you
started.

The Docker Bench for Security is a part of the [Docker](https://www.docker.com)
project, and follows the same rules and principles. If you're already familiar
with the way Docker does things, you'll feel right at home.

Otherwise, go read
[Contribute to the Moby Project](https://github.com/moby/moby/blob/master/CONTRIBUTING.md).

## Development Environment Setup

### Start hacking

You can build the container that wraps the docker-bench for security:

```sh
git clone git@github.com:docker/docker-bench-security.git
cd docker-bench-security
docker build -t docker-bench-security .
```

Or you can simply run the shell script locally:

```sh
git clone git@github.com:docker/docker-bench-security.git
cd docker-bench-security
sudo sh docker-bench-security.sh
```

The Docker Bench has the main script called `docker-bench-security.sh`.
This is the main script that checks for all the dependencies, deals with
command line arguments and loads all the tests.

The tests are split into the following files:

```sh
tests/
├── 1_host_configuration.sh
├── 2_docker_daemon_configuration.sh
├── 3_docker_daemon_configuration_files.sh
├── 4_container_images.sh
├── 5_container_runtime.sh
├── 6_docker_security_operations.sh
├── 7_docker_swarm_configuration.sh
├── 8_docker_enterprise_configuration.sh
└── 99_community_checks.sh
```

To modify the Docker Bench for Security you should first clone the repository,
make your changes, check your code with `shellcheck`, or similar tools, and
then sign off on your commits. After that feel free to send us a pull request
with the changes.

While this tool was inspired by the [CIS Docker 1.11.0 benchmark](https://www.cisecurity.org/benchmark/docker/)
and its successors, feel free to add new tests.
