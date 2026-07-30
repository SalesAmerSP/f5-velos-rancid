# F5 VELOS RANCID Custom Integration & Backup Solution

This repository provides a custom **RANCID (v3.x)** integration to automate both **textual configuration change tracking** (via Git/SVN diffs) and **bare-metal binary database backups** (via XML and UCS archives) for an **F5 VELOS Chassis** (with two blades, dual system controllers, chassis partitions, and running TMOS tenants).

---

## 📋 Table of Contents
1. [Architecture Overview](#-architecture-overview)
2. [Included Files & Directory Layout](#-directory-layout)
3. [Installation & Setup](#-installation--setup)
4. [Custom Device Type Configuration](#-custom-device-type-configuration)
5. [How to Run Text-Based Backups](#-how-to-run-text-based-backups)
6. [How to Trigger Official XML/UCS Database Backups](#-how-to-trigger-official-xmlucs-database-backups)
7. [Backup Recovery Verification](#-backup-recovery-verification)

---

## 🏗️ Architecture Overview

The F5 VELOS platform utilizes a layered, microservices-based operating system called **F5OS-C** on its controllers and chassis partitions, while running standard **TMOS (BIG-IP)** on individual tenants inside those partitions. Standard RANCID has no native support for the new ConfD-based F5OS CLI.

This project delivers a complete native RANCID extension:
- **`f5os` custom device type**: Maps CLI commands natively for pagination suppression and data gathering.
- **`f5os.pm` Perl parser module**: Intelligently cleans up, filters out oscillating state values (like dynamic cluster health up-time and event timestamps), and extracts running-config databases cleanly.

---

## 📂 Directory Layout

```text
├── README.md               # This comprehensive documentation guide
├── .gitignore              # Ignores local compilation files & environment folders
├── rancid_install/         # RANCID Local Installation Dir (Compiled Locally)
│   ├── etc/
│   │   ├── rancid.types.conf # Custom f5os device types added here
│   │   ├── cloginrc.velos   # Login credentials configuration template
│   │   └── router.db.velos  # Inventory matching controllers and partitions
│   └── lib/rancid/
│       └── f5os.pm          # Custom Perl parser for F5OS logs/prompts
└── sample_backups/         # Verified backup samples retrieved from live test
    ├── controller_backup.xml           # Active System Controller DB Backup (XML)
    ├── partition_backup.xml            # Active Chassis Partition DB Backup (XML)
    ├── sample_controller_backup.txt    # Parser-filtered controller text
    └── sample_floating_controller_backup.txt # Parser-filtered floating controller text
```

---

## 🚀 Installation & Setup

If setting up this solution on a new system:

### 1. Prereqs (Compile RANCID Locally)
Download, compile, and install RANCID (version 3.14 is verified and recommended):
```bash
curl -L -O https://shrubbery.net/pub/rancid/rancid-3.14.tar.gz
tar -zxf rancid-3.14.tar.gz
cd rancid-3.14
./configure --prefix=/path/to/your/rancid_install
make && make install
```

### 2. Copy the Custom Module
Move the custom Perl module `f5os.pm` from this repo into your RANCID library directory:
```bash
cp rancid_install/lib/rancid/f5os.pm <rancid-lib-dir>/rancid/
```

---

## ⚙️ Custom Device Type Configuration

To enable the `f5os` device type in your RANCID installation, add the following lines to your `rancid.types.conf` (normally located under `etc/rancid.types.conf`):

```text
# F5OS (VELOS System Controllers and Chassis Partitions)
f5os;script;rancid -t f5os
f5os;login;clogin
f5os;module;f5os
f5os;inloop;f5os::inloop
f5os;command;rancid::RunCommand;paginate false
f5os;command;rancid::RunCommand;screen-length 0
f5os;command;f5os::ShowVersion;show system version
f5os;command;f5os::ShowImage;show system image
f5os;command;f5os::ShowCluster;show cluster cluster-status
f5os;command;f5os::ShowTenants;show tenants
f5os;command;f5os::ShowComponents;show components
f5os;command;f5os::WriteTerm;show running-config
```

---

## 📝 How to Run Text-Based Backups

RANCID tracks line-by-line configuration changes in Git or SVN. Follow these steps to execute a run:

### 1. Set Up Credentials (`~/.cloginrc`)
Copy the template `cloginrc.velos` to your home directory, add your administrator password (`F5bigip!F5bigip`), and restrict permissions:
```bash
cp rancid_install/etc/cloginrc.velos ~/.cloginrc
chmod 600 ~/.cloginrc
```

### 2. Configure Host Inventory (`router.db`)
Configure the `router.db` with your VELOS IP addresses using the `f5os` or `bigip` types:
```text
# Format: hostname;type;status
192.0.2.36;f5os;up;velos-chassis-1-sys-controller-floating-ip
192.0.2.35;f5os;up;velos-chassis-1-sys-controller-1
192.0.2.37;f5os;up;velos-chassis-1-sys-controller-2
192.0.2.38;f5os;up;velos-chassis-1-partition-1
192.0.2.39;bigip;up;velos-chassis-1-tenant-1
```

### 3. Run the Native RANCID Collector
Trigger the backup execution using the native `rancid-run` executable:
```bash
/path/to/rancid_install/bin/rancid-run
```

---

## 💾 How to Trigger Official XML/UCS Database Backups

For bare-metal restore scenarios, you can use RANCID's native interactive execution tool (`clogin`) to generate and export binary database backups from the CLI **without** needing external scripts.

### 1. Backup F5OS System Controllers (XML Backup)
Connects to the floating controller management IP, creates a database backup file, and exports it:
```bash
/path/to/rancid_install/bin/clogin -c "config; system database config-backup name controller_backup.xml; exit; file export local-file configs/controller_backup.xml remote-file /tmp/controller_backup.xml remote-host <SFTP_SERVER> username <SFTP_USER>" 192.0.2.36
```

### 2. Backup F5OS Chassis Partitions (XML Backup)
Connects to the chassis partition management IP, creates a partition database backup (which includes all tenant allocations), and exports it:
```bash
/path/to/rancid_install/bin/clogin -c "config; system database config-backup name partition_backup.xml; exit; file export local-file configs/partition_backup.xml remote-file /tmp/partition_backup.xml remote-host <SFTP_SERVER> username <SFTP_USER>" 192.0.2.38
```

### 3. Backup BIG-IP Tenants (UCS Archive Save)
Triggers a complete TMOS configuration save on the tenant VM:
```bash
/path/to/rancid_install/bin/clogin -c "tmsh save /sys ucs tenant_backup.ucs" 192.0.2.39
```

---

## 🔍 Backup Recovery Verification

Real-world verified files are committed inside this repository's [sample_backups/](sample_backups/) directory as active references:
- **`controller_backup.xml`**: Active System Controller backup detailing global management, SNMP, cluster structures, and physical blades configuration.
- **`partition_backup.xml`**: Active Partition-level backup containing virtual settings and tenant resource deployments.
- **`sample_controller_backup.txt`**: Normal text configuration parsed and filtered via `f5os.pm` to prevent dynamic health alerts from causing Git noise.

---

## 🔄 F5OS-C System-to-System Configuration Migration

When performing system replacements, Return Material Authorizations (RMA), or aligning multiple system controllers, you can migrate the system controller configuration from a source system to a destination system via the CLI.

> [!IMPORTANT]
> F5 does **not** support migrating chassis partition configurations independently from one system to another. You must migrate the entire system controller configuration first, and then log in to each chassis partition to restore its configuration.

### 🔑 Cryptographic Alignment (The Primary Key Passphrase)
For encrypted configuration elements (like administrator credentials, SNMP communities, and secrets) to migrate successfully, both the source and destination systems **must** share the same Primary Encryption Key.

#### 1. Set the Primary Key on both systems:
Log in to the system controller CLI as `admin`, enter config mode, and configure matching passphrases and salts:
```text
config
system aaa primary-key set passphrase <KnownPassphrase> confirm-passphrase <KnownPassphrase> salt <KnownSalt> confirm-salt <KnownSalt>
end
```

#### 2. Verify key alignment:
Verify that the status displays `COMPLETE` and that the hashes match exactly on both systems:
```text
show system aaa primary-key state status
show system aaa primary-key state hash
```

### 💾 Backup, Export, and Restore Sequence

#### 1. Create the XML Backup on the Source Controller:
```text
system database config-backup name controller_migration.xml
```

#### 2. Export the Backup File onto a Remote Server:
```text
file export local-file configs/controller_migration.xml remote-file /tmp/controller_migration.xml remote-host 192.0.2.1 username root
```

#### 3. Import the Backup File on the Destination Controller:
```text
file import local-file configs/controller_migration.xml remote-file /tmp/controller_migration.xml remote-host 192.0.2.1 username root
```

#### 4. Load the configuration on the Destination System:
```text
system database config-restore name controller_migration.xml
```
*Note: If the migration fails for any reason, the system automatically rolls back to the previous configuration.*

---

## 🔗 Official F5 Technical Documentation References

For full, vendor-authorized compliance guidelines, consult the following official F5 manual directories:

* **[F5 VELOS Systems: Backup, Restore, and Migration (Master Index)](https://techdocs.f5.com/en-us/velos-1-5-0/velos-systems-backup-restore-migration.html)** — Comprehensive landing directory detailing entire platform recovery operations.
* **[Back Up F5OS System Configurations](https://techdocs.f5.com/en-us/velos-1-5-0/velos-systems-backup-restore-migration/back-up-system-config.html)** — Official operational standards for triggering system controller and chassis partition backups (from both GUI and CLI).
* **[Restore F5OS to a Previous Configuration](https://techdocs.f5.com/en-us/velos-1-5-0/velos-systems-backup-restore-migration/restore-system.html)** — Official procedure for loading XML databases or resetting a chassis back to factory defaults via console connection.
* **[Migrate F5OS Configurations (System-to-System)](https://techdocs.f5.com/en-us/velos-1-5-0/velos-systems-backup-restore-migration/migrate-config.html)** — Guides for aligning primary cryptographic keys and salts for Return Material Authorizations (RMAs).


