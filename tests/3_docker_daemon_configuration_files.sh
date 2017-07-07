#!/bin/sh

logit "\n"
info "3 - Docker daemon configuration files"

# 3.1
check_3_1="3.1  - Ensure that docker.service file ownership is set to root:root"
file="$(get_systemd_service_file docker.service)"
if [ -f "$file" ]; then
  if [ "$(stat -c %u%g $file)" -eq 00 ]; then
    pass "$check_3_1"
  else
    warn "$check_3_1"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_1"
  info "     * File not found"
fi

# 3.2
check_3_2="3.2  - Ensure that docker.service file permissions are set to 644 or more restrictive"
file="$(get_systemd_service_file docker.service)"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 -o "$(stat -c %a $file)" -eq 600 ]; then
    pass "$check_3_2"
  else
    warn "$check_3_2"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_2"
  info "     * File not found"
fi

# 3.3
check_3_3="3.3  - Ensure that docker.socket file ownership is set to root:root"
file="$(get_systemd_service_file docker.socket)"
if [ -f "$file" ]; then
  if [ "$(stat -c %u%g $file)" -eq 00 ]; then
    pass "$check_3_3"
  else
    warn "$check_3_3"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_3"
  info "     * File not found"
fi

# 3.4
check_3_4="3.4  - Ensure that docker.socket file permissions are set to 644 or more restrictive"
file="$(get_systemd_service_file docker.socket)"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 -o "$(stat -c %a $file)" -eq 600 ]; then
    pass "$check_3_4"
  else
    warn "$check_3_4"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_4"
  info "     * File not found"
fi

# 3.5
check_3_5="3.5  - Ensure that /etc/docker directory ownership is set to root:root"
directory="/etc/docker"
if [ -d "$directory" ]; then
  if [ "$(stat -c %u%g $directory)" -eq 00 ]; then
    pass "$check_3_5"
  else
    warn "$check_3_5"
    warn "     * Wrong ownership for $directory"
  fi
else
  info "$check_3_5"
  info "     * Directory not found"
fi

# 3.6
check_3_6="3.6  - Ensure that /etc/docker directory permissions are set to 755 or more restrictive"
directory="/etc/docker"
if [ -d "$directory" ]; then
  if [ "$(stat -c %a $directory)" -eq 755 -o "$(stat -c %a $directory)" -eq 700 ]; then
    pass "$check_3_6"
  else
    warn "$check_3_6"
    warn "     * Wrong permissions for $directory"
  fi
else
  info "$check_3_6"
  info "     * Directory not found"
fi

# 3.7
check_3_7="3.7  - Ensure that registry certificate file ownership is set to root:root"
directory="/etc/docker/certs.d/"
if [ -d "$directory" ]; then
  fail=0
  owners=$(find "$directory" -type f -name '*.crt')
  for p in $owners; do
    if [ "$(stat -c %u $p)" -ne 0 ]; then
      fail=1
    fi
  done
  if [ $fail -eq 1 ]; then
    warn "$check_3_7"
    warn "     * Wrong ownership for $directory"
  else
    pass "$check_3_7"
  fi
else
  info "$check_3_7"
  info "     * Directory not found"
fi

# 3.8
check_3_8="3.8  - Ensure that registry certificate file permissions are set to 444 or more restrictive"
directory="/etc/docker/certs.d/"
if [ -d "$directory" ]; then
  fail=0
  perms=$(find "$directory" -type f -name '*.crt')
  for p in $perms; do
    if [ "$(stat -c %a $p)" -ne 444 -a "$(stat -c %a $p)" -ne 400 ]; then
      fail=1
    fi
  done
  if [ $fail -eq 1 ]; then
    warn "$check_3_8"
    warn "     * Wrong permissions for $directory"
  else
    pass "$check_3_8"
  fi
else
  info "$check_3_8"
  info "     * Directory not found"
fi

# 3.9
check_3_9="3.9  - Ensure that TLS CA certificate file ownership is set to root:root"
if ! [ -z $(get_docker_configuration_file_args 'tlscacert') ]; then
  tlscacert=$(get_docker_configuration_file_args 'tlscacert')
else
  tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
fi
if [ -f "$tlscacert" ]; then
  if [ "$(stat -c %u%g "$tlscacert")" -eq 00 ]; then
    pass "$check_3_9"
  else
    warn "$check_3_9"
    warn "     * Wrong ownership for $tlscacert"
  fi
else
  info "$check_3_9"
  info "     * No TLS CA certificate found"
fi

# 3.10
check_3_10="3.10 - Ensure that TLS CA certificate file permissions are set to 444 or more restrictive"
if ! [ -z $(get_docker_configuration_file_args 'tlscacert') ]; then
  tlscacert=$(get_docker_configuration_file_args 'tlscacert')
else
  tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
