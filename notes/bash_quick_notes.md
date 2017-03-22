### Bash Quick Notes

#### SHIFT
`shift` is a bash built-in which kind of removes arguments in beginning of the argument list. Given that the arguments provided to the script are 3 available in `$1`, `$2`, `$3`, then a call to `shift` will make `$2` the new `$1`. a shift 2 will shift by two making new `$1` the old `$3`. for more info see here

#### DIR OF CURRENT SCRIPT
```bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
```

#### IF `$VAR` RETURN `:` ELSE RETURN EMPTY STRING
```bash
if ${var+:} false; then ...
```

```bash
[[ ${var+:} ]] && ....
```
#### Passing arrays as parameters in bash
```bash
takes_ary_as_arg()
{
    declare -a argAry1=("${!1}")
    echo "${argAry1[@]}"

    declare -a argAry2=("${!2}")
    echo "${argAry2[@]}"
}
try_with_local_arys()
{
    # array variables could have local scope
    local descTable=(
        "sli4-iread"
        "sli4-iwrite"
        "sli3-iread"
        "sli3-iwrite"
    )
    local optsTable=(
        "--msix  --iread"
        "--msix  --iwrite"
        "--msi   --iread"
        "--msi   --iwrite"
    )
    takes_ary_as_arg descTable[@] optsTable[@]
}
try_with_local_arys
```

#### assign ls to an array

```
array=($(ls -d */))
```

#### $ Variables
[**Special Parameters**](https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html)


* `$1`, `$2`, `$3`, ... are the [positional parameters](https://www.gnu.org/software/bash/manual/html_node/Positional-Parameters.html).
* `"$@"` is an array-like construct of all positional parameters, `{$1, $2, $3 ...}`.
* `"$*"` is the IFS expansion of all positional parameters, `$1 $2 $3 ...`.
* `$#` is the number of positional parameters.
* `$-` current options set for the shell.
* `$$` pid of the current shell (not subshell).
* `$_` most recent parameter (or the abs path of the command to start the current shell  immediately after startup).
* `$IFS` is the (input) field separator.
* `$?` is the most recent foreground pipeline exit status.
* `$!` is the PID of the most recent background command.
* `$0` is the name of the shell or shell script.

#### Find file last modified n*24 hours ago

```
find *.txt -m +5 -exec rm -rf {} \;
```
