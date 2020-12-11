# droplet.sh

Bootstrap of my shell world. Import shell scripts like Golang.

## Getting Started

```bash
curl -sSLO "https://raw.githubusercontent.com/ggicci/droplet/master/droplet.sh"
```

## Use "droplet"

First, you have to source the `droplet.sh` ([WARNING](#warning)):

```bash
source droplet.sh
```

then you can use `droplet` rather than `source` to make life much more easier:

```bash
droplet "foo"      # => source "{lookfor_paths}/foo/droplet.sh"
droplet "bar.sh"   # => source "{lookfor_paths}/bar.sh"
droplet "/tmp/mutable.sh"  # => use absolute path

# e.g.
git clone github.com/ggicci/shellder
droplet "github.com/ggicci/shellder/io.sh"
io::print -fg "#FF0000" "RED\n" -fg "#00FF00" "GREEN\n"
```

## The `lookfor_paths`

`droplet.sh` will find the scripts you wish to import in several paths (`lookfor_paths`) by order:

1. `.`;
2. `./vendor` directory;
3. `DROPLET_SHELL_PATH`;

If `DROPLET_SHELL_PATH` is empty, `${HOME}/.droplet` will be used.

## WARNING

**ONLY** import **trusted** shell scripts.
