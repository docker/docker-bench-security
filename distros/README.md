# Distribution specific Dockerfiles

## Requirements

### Dockerfile name

The format should be `Dockerfile.{distribution name}`.

### Keep your images up-to-date

Use the distribution package manager to keep your image up-to-date.

### Labels

Use the following labels in your Dockerfile:

```
LABEL org.label-schema.name="docker-bench-security" \
      org.label-schema.url="<YOUR GIT REPOSITORY HTTPS ADDRESS>" \
      org.label-schema.vcs-url="<YOUR REPOSITORY HTTPS GIT ADDRESS"
```
