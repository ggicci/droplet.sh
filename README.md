# droplet

Bootstrap of my shell world. Import shell scripts like Golang.

## Getting Started

You can clone this repository and source `droplet.sh`. Or even just wget the raw file from github and source it.

```bash
wget --quiet "https://raw.githubusercontent.com/ggicci/droplet/master/droplet.sh" -O "droplet.sh"
```

## Use "import"

First, you have to source the `droplet.sh` ([WARNING](#warning)):

```bash
source droplet.sh
```

then you can use `import` rather than `source` to make life much more easier:

```bash
import "foo"      # => source "{lookfor_paths}/foo/droplet.sh"

import "bar.sh"   # => source "{lookfor_paths}/bar.sh"

import "./foo.sh"               # not recommended
import "../third_party/time.sh" # not recommended
import "/tmp/mutable.sh"
import "github.com/ggicci/droplet/droplets/env.sh"
```

## The lookfor paths

Droplet will find the scripts you wish to import in several paths by order (lookfor_paths):

1. `.`;
2. `./vendor` directory;
3. `DROPLET_SHELL_PATH`;

If `DROPLET_SHELL_PATH` is empty, `${HOME}/.droplet` will be used.

## The Go way (my practice)

Set `DROPLET_SHELL_PATH=${GOPATH}/src` to reuse the `${GOPATH}`. And then manage shell scripts project like Go and do import like Go:

```shell
# clone a project
go get github.com/ggicci/droplet

# import scripts
import "github.com/ggicci/droplet/droplets/out.sh"

out::printf_red "RED\n"
out::printf_green "GREEN\n"
```

## WARNING

**ONLY** import **trusted** shell scripts.
