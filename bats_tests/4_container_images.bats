#!/usr/bin/env bats

load "test_helper/bats-support/load"
load "test_helper/bats-assert/load"

# 4.5
@test "4.5  - Enable Content trust for Docker" {
  assert [ "x$DOCKER_CONTENT_TRUST" = "x1" ]
}
