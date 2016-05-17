# Docker Bench for Security

![Docker Bench for Security running](https://raw.githubusercontent.com/docker/docker-bench-security/master/benchmark_log.png "Docker Bench for Security running")

The Docker Bench for Security is a script that checks for dozens of common best-practices around deploying Docker containers in production. The tests are all automated, and are inspired by the [CIS Docker 1.11 Benchmark](https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.11.0_Benchmark_v1.0.0.pdf). We are releasing this as a follow-up to our [Understanding Docker Security and Best Practices](https://blog.docker.com/2015/05/understanding-docker-security-and-best-practices/) blog post.

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

Docker bench requires Docker 1.10.0 or later in order to run.

Also note that the default image and `Dockerfile` uses `FROM: alpine` which doesn't contain `auditctl`, this will generate errors in section 1.8 to 1.18. Distribution specific Dockerfiles that fixes this issue are available in the [distros directory](https://github.com/docker/docker-bench-security/tree/master/distros).

The [distribution specific Dockerfiles](https://github.com/docker/docker-bench-security/tree/master/distros) may also help if the distribution you're using haven't yet shipped Docker version 1.10.0 or later.

## Running Docker Bench Bats tests

[Bats](https://github.com/sstephenson/bats) is a [TAP](http://testanything.org/)-compliant testing framework for Bash. It provides a simple way to verify that the UNIX programs you write behave as expected.

All Docker Bench scipts are also available as Bats tests. Also container level (and image level) tests are automatically generated for all containers avaiable on host. It's possible to run all or only selected test(s), if you like.

By default TAP test results are reported, but it's possible to produce a "pretty" printed output too.

Use the following command to run Docker Bench Bats tests:

```
Help documentation for run_tests.sh

Basic usage: run_tests.sh [-c] [-p|-t] [-o path] <test> [<test> ...]

Command line switches are optional. The following switches are recognized.
-c  --Displays number of tests. No further functions are performed.
-g  --Generates all CIS Bats tests without execution. No further functions are performed.
-p  --Show results in pretty format.
-t  --Show results in TAP format. This is the default format.
-t  --Create test results files: tests_<timestamp>.tap in test result folder.
-o  --Specify test result folder. Default to /var/docker-bench/results.
-h  --Displays this help message. No further functions are performed.

Example: run_tests.sh -t -o /var/docker-bench/results
```

You need to run `run_tests.sh` on Docker host as `root` user.

### Running Docker Bench Bats tests from Docker image

First, clone and compile your `docker-bench-tests` Docker image.

```sh
git clone https://github.com/gaia-adm/docker-bench-security.git
cd docker-bench-security
docker build -t docker-bench-tests -f bats.Dockerfile .
```

Then run `docker-bench-tests` container (as bellow). Test results will be saved into `/var/docker-bench` folder in TAP format. Test results file is named accoring to the `test_<timestamp>.tap` pattern.

```sh
docker run -it --net host --pid host --cap-add audit_control \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/lib/systemd:/usr/lib/systemd \
    -v /var/docker-bench:/var/docker-bench
    -v /etc:/etc --label docker_bench_security \
    docker-bench-tests
```
<<<<<<< HEAD
>>>>>>> update README.md file with info about running Bats tests
=======
>>>>>>> a888600cbb2c08e85ce279b335345e136d529f9b

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
