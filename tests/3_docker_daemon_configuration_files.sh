#!/bin/sh

logit "\n"
info "3 - Docker Daemon Configuration Files"

# 3.1
check_3_1="3.1  - Verify that docker.service file ownership is set to root:root"
file="$(get_systemd_service_file docker-registry.service)"
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
check_3_2="3.2  - Verify that docker.service file permissions are set to 644"
file="$(get_systemd_service_file docker-registry.service)"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 ]; then
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
check_3_3="3.3  - Verify that docker-registry.service file ownership is set to root:root"
file="$(get_systemd_service_file docker-registry.service)"
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
check_3_4="3.4  - Verify that docker-registry.service file permissions are set to 644"
file="$(get_systemd_service_file docker-registry.service)"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 ]; then
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
check_3_5="3.5  - Verify that docker.socket file ownership is set to root:root"
file="/usr/lib/systemd/system/docker.socket"
if [ -f "$file" ]; then
  if [ "$(stat -c %u%g $file)" -eq 00 ]; then
    pass "$check_3_5"
  else
    warn "$check_3_5"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_5"
  info "     * File not found"
fi

# 3.6
check_3_6="3.6  - Verify that docker.socket file permissions are set to 644"
file="/usr/lib/systemd/system/docker.socket"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 ]; then
    pass "$check_3_6"
  else
    warn "$check_3_6"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_6"
  info "     * File not found"
fi

# 3.7
check_3_7="3.7  - Verify that Docker environment file ownership is set to root:root "
file="/etc/sysconfig/docker"
if [ -f "$file" ]; then
  if [ "$(stat -c %u%g $file)" -eq 00 ]; then
    pass "$check_3_7"
  else
    warn "$check_3_7"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_7"
  info "     * File not found"
fi

# 3.8
check_3_8="3.8  - Verify that Docker environment file permissions are set to 644"
file="/etc/sysconfig/docker"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 ]; then
    pass "$check_3_8"
  else
    warn "$check_3_8"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_8"
  info "     * File not found"
fi

# 3.9
check_3_9="3.9  - Verify that docker-network environment file ownership is set to root:root"
file="/etc/sysconfig/docker-network"
if [ -f "$file" ]; then
  if [ "$(stat -c %u%g $file)" -eq 00 ]; then
    pass "$check_3_9"
  else
    warn "$check_3_9"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_9"
  info "     * File not found"
fi

# 3.10
check_3_10="3.10 - Verify that docker-network environment file permissions are set to 644"
file="/etc/sysconfig/docker-network"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 ]; then
    pass "$check_3_10"
  else
    warn "$check_3_10"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_10"
  info "     * File not found"
fi

# 3.11
check_3_11="3.11 - Verify that docker-registry environment file ownership is set to root:root"
file="/etc/sysconfig/docker-registry"
if [ -f "$file" ]; then
  if [ "$(stat -c %u%g $file)" -eq 00 ]; then
    pass "$check_3_11"
  else
    warn "$check_3_11"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_11"
  info "     * File not found"
fi

# 3.12
check_3_12="3.12 - Verify that docker-registry environment file permissions are set to 644"
file="/etc/sysconfig/docker-registry"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 ]; then
    pass "$check_3_12"
  else
    warn "$check_3_12"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_12"
  info "     * File not found"
fi

# 3.13
check_3_13="3.13 - Verify that docker-storage environment file ownership is set to root:root"
file="/etc/sysconfig/docker-storage"
if [ -f "$file" ]; then
  if [ "$(stat -c %u%g $file)" -eq 00 ]; then
    pass "$check_3_13"
  else
    warn "$check_3_13"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_13"
  info "     * File not found"
fi

# 3.14
check_3_14="3.14 - Verify that docker-storage environment file permissions are set to 644"
file="/etc/sysconfig/docker-storage"
if [ -f "$file" ]; then
  if [ "$(stat -c %a $file)" -eq 644 ]; then
    pass "$check_3_14"
  else
    warn "$check_3_14"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_14"
  info "     * File not found"
fi

# 3.15
check_3_15="3.15 - Verify that /etc/docker directory ownership is set to root:root"
directory="/etc/docker"
if [ -d "$directory" ]; then
  if [ "$(stat -c %u%g $directory)" -eq 00 ]; then
    pass "$check_3_15"
  else
    warn "$check_3_15"
    warn "     * Wrong ownership for $directory"
  fi
else
  info "$check_3_15"
  info "     * Directory not found"
fi

# 3.16
check_3_16="3.16 - Verify that /etc/docker directory permissions are set to 755"
directory="/etc/docker"
if [ -d "$directory" ]; then
  if [ "$(stat -c %a $directory)" -eq 755 ]; then
    pass "$check_3_16"
  elif [ "$(stat -c %a $directory)" -eq 700 ]; then
    pass "$check_3_16"
  else
    warn "$check_3_16"
    warn "     * Wrong permissions for $directory"
  fi
else
  info "$check_3_16"
  info "     * Directory not found"
fi

