# droplet

Bootstrap of my shell world. Take me from :droplet: to :ocean: ~

## Getting Started

You can clone this repository and source `droplet.sh`. Or even just wget the raw file from github and source it.

```bash
wget --quiet "https://raw.githubusercontent.com/ggicci/basher/master/droplet.sh" -O "droplet.sh"
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

import "./foo.sh"
import "../third_party/time.sh"
import "/tmp/mutable.sh"
```


## The lookfor paths

Droplet will find the scripts you wish to import in several paths by order (lookfor\_paths):

  1. `.`;
  2. `./vendor` directory;
  3. `DROPLET_SHELL_PATH`;

If `DROPLET_SHELL_PATH` is empty, `${HOME}/.droplet` will be used.

## WARNING

**ONLY** import **trusted** shell scripts.
