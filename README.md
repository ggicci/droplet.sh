# basher

:shell: My bash utilities.

## bootstrap

You can clone this repository and source `bootstrap.sh`. Or even just wget the raw file from github and source then.

```bash
wget --quiet "https://raw.githubusercontent.com/ggicci/basher/master/bootstrap.sh" -O "bootstrap.sh"

source bootstrap.sh
```

## import

After `source bootstrap.sh`, you can use `import` function to source bash scripts for avoid sourcing multiple times.

```bash
# import "*.sh" except "_*.sh" under directory "dir" or "${_BASHER_VENDOR_ROOT}/dir"
import "dir"

# import "bar.sh" under current directory
import "bar.sh"

import "./foo.sh"
import "../3rd/time.sh"
import "/tmp/mutable.sh"
```
