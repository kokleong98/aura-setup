#!/bin/bash
set -e

source /etc/environment
source /etc/profile

# $HOME is available, but not many other env vars are by default
source $HOME/.nvm/nvm.sh

# restore SHELL env var for cron
SHELL=/bin/bash
# execute the cron command in an actual shell
exec /bin/bash --norc "$@"
