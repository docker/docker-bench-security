# Available Checks
Check ID | Category | Subcategory | Check Name 
------------ | ------------ | ------------ | ------------
`host_configuration` | Host Configuration
`host_general_configuration` |  | General Configuration
`check_1_1_1` | | |  Ensure the container host has been Hardened (Not Scored)
`check_1_1_2` | |  | Ensure that the version of Docker is up to date (Not Scored)
`linux_hosts_specific_configuration` | |  Linux Hosts Specific Configuration
`check_1_2_1` | |  | Ensure a separate partition for containers has been created (Scored)
`check_1_2_2` | |  | Ensure only trusted users are allowed to control Docker daemon (Scored)
`check_1_2_3` | |  | Ensure auditing is configured for the Docker daemon (Scored)
`check_1_2_4` | |  | Ensure auditing is configured for Docker files and directories - /var/lib/docker (Scored)
`check_1_2_5` | |  | Ensure auditing is configured for Docker files and directories - /etc/docker (Scored)
`check_1_2_6` | |  | Ensure auditing is configured for Docker files and directories - docker.service (Scored)
`check_1_2_7` | |  | Ensure auditing is configured for Docker files and directories - docker.socket (Scored)
`check_1_2_8` | |  | Ensure auditing is configured for Docker files and directories - /etc/default/docker (Scored)
`check_1_2_9` | |  | Ensure auditing is configured for Docker files and directories - /etc/sysconfig/docker (Scored)
`check_1_2_10` | |  | Ensure auditing is configured for Docker files and directories - /etc/docker/daemon.json (Scored)
`check_1_2_11` | |  | Ensure auditing is configured for Docker files and directories - /usr/bin/containerd (Scored)
`check_1_2_12` | |  | Ensure auditing is configured for Docker files and directories - /usr/sbin/runc (Scored)
`docker_daemon_configuration` | Docker daemon configuration
`check_2_1` |  | Ensure network traffic is restricted between containers on the default bridge (Scored)
`check_2_2` |  | Ensure the logging level is set to 'info' (Scored)
`check_2_3` |  | Ensure Docker is allowed to make changes to iptables (Scored)
`check_2_4` |  | Ensure insecure registries are not used (Scored)
`check_2_5` |  | Ensure aufs storage driver is not used (Scored)
`check_2_6` |  | Ensure TLS authentication for Docker daemon is configured (Scored)
`check_2_7` |  | Ensure the default ulimit is configured appropriately (Not Scored)
`check_2_8` |  | Enable user namespace support (Scored)
`check_2_9` |  | Ensure the default cgroup usage has been confirmed (Scored)
`check_2_10` |  | Ensure base device size is not changed until needed (Scored)
`check_2_11` |  | Ensure that authorization for Docker client commands is enabled (Scored)
`check_2_12` |  | Ensure centralized and remote logging is configured (Scored)
`check_2_13` |  | Ensure live restore is enabled (Scored)
`check_2_14` |  | Ensure Userland Proxy is Disabled (Scored)
`check_2_15` |  | Ensure that a daemon-wide custom seccomp profile is applied if appropriate (Not Scored)
`check_2_16` |  | Ensure that experimental features are not implemented in production (Scored)
`check_2_17` |  | Ensure containers are restricted from acquiring new privileges (Scored)
`docker_daemon_files` | Docker daemon configuration files
`check_3_1` |  | Ensure that the docker.service file ownership is set to root:root (Scored)
`check_3_2` |  | Ensure that docker.service file permissions are appropriately set (Scored)
`check_3_3` |  | Ensure that docker.socket file ownership is set to root:root (Scored)
`check_3_4` |  | Ensure that docker.socket file permissions are set to 644 or more restrictive (Scored)
`check_3_5` |  | Ensure that the /etc/docker directory ownership is set to root:root (Scored)
`check_3_6` |  | Ensure that /etc/docker directory permissions are set to 755 or more restrictively (Scored)
`check_3_7` |  | Ensure that registry certificate file ownership is set to root:root (Scored)
`check_3_8` |  | Ensure that registry certificate file permissions are set to 444 or more restrictively (Scored)
`check_3_9` |  | Ensure that TLS CA certificate file ownership is set to root:root (Scored)
`check_3_10` |  | Ensure that TLS CA certificate file permissions are set to 444 or more restrictively (Scored)
`check_3_11` |  | Ensure that Docker server certificate file ownership is set to root:root (Scored)
`check_3_12` |  | Ensure that the Docker server certificate file permissions are set to 444 or more restrictively (Scored)
`check_3_13` |  | Ensure that the Docker server certificate key file ownership is set to root:root (Scored)
`check_3_14` |  | Ensure that the Docker server certificate key file permissions are set to 400 (Scored)
`check_3_15` |  | Ensure that the Docker socket file ownership is set to root:docker (Scored)
`check_3_16` |  | Ensure that the Docker socket file permissions are set to 660 or more restrictively (Scored)
`check_3_17` |  | Ensure that the daemon.json file ownership is set to root:root (Scored)
`check_3_18` |  | Ensure that daemon.json file permissions are set to 644 or more restrictive (Scored)
`check_3_19` |  | Ensure that the /etc/default/docker file ownership is set to root:root (Scored)
`check_3_20` |  | Ensure that the /etc/sysconfig/docker file ownership is set to root:root (Scored)
`check_3_21` |  | Ensure that the /etc/sysconfig/docker file permissions are set to 644 or more restrictively (Scored)
`check_3_22` |  | Ensure that the /etc/default/docker file permissions are set to 644 or more restrictively (Scored)
`container_images` | Container Images and Build File
`check_4.1` |  | Ensure that a user for the container has been created (Scored)
`check_4.2` |  | Ensure that containers use only trusted base images (Not Scored)
`check_4.3` |  | Ensure that unnecessary packages are not installed in the container (Not Scored)
`check_4.4` |  | Ensure images are scanned and rebuilt to include security patches (Not Scored)
`check_4.5` |  | Ensure Content trust for Docker is Enabled (Scored)
`check_4.6` |  | Ensure that HEALTHCHECK instructions have been added to container images (Scored)
`check_4.7` |  | Ensure update instructions are not used alone in the Dockerfile (Not Scored)
`check_4.8` |  | Ensure setuid and setgid permissions are removed (Not Scored)
`check_4.9` |  | Ensure that COPY is used instead of ADD in Dockerfiles (Not Scored)
`check_4.10` |  | Ensure secrets are not stored in Dockerfiles (Not Scored)
`check_4.11` |  | Ensure only verified packages are are installed (Not Scored)
`container_runtime` | Container Runtime
`check_running_containers` | | Check if exists running containers
`check_5_1` | | Ensure that, if applicable, an AppArmor Profile is enabled (Scored)
`check_5_2` | | Ensure that, if applicable, SELinux security options are set (Scored)
`check_5_3` | | Ensure that Linux kernel capabilities are restricted within containers (Scored)
`check_5_4` | | Ensure that privileged containers are not used (Scored)
`check_5_5` | | Ensure sensitive host system directories are not mounted on containers (Scored)
`check_5_6` | | Ensure sshd is not run within containers (Scored)
`check_5_7` | | Ensure privileged ports are not mapped within containers (Scored)
`check_5_8` | | Ensure that only needed ports are open on the container (Not Scored)
`check_5_9` | | Ensure that the host's network namespace is not shared (Scored)
`check_5_10` | | Ensure that the memory usage for containers is limited (Scored)
`check_5_11` | | Ensure that CPU priority is set appropriately on containers (Scored)
`check_5_12` | | Ensure that the container's root filesystem is mounted as read only (Scored)
`check_5_13` | | Ensure that incoming container traffic is bound to a specific host interface (Scored)
`check_5_14` | | Ensure that the 'on-failure' container restart policy is set to '5' (Scored)
`check_5_15` | | Ensure that the host's process namespace is not shared (Scored)
`check_5_16` | | Ensure that the host's IPC namespace is not shared (Scored)
`check_5_17` | | Ensure that host devices are not directly exposed to containers (Not Scored)
`check_5_18` | | Ensure that the default ulimit is overwritten at runtime if needed (Not Scored)
`check_5_19` | | Ensure mount propagation mode is not set to shared (Scored)
`check_5_20` | | Ensure that the host's UTS namespace is not shared (Scored)
`check_5_21` | | Ensurethe default seccomp profile is not Disabled (Scored)
`check_5_22` | | Ensure that docker exec commands are not used with the privileged option (Scored)
`check_5_23` | | Ensure that docker exec commands are not used with the user=root option (Not Scored)
`check_5_24` | | Ensure that cgroup usage is confirmed (Scored)
`check_5_25` | | Ensure that the container is restricted from acquiring additional privileges (Scored)
`check_5_26` | | Ensure that container health is checked at runtime (Scored)
`check_5_27` | | Ensure that Docker commands always make use of the latest version of their image (Not Scored)
`check_5_28` | | Ensure that the PIDs cgroup limit is used (Scored)
`check_5_29` | | Ensure that Docker's default bridge docker0 is not used (Not Scored)
`check_5_30` | | Ensure that the host's user namespaces are not shared (Scored)
`check_5_31` | | Ensure that the Docker socket is not mounted inside any containers (Scored)
`docker_security_operations` | Docker Security Operations
`check_6.1` |  | Ensure that image sprawl is avoided (Not Scored)
`check_6.2` |  | Ensure that container sprawl is avoided (Not Scored)
`docker_swarm_configuration` | Docker Swarm Configuration
`check_7.1` | | Ensure swarm mode is not Enabled, if not needed (Scored)
`check_7.2` | | Ensure that the minimum number of manager nodes have been created in a swarm (Scored) (Swarm mode not enabled)
`check_7.3` | | Ensure that swarm services are bound to a specific host interface (Scored) (Swarm mode not enabled)
`check_7.4` | | Ensure that all Docker swarm overlay networks are encrypted (Scored)
`check_7.5` | | Ensure that Docker's secret management commands are used for managing secrets in a swarm cluster (Not Scored) (Swarm mode not enabled)
`check_7.6` | | Ensure that swarm manager is run in auto-lock mode (Scored) (Swarm mode not enabled)
`check_7.7` | | Ensure that the swarm manager auto-lock key is rotated periodically (Not Scored) (Swarm mode not enabled)
`check_7.8` | | Ensure that node certificates are rotated as appropriate (Not Scored) (Swarm mode not enabled)
`check_7.9` | | Ensure that CA certificates are rotated as appropriate (Not Scored) (Swarm mode not enabled)
`check_7.10` | | Ensure that management plane traffic is separated from data plane traffic (Not Scored) (Swarm mode not enabled)
`docker_enterprise_configuration` | Docker Enterprise Configuration
`check_product_license` | | Check Docker license
`universal_control_plane_configuration` | | Universal Control Plane Configuration
`check_8.1.1` | | | Configure the LDAP authentication service (Scored)
`check_8.1.2` | | | Use external certificates (Scored)
`check_8.1.3` | | | Enforce the use of client certificate bundles for unprivileged users (Not Scored)
`check_8.1.4` | | | Configure applicable cluster role-based access control policies (Not Scored)
`check_8.1.5` | | | Enable signed image enforcement (Scored)
`check_8.1.6` | | | Set the Per-User Session Limit to a value of '3' or lower (Scored)
`check_8.1.7` | | | Set the 'Lifetime Minutes' and 'Renewal Threshold Minutes' values to '15' or lower and '0' respectively (Scored)
`docker_trusted_registry_configuration` | | Docker Trusted Registry Configuration
`check_8.2.1` | | | Enable image vulnerability scanning (Scored)
`community_checks` | Community contributed checks
`check_c_1` | | This is a example check
`check_c_2` | | Ensure operations on legacy registry (v1) are Disabled (Deprecated)

