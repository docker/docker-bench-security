# Distribution specific Dockerfiles

## Requirements

### Dockerfile name
The format should be `Dockerfile.{distribution name}`.  

### Keep your images up-to-date
Use the distribution package manager to keep your image up-to-date.

### REPOSITORY
Add a `REPOSITORY` comment with the URL to your GitHub repository where the Dockerfile is present.   
`# REPOSITORY <GitHub repository>`  

### MAINTAINER
Add the `MAINTAINER` instruction and your contact details, GitHub aliases are acceptable.   

## Example Dockerfile

```sh
# REPOSITORY https://github.com/docker/docker-bench-security

MAINTAINER dockerbench.com

FROM alpine:3.1

RUN apk update && \
    apk upgrade && \
    apk --update add docker

RUN mkdir /docker-bench-security

COPY . /docker-bench-security

WORKDIR /docker-bench-security

ENTRYPOINT ["/bin/sh", "docker-bench-security.sh"]
```
