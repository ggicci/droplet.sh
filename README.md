# droplet.sh

Bootstrap of my shell world. Import shell scripts like Golang.

## Getting Started

```bash
curl -sSLO "https://raw.githubusercontent.com/ggicci/droplet.sh/v0.1.0/droplet.sh"
```

## Use "droplet"

First, you have to source the `droplet.sh` ([WARNING](#warning)):

```bash
source droplet.sh
```

then you can use `droplet` rather than `source` to import well-organized shell scripts:

```bash
droplet "foo"      # => source "{lookfor_paths}/foo/droplet.sh"
droplet "bar.sh"   # => source "{lookfor_paths}/bar.sh"
droplet "/tmp/mutable.sh"  # => use absolute path
```

## The `lookfor_paths`

`droplet.sh` will find the scripts you wish to import in several paths (`lookfor_paths`) by order:

1. `.`;
2. `./droplets` directory;

## Organize Your Shell Scripts

Create a repository e.g. github.com/ggicci/droplets, in which save your reuseable shell scripts. Then `droplet` it in another project. Demo:

```bash
mkdir /tmp/demo-project && cd $_

# Get droplet.sh in the project.
curl -sSLO "https://raw.githubusercontent.com/ggicci/droplet.sh/v0.1.0/droplet.sh"

# Save 3rd-party reusable shell scripts (dependencies, libraries?) into
# "droplets" subfolder.
mkdir -p droplets/github.com/ggicci/droplets
git clone https://github.com/ggicci/droplets.git droplets/github.com/ggicci/droplets

# Create sample snippet:
echo '#!/usr/bin/env bash

set -euo pipefail

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/droplet.sh"
droplet "github.com/ggicci/droplets/time.sh"

time::now
' > demo.sh

chmod u+x demo.sh
./demo.sh

# Output:
# 2021-07-04T14:33:38+08:00
```

## Environment Variables

- `DROPLET_DEBUG=1`: enable debug output

## WARNING

**ONLY** import **trusted** shell scripts.