# 3.17
check_3_17="3.17 - Verify that registry certificate file ownership is set to root:root"
directory="/etc/docker/certs.d/"
if [ -d "$directory" ]; then
  fail=0
  owners=$(ls -lL $directory | grep ".crt" | awk '{print $3, $4}')
  for p in $owners; do
    printf "%s" "$p" | grep "root" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      fail=1
    fi
  done
  if [ $fail -eq 1 ]; then
    warn "$check_3_17"
    warn "     * Wrong ownership for $directory"
  else
    pass "$check_3_17"
  fi
else
  info "$check_3_17"
  info "     * Directory not found"
fi

# 3.18
check_3_18="3.18 - Verify that registry certificate file permissions are set to 444"
directory="/etc/docker/certs.d/"
if [ -d "$directory" ]; then
  fail=0
  perms=$(ls -lL $directory | grep ".crt" | awk '{print $1}')
  for p in $perms; do
    if [ "$p" != "-r--r--r--." -a "$p" = "-r--------." ]; then
      fail=1
    fi
  done
  if [ $fail -eq 1 ]; then
    warn "$check_3_18"
    warn "     * Wrong permissions for $directory"
  else
    pass "$check_3_18"
  fi
else
  info "$check_3_18"
  info "     * Directory not found"
fi

# 3.19
check_3_19="3.19 - Verify that TLS CA certificate file ownership is set to root:root"
tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
if [ -f "$tlscacert" ]; then
  if [ "$(stat -c %u%g "$tlscacert")" -eq 00 ]; then
    pass "$check_3_19"
  else
    warn "$check_3_19"
    warn "     * Wrong ownership for $tlscacert"
  fi
else
  info "$check_3_19"
  info "     * No TLS CA certificate found"
fi

# 3.20
check_3_20="3.20 - Verify that TLS CA certificate file permissions are set to 444"
tlscacert=$(get_docker_effective_command_line_args '--tlscacert' | sed -n 's/.*tlscacert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
if [ -f "$tlscacert" ]; then
  perms=$(ls -ld "$tlscacert" | awk '{print $1}')
  if [ "$perms" = "-r--r--r--" ]; then
    pass "$check_3_20"
  else
    warn "$check_3_20"
    warn "     * Wrong permissions for $tlscacert"
  fi
else
  info "$check_3_20"
  info "     * No TLS CA certificate found"
fi

# 3.21
check_3_21="3.21 - Verify that Docker server certificate file ownership is set to root:root"
tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
if [ -f "$tlscert" ]; then
  if [ "$(stat -c %u%g "$tlscert")" -eq 00 ]; then
    pass "$check_3_21"
  else
    warn "$check_3_21"
    warn "     * Wrong ownership for $tlscert"
  fi
else
  info "$check_3_21"
  info "     * No TLS Server certificate found"
fi

# 3.22
check_3_22="3.22 - Verify that Docker server certificate file permissions are set to 444"
tlscert=$(get_docker_effective_command_line_args '--tlscert' | sed -n 's/.*tlscert=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
if [ -f "$tlscert" ]; then
  perms=$(ls -ld "$tlscert" | awk '{print $1}')
  if [ "$perms" = "-r--r--r--" ]; then
    pass "$check_3_22"
  else
    warn "$check_3_22"
    warn "     * Wrong permissions for $tlscert"
  fi
else
  info "$check_3_22"
  info "     * No TLS Server certificate found"
fi

# 3.23
check_3_23="3.23 - Verify that Docker server key file ownership is set to root:root"
tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
if [ -f "$tlskey" ]; then
  if [ "$(stat -c %u%g "$tlskey")" -eq 00 ]; then
    pass "$check_3_23"
  else
    warn "$check_3_23"
    warn "     * Wrong ownership for $tlskey"
  fi
else
  info "$check_3_23"
  info "     * No TLS Key found"
fi

# 3.24
check_3_24="3.24 - Verify that Docker server key file permissions are set to 400"
tlskey=$(get_docker_effective_command_line_args '--tlskey' | sed -n 's/.*tlskey=\([^s]\)/\1/p' | sed 's/--/ --/g' | cut -d " " -f 1)
if [ -f "$tlskey" ]; then
  perms=$(ls -ld "$tlskey" | awk '{print $1}')
  if [ "$perms" = "-r--------" ]; then
    pass "$check_3_24"
  else
    warn "$check_3_24"
    warn "     * Wrong permissions for $tlskey"
  fi
else
  info "$check_3_24"
  info "     * No TLS Key found"
fi

# 3.25
check_3_25="3.25 - Verify that Docker socket file ownership is set to root:docker"
file="/var/run/docker.sock"
if [ -S "$file" ]; then
  if [ "$(stat -c %U:%G $file)" = 'root:docker' ]; then
    pass "$check_3_25"
  else
    warn "$check_3_25"
    warn "     * Wrong ownership for $file"
  fi
else
  info "$check_3_25"
  info "     * File not found"
fi

# 3.26
check_3_26="3.26 - Verify that Docker socket file permissions are set to 660"
file="/var/run/docker.sock"
if [ -S "$file" ]; then
  perms=$(ls -ld "$file" | awk '{print $1}')
  if [ "$perms" = "srw-rw----" ]; then
    pass "$check_3_26"
  else
    warn "$check_3_26"
    warn "     * Wrong permissions for $file"
  fi
else
  info "$check_3_26"
  info "     * File not found"
fi
