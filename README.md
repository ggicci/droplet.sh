# basher

:shell: My bash utilities.

## bootstrap

You can clone this repository and source `bootstrap.sh`. Or even just wget the raw file from github and source then.

```bash
wget --quiet "https://raw.githubusercontent.com/ggicci/basher/master/bootstrap.sh" -O "bootstrap.sh"

source bootstrap.sh
```

## import

After `source bootstrap.sh`, you can use `import` function to source bash scripts from `local`, `github` and `http`. For instance:

```bash
# from local
import "./foo.sh"
import "../3rd/time.sh"

# from github
import "github.com/ggicci/basher/log"

# from http
import "http://my.site.com/src-remote/bashutil/bar.sh"
```