## Another Check ID are:
- `community_checks` -> Run all community checks
- `community` -> Is an alias for `community_checks`
- `cis` -> Run all bellow checks category:
  - `host_configuration`
  - `docker_daemon_configuration`
  - `docker_daemon_files`
  - `container_images`
  - `container_runtime`
  - `docker_security_operations`
  - `docker_swarm_configuration`
  - `docker_enterprise_configuration`
- `all` -> Run all bellow checks category:
  - `cis`
  - `community`
- `cis_level1` -> Run all bellow checks:
  - `host_configuration_level1`
  - `docker_daemon_configuration_level1`
  - `docker_daemon_files_level1`
  - `container_images_level1`
  - `container_runtime_level1`
  - `docker_security_operations_level1`
  - `docker_swarm_configuration_level1`
  - `docker_enterprise_configuration_level1`
- `host_configuration_level1` -> Run all bellow checks:
  - `check_1_1_1`
  - `check_1_1_2`
  - `check_1_2_1`
  - `check_1_2_2`
  - `check_1_2_3`
  - `check_1_2_5`
  - `check_1_2_6`
  - `check_1_2_7`
  - `check_1_2_8`
  - `check_1_2_9`
  - `check_1_2_10`
  - `check_1_2_11`
  - `check_1_2_12`
