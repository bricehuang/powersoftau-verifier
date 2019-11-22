# Powers Of Tau script

This script verifies the integrity of the the Semaphore team's
Perpetual Powers of Tau trusted setup ceremony.
It downloads and validates the challenges and responses published
by the ceremony's participants.
This script is written for an Ubuntu 18.04 machine (we personally use an Azure VM) with at least 512GB of storage.

## Usage

```
./upload.sh
ssh ubuntu@104.215.159.250
cd /mnt/disk0/verify/
./script.sh
```
