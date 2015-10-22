# Docker Bench for Security

![Docker Bench for Security running](https://github.com/diogomonica/docker-bench-security/raw/master/benchmark_log.png?raw=true "Docker Bench for Security running")

The Docker Bench for Security is a script that checks for dozens of common best-practices around deploying Docker containers in production. The tests are all automated, and are inspired by the [CIS Docker 1.6 Benchmark](https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.6_Benchmark_v1.0.0.pdf). We are releasing this as a follow-up to our [Understanding Docker Security and Best Practices](https://blog.docker.com/2015/05/understanding-docker-security-and-best-practices/) blog post.

We are making this available as an open-source utility so the Docker community can have an easy way to self-assess their hosts and docker containers against this benchmark.

## Running Docker Bench for Security

We packaged docker bench as a small container for your convenience. Note that this container is being run with a *lot* of privilege -- sharing the host's filesystem, pid and network namespaces, due to portions of the benchmark applying to the running host.

The easiest way to run your hosts against the Docker Bench for Security is by running our pre-built container:


```sh
docker run -it --net host --pid host --cap-add audit_control \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/lib/systemd:/usr/lib/systemd \
    -v /etc:/etc --label docker_bench_security \
    docker/docker-bench-security
```

Docker bench requires Docker 1.6.2 or later in order to run, since it depends on the `--label` to exclude the current container from being inspected. If you can't upgrade to 1.6.2, feel free to remove the `--label` flag or run the shell script locally (see below).

Additionally, there was a bug in Docker 1.6.0 that would not allow mounting `-v /dev:/dev`. If you are getting an error while accessing `resolv.conf`, please update your docker to 1.6.2.  
Also note that the default image and `Dockerfile` uses `FROM: alpine` which doesn't contain `auditctl`, this will generate errors in section 1.8 to 1.18. Distribution specific Dockerfiles that fixes this issue are available in the [distros directory](https://github.com/docker/docker-bench-security/tree/master/distros).

## Building Docker Bench for Security

If you wish to build and run this container yourself, you can follow the following steps:

```sh
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
docker build -t docker-bench-security .
docker run -it --net host --pid host --cap-add audit_control \
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
sh docker-bench-security.sh
```

This script was build to be POSIX 2004 compliant, so it should be portable across any Unix platform.
