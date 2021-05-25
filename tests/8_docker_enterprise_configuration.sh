#!/bin/bash

check_8() {
  logit ""
  local id="8"
  local desc="Docker Enterprise Configuration"
  checkHeader="$id - $desc"
  info "$checkHeader"
  startsectionjson "$id" "$desc"
}

check_product_license() {
  enterprise_license=1
  if docker version | grep -Eqi '^Server.*Community$|Version.*-ce$'; then
    info "  * Community Engine license, skipping section 8"
    enterprise_license=0
  fi
}

check_8_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1"
  local desc="Universal Control Plane Configuration"
  local check="$id - $desc"
  info "$check"
}

check_8_1_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.1"
  local desc="Configure the LDAP authentication service (Automated)"
  local remediation="You can configure LDAP integration via the UCP Admin Settings UI. LDAP integration can also be enabled via a configuration file"
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_8_1_2() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.2"
  local desc="Use external certificates (Automated)"
  local remediation="You can configure your own certificates for UCP either during installation or after installation via the UCP Admin Settings user interface."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_8_1_3() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.3"
  local desc="Enforce the use of client certificate bundles for unprivileged users (Not Scored)"
  local remediation="Client certificate bundles can be created in one of two ways. User Management UI: UCP Administrators can provision client certificate bundles on behalf of users. Self-Provision: Users with access to the UCP console can create client certificate bundles themselves."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_8_1_4() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.4"
  local desc="Configure applicable cluster role-based access control policies (Not Scored)"
  local remediation="UCP RBAC components can be configured as required via the UCP User Management UI."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_8_1_5() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.5"
  local desc="Enable signed image enforcement (Automated)"
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_8_1_6() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.6"
  local desc="Set the Per-User Session Limit to a value of '3' or lower (Automated)"
  local remediation="Retrieve a UCP API token. Retrieve and save UCP config. Open the ucp-config.toml file, set the per_user_limit entry under the [auth.sessions] section to a value of 3 or lower, but greater than 0. Update UCP with the new configuration."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_8_1_7() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.1.7"
  local desc="Set the 'Lifetime Minutes' and 'Renewal Threshold Minutes' values to '15' or lower and '0' respectively (Automated)"
  local remediation="Retrieve a UCP API token. Retrieve and save UCP config. Open the ucp-config.toml file, set the lifetime_minutes and renewal_threshold_minutes entries under the [auth.sessions] section to values of 15 or lower and 0 respectively. Update UCP with the new configuration."
  local remediationImpact="Setting the Lifetime Minutes setting to a value that is too lower would result in users having to constantly re-authenticate to their Docker Enterprise cluster."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_8_2() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.2"
  local desc="Docker Trusted Registry Configuration"
  local check="$id - $desc"
  info "$check"
}

check_8_2_1() {
  if [ "$enterprise_license" -ne 1 ]; then
    return
  fi

  local id="8.2.1"
  local desc="Enable image vulnerability scanning (Automated)"
  local remediation="You can navigate to DTR Settings UI and select the Security tab to access the image scanning configuration. Select the Enable Scanning slider to enable this functionality."
  local remediationImpact="None."
  local check="$id - $desc"
  starttestjson "$id" "$desc"

  note -c "$check"
  logcheckresult "INFO"
}

check_8_end() {
  endsectionjson
}
