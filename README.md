# Docker Bench for Security

![Docker Bench for Security running](https://raw.githubusercontent.com/docker/docker-bench-security/master/benchmark_log.png "Docker Bench for Security running")

The Docker Bench for Security is a script that checks for dozens of common
best-practices around deploying Docker containers in production. The tests are
all automated, and are inspired by the [CIS Docker Community Edition Benchmark v1.1.0](https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_Community_Edition_Benchmark_v1.1.0.pdf).
We are releasing this as a follow-up to our [Understanding Docker Security and Best Practices](https://blog.docker.com/2015/05/understanding-docker-security-and-best-practices/)
blog post.

We are making this available as an open-source utility so the Docker community
can have an easy way to self-assess their hosts and docker containers against
this benchmark.

## Running Docker Bench for Security

We packaged docker bench as a small container for your convenience. Note that
this container is being run with a *lot* of privilege -- sharing the host's
filesystem, pid and network namespaces, due to portions of the benchmark
applying to the running host. Don't forget to adjust the shared volumes
according to your operating system, for example it might not use systemd.

The easiest way to run your hosts against the Docker Bench for Security is by
running our pre-built container:

```sh
docker run -it --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/lib/systemd:/usr/lib/systemd \
    -v /etc:/etc --label docker_bench_security \
    docker/docker-bench-security
```

Docker bench requires Docker 1.13.0 or later in order to run.

Note that when distributions doesn't contain `auditctl`, the audit tests will
check `/etc/audit/audit.rules` to see if a rule is present instead.

Distribution specific Dockerfiles that fixes this issue are available in the
[distros directory](https://github.com/docker/docker-bench-security/tree/master/distros).

The [distribution specific Dockerfiles](https://github.com/docker/docker-bench-security/tree/master/distros)
may also help if the distribution you're using haven't yet shipped Docker
version 1.13.0 or later.

### Docker Bench for Security options

```sh
  -b           optional  Do not print colors
  -h           optional  Print this help message
  -l FILE      optional  Log output in FILE
  -c CHECK     optional  Comma delimited list of specific check(s)
  -e CHECK     optional  Comma delimited list of specific check(s) to exclude
  -i INCLUDE   optional  Comma delimited list of patterns within a container name to check
  -x EXCLUDE   optional  Comma delimited list of patterns within a container name to exclude from check
  -t TARGET    optional  Comma delimited list of images name to check
```

By default the Docker Bench for Security script will run all available CIS tests
and produce logs in the current directory named `docker-bench-security.sh.log.json`
and `docker-bench-security.sh.log`.
The CIS based checks are named `check_<section>_<number>`, e.g. `check_2_6`
and community contributed checks are named `check_c_<number>`.
A complete list of checks are present in [functions_lib.sh](functions_lib.sh).

`sh docker-bench-security.sh -l /tmp/docker-bench-security.sh.log -c check_2_2`
will only run check `2.2 Ensure the logging level is set to 'info'`.

`sh docker-bench-security.sh -l /tmp/docker-bench-security.sh.log -e check_2_2`
will run all available checks except `2.2 Ensure the logging level is set to 'info'`.

Note that when submitting checks, provide information why it is a
reasonable test to add and please include some kind of official documentation
verifying that information.

## Building Docker Bench for Security

If you wish to build and run this container yourself, you can follow the
following steps:

```sh
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
docker build --no-cache -t docker-bench-security .
docker run -it --net host --pid host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/lib/systemd:/usr/lib/systemd \
    -v /etc:/etc --label docker_bench_security \
    docker-bench-security
```

or use [Docker Compose](https://docs.docker.com/compose/):

```sh
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
docker-compose run --rm docker-bench-security
```

Also, this script can also be simply run from your base host by running:

```sh
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
sudo sh docker-bench-security.sh
```

This script was built to be POSIX 2004 compliant, so it should be portable
across any Unix platform.
