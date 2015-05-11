# Docker Security Benchmark Checker

The Docker Security Benchmark Checker is a script that checks for all the automatable tests included in the [CIS Docker 1.6 Benchmark](https://benchmarks.cisecurity.org/tools2/docker/CIS_Docker_1.6_Benchmark_v1.0.0.pdf). We are releasing this as a follow-up to our [Understanding Docker Security and Best Practices](https://blog.docker.com/2015/05/understanding-docker-security-and-best-practices/) blog post.

We are making this available as an open-source utility so the Docker community can have an easy way to self-assess their hosts and docker containers against this benchmark.

## Running the benchmark

We packaged this benchmark as a small container for your convenience. Note that this container is being run with a *lot* of privilege -- sharing the host's filesystem, pid and network namespaces, due to portions of the benchmark applying to the running host.

The easiest way to run your hosts against the CIS Docker 1.6 benchmark is by running our pre-built container:


```
docker run -it --net host --pid host -v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/lib/systemd:/usr/lib/systemd -v /etc:/etc diogomonica/docker-security-benchmark
```

## Building the benchmark

If you wish to build and run this container yourself, you can follow the following steps:

```
# git clone https://github.com/diogomonica/docker-security-benchmark.git
# cd docker-security-benchmark; docker build -t docker-security-benchmark .
# docker run run -it --net host --pid host -v /var/run/docker.sock:/var/run/docker.sock -v /usr/lib/systemd:/usr/lib/systemd -v /etc:/etc docker-security-benchmark
```

Also, this script can also be simply run from your base host by running:

```
# git clone https://github.com/diogomonica/docker-security-benchmark.git
# cd docker-security-benchmark; sh docker_security_benchmark.sh
```

This script was build to be POSIX 2004 compliant, so it should be portable across any Unix platform.