fi
if [ -f "$tlscacert" ]; then
  if [ "$(stat -c %a $tlscacert)" -eq 444 -o "$(stat -c %a $tlscacert)" -eq 400 ]; then
    pass "$check_3_10"
  else
    warn "$check_3_10"
    warn "     * Wrong permissions for $tlscacert"
  fi
else
  info "$check_3_10"
  info "     * No TLS CA certificate found"
fi

# 3.11
check_3_11="3.11 - Ensure that Docker server certificate file ownership is set to root:root"
if ! [ -z $(get_docker_configuration_file_args 'tlscert') ]; then
  tlscert=$(get_docker_configuration_file_args 'tlscert')
else
  tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
fi
if [ -f "$tlscert" ]; then
  if [ "$(stat -c %u%g "$tlscert")" -eq 00 ]; then
    pass "$check_3_11"
  else
    warn "$check_3_11"
    warn "     * Wrong ownership for $tlscert"
  fi
else
  info "$check_3_11"
  info "     * No TLS Server certificate found"
fi

# 3.12
check_3_12="3.12 - Ensure that Docker server certificate file permissions are set to 444 or more restrictive"
if ! [ -z $(get_docker_configuration_file_args 'tlscert') ]; then
  tlscert=$(get_docker_configuration_file_args 'tlscert')
else
  tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
fi
if [ -f "$tlscert" ]; then
  if [ "$(stat -c %a $tlscert)" -eq 444 -o "$(stat -c %a $tlscert)" -eq 400 ]; then
    pass "$check_3_12"
  else
    warn "$check_3_12"
    warn "     * Wrong permissions for $tlscert"
  fi
else
  info "$check_3_12"
  info "     * No TLS Server certificate found"
fi

# 3.13
check_3_13="3.13 - Ensure that Docker server certificate key file ownership is set to root:root"
if ! [ -z $(get_docker_configuration_file_args 'tlskey') ]; then
  tlskey=$(get_docker_configuration_file_args 'tlskey')
else
  tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
fi
if [ -f "$tlskey" ]; then
  if [ "$(stat -c %u%g "$tlskey")" -eq 00 ]; then
    pass "$check_3_13"
  else
    warn "$check_3_13"
    warn "     * Wrong ownership for $tlskey"
  fi
else
  info "$check_3_13"
  info "     * No TLS Key found"
fi

# 3.14
check_3_14="3.14 - Ensure that Docker server certificate key file permissions are set to 400"
if ! [ -z $(get_docker_configuration_file_args 'tlskey') ]; then
  tlskey=$(get_docker_configuration_file_args 'tlskey')
else
  tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
fi
if [ -f "$tlskey" ]; then
  if [ "$(stat -c %a $tlskey)" -eq 400 ]; then
    pass "$check_3_14"
  else
    warn "$check_3_14"
    warn "     * Wrong permissions for $tlskey"
  fi
else
  info "$check_3_14"
  info "     * No TLS Key found"
fi

# 3.15
check_3_15="3.15 - Ensure that Docker socket file ownership is set to root:docker"
file="/var/run/docker.sock"
if [ -S "$file" ]; then
  if [ "$(stat -c %U:%G $file)" = 'root:docker' ]; then
    pass "$check_3_15"
  else
    warn "$check_3_15"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_15"
  info "     * File not found"
fi

# 3.16
check_3_16="3.16 - Ensure that Docker socket file permissions are set to 660 or more restrictive"
file="/var/run/docker.sock"
if [ -S "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 660 -o "$(stat -c %a $file)" -eq 600 ]; then
    pass "$check_3_16"
  else
    warn "$check_3_16"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_16"
  info "     * File not found"
fi

# 3.17
check_3_17="3.17 - Ensure that daemon.json file ownership is set to root:root"
file="/etc/docker/daemon.json"
if [ -f "$file" ]; then
  if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
    pass "$check_3_17"
  else
    warn "$check_3_17"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_17"
  info "     * File not found"
fi

# 3.18
check_3_18="3.18 - Ensure that daemon.json file permissions are set to 644 or more restrictive"
file="/etc/docker/daemon.json"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 -o "$(stat -c %a $file)" -eq 600 ]; then
    pass "$check_3_18"
  else
    warn "$check_3_18"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_18"
  info "     * File not found"
fi

# 3.19
check_3_19="3.19 - Ensure that /etc/default/docker file ownership is set to root:root"
file="/etc/default/docker"
if [ -f "$file" ]; then
  if [ "$(stat -c %U:%G $file)" = 'root:root' ]; then
    pass "$check_3_19"
  else
    warn "$check_3_19"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_19"
  info "     * File not found"
fi

# 3.20
check_3_20="3.20 - Ensure that /etc/default/docker file permissions are set to 644 or more restrictive"
file="/etc/default/docker"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 -o "$(stat -c %a $file)" -eq 600 ]; then
    pass "$check_3_20"
  else
    warn "$check_3_20"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_20"
  info "     * File not found"
fi