- `docker_daemon_configuration_level1` -> Run all bellow checks:
  - `check_2_1`
  - `check_2_2`
  - `check_2_3`
  - `check_2_4`
  - `check_2_5`
  - `check_2_6`
  - `check_2_7`
  - `check_2_13`
  - `check_2_14`
  - `check_2_16`
  - `check_2_17`
- `docker_daemon_files_level1` -> Run all bellow checks:
  - `check_3_1`
  - `check_3_2`
  - `check_3_3`
  - `check_3_4`
  - `check_3_5`
  - `check_3_6`
  - `check_3_7`
  - `check_3_8`
  - `check_3_9`
  - `check_3_10`
  - `check_3_11`
  - `check_3_12`
  - `check_3_13`
  - `check_3_14`
  - `check_3_15`
  - `check_3_16`
  - `check_3_17`
  - `check_3_18`
  - `check_3_19`
  - `check_3_20`
  - `check_3_21`
  - `check_3_22`
- `container_images_level1` -> Run all bellow checks:
  - `check_4_1`
  - `check_4_2`
  - `check_4_3`
  - `check_4_4`
  - `check_4_6`
  - `check_4_7`
  - `check_4_9`
  - `check_4_10`
- `container_runtime_level1` -> Run all bellow checks:
  - `check_running_containers`
  - `check_5_1`
  - `check_5_3`
  - `check_5_4`
  - `check_5_5`
  - `check_5_6`
  - `check_5_7`
  - `check_5_8`
  - `check_5_9`
  - `check_5_10`
  - `check_5_11`
  - `check_5_12`
  - `check_5_13`
  - `check_5_14`
  - `check_5_15`
  - `check_5_16`
  - `check_5_17`
  - `check_5_18`
  - `check_5_19`
  - `check_5_20`
  - `check_5_21`
  - `check_5_24`
  - `check_5_25`
  - `check_5_26`
  - `check_5_27`
  - `check_5_28`
  - `check_5_30`
  - `check_5_31`
- `docker_security_operations_level1` -> Run all bellow checks:
  - `check_6_1`
  - `check_6_2`
- `docker_swarm_configuration_level1` -> Run all bellow checks:
  - `check_7_1`
  - `check_7_2`
  - `check_7_3`
  - `check_7_4`
  - `check_7_7`
- `docker_enterprise_configuration_level1` -> Run all bellow checks:
  - `check_product_license`
  - `check_8_1_1`
  - `check_8_1_2`
  - `check_8_1_3`
  - `check_8_1_4`
  - `check_8_1_5`
  - `check_8_1_6`
  - `check_8_1_7`
  - `check_8_2_1`
