# Security Hardening Scripts

Basic CIS-aligned hardening tasks for Linux hosts.

## Files
- `01_cis_base_hardening.sh` sysctl tuning and permissions for core system files
- `02_auditd_rules.sh` auditd rules for identity and exec tracking
- `03_patch_management.sh` enable `dnf-automatic` for security updates
- `04_ssh_hardening.sh` SSH configuration hardening
- `05_user_policy.sh` password aging and sudo policy

## Requirements
- Run as root
- `dnf`-based systems
- These scripts modify system configuration files

## Warning (possible lockout)
Running SSH hardening or user policy changes can lock you out if you do it before creating a non-root admin.
Create a wheel/sudo user and confirm SSH key login works before running `04_ssh_hardening.sh` or `05_user_policy.sh`.
If you disable password or root login without a working key-based admin account, you may lose SSH access.

## Suggested order
```bash
sudo ./01_cis_base_hardening.sh
sudo ./02_auditd_rules.sh
sudo ./03_patch_management.sh
sudo ./04_ssh_hardening.sh
sudo ./05_user_policy.sh
```
