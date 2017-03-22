### Bash Notes

* [Bash](#a)
  * [Dollar Sign Question Mark ( $? )](#a1)
  * [Back to Pervious `DIR`](#a2)
* [STRINGS](#b)
  * [LENGTH: bash :Get Length of a string.](#b1)
  * [SUBSTRING](#b2)
     * [Substring: bash :Extract substring](#b2a)
     * [Shortest Substring Match](#b2b)
         * [Deletes the shortest match of substring from front of string](#b2b1)
         * [Deletes the shortest match of substring from back of string: dirname](#b2b2)
     * [Longest Substring Match](#b2c)
         * [Deletes the longest match of substring from front of string: basename](#b2c1)
         * [Deletes the longest match of substring from back of string](#b2c2)
         * [FILE EXTENSION: bash :Get file extension from string](#b2c3)
     * [REPLACE: bash :Find and Replace string values](#b3)
         * [Replace only first match](#b3a)
         * [Replace all the matches](#b3b)
         * [Replace at beginning of string](#b3c)
         * [Replace at end of string](#b3d)
     * [REPLACE: sed :a character in a string:](#b4)
     * [`printf`](#b5)
         * [Left Justify](#b5a)
         * [Right Justify](#b5b)
         * [Print CHAR n times (duplicate)](#b5c)
     * [REGEX](#b6)
         * [`grep` substring](#b6a)  
* [XML](#c)
  * [XML syntax: `xmllint`](#c1)
  * [XML pretty print: `xmllint`](#c2)
* [Directory Tree Structure](#d)
  * [Syntax](#d1)
  * [See all files: `tree -a`](#d2)
  * [See directories only: `tree -d`](#d3)
* [VIM](#e)
  * [Reverse Search](#e1)
* [ARRAY](#f)
  * [Declaring an empty `array`](#f1)
  * [`array` push](#f2)
  * [Associative `array`](#f3)
     * [Declare](#f3a)
     * [Add Values](#f3b)
     * [Access Keys](#f3c)
     * [Access Values](#f3d)
     * [Count](#f3e)
     * [Iterate](#f3f)

### Bash <a name="a"></a>

----

#### Dollar Sign Question Mark ( $? ) <a name="a1"></a>

* Used to find the return value of the last executed command.
```bash
 # Example
 $ ls somefile
 $ echo $?
 # If 'somefile' exists you will get the return value thrown by the 'ls' command,
 # be 0 (default "success" return value). If it doesn't exist, you should get 1.
```

#### Back to Pervious `DIR` <a name="a2"></a>

```
$ cd -
```
----

<h3>STRINGS</h3> <a name="b"></a>

----
#### LENGTH: `bash` :Get Length of a string. <a name="b1"></a>

```bash
# Syntax
${#string}
```
```bash 
$ var="Welcome to the geekstuff"

$ echo ${#var}

## Output
## 24
```
#### SUBSTRING <a name="b2"></a>
##### Substring: `bash` :Extract substring <a name="b2a"></a>
```bash
# Syntax
${string:position} || ${string:position:length}
```
```bash
$ var="Welcome to the geekstuff"

$ echo ${var:15}
$ echo ${var:15:4}

## Output
## geekstuff
## geek
```

##### Shortest Substring Match <a name="b2b"></a>

###### Deletes the shortest match of substring from **front** of  string <a name="b2b1"></a>
```bash
# Syntax
${string#substring}
```
```bash
$ filename="bash.string.txt"

$ echo ${filename#*.}

## Output
## string.txt
```
###### Deletes the shortest match of substring from **back** of string: dirname <a name="b2b2"></a>
```bash
# Syntax
${string%substring}
```
```bash
# dirname
$ path=/mnt/spool/edi/active/archive/2015/12/10/ci1447137681384.50063server.x12.dir

$ echo ${path%/*}

## Output
## /mnt/spool/edi/active/archive/2015/12/10
```

##### Longest Substring Match <a name="b2c"></a>
<h6>Deletes the longest match of substring from <b>front</b> of string: basename</h6> <a name="b2c1"></a>
```bash
# Syntax
${string##substring}
```

```bash
#basename
path=/mnt/spool/edi/active/archive/2015/12/10/ci1447137681384.50063server.x12.dir

echo ${path##*/}

## output
## ci1447137681384.50063server.x12.dir
```

<h6>Deletes the longest match of substring from <b>back</b> of string</h6> <a name="b2c2"></a>

```bash
# Syntax
${string%%substring}
```

```bash
filename="bash.string.txt"

echo ${filename%%.*}

## output
## bash
```

###### FILE EXTENSION: `bash` :Get file extension from string <a name="b2c3"></a>

```bash
extension="${filename##*.}"
```

#### REPLACE: `bash` :Find and Replace string values <a name="b3"></a>

##### Replace only first match <a name="b3a"></a>

```bash
# Syntax
${string/pattern/replacement}
```

```bash
$ filename="bash.string.txt"
$ echo "After Replacement:" ${filename/str*./operations.}

## Output
## After Replacement: bash.operations.txt
```

##### Replace all the matches <a name="b3b"></a>

```bash
# Syntax
${string//pattern/replacement}
```

```bash
$ filename="Path of the bash is /bin/bash"
$ echo "After Replacement:" ${filename//bash/sh}

## Output
## After Replacement: Path of the sh is /bin/sh
```

##### Replace at beginning of string <a name="b3c"></a>

```bash
# Syntax
${string/#pattern/replacement}
```

```bash
$ filename="/root/admin/monitoring/process.sh"
$ echo "Replaced at the beginning:" ${filename/#\/root/\/tmp}

## Output
## Replaced at the beginning: /tmp/admin/monitoring/process.sh
```

##### Replace at end of string <a name="b3d"></a>

```bash
# Syntax
${string/%pattern/replacement}
```

```bash
$ filename="/root/admin/monitoring/process.sh"
$ echo "Replaced at the end": ${filename/%.*/.ksh}

## Output
## Replaced at the end: /root/admin/monitoring/process.ksh
```

#### REPLACE: `sed` :a character in a string: <a name="b4"></a>

```bash
STR1="This is a string"
echo ${STR1} | sed 's/ /,/g'

##output
##This,is,a,string
```

#### REGEX <a name="b6"></a>

##### `grep` substring <a name="b6a"></a>

```bash
# grep -oP "regex"
grep -oP "\d{1,}"
```
----
#### **`printf`** <a name="b5"></a>
##### Left Justify <a name="b5a"></a>
```bash
$ printf '%10s\n' "hello"
     hello
```
##### Right Justify <a name="b5b"></a>
```bash
$ printf printf '%-10s  |\n' "hello"
hello       |
```

#### Print CHAR n Times (Duplicate) <a name="b5c"></a>

The follow is how you print char or string n number of times

```
printf "%0.s-" {1..10}
```

output

```
----------
```

----
### XML <a name="c"></a>

#### XML syntax: `xmllint` <a name="c1"></a>

```bash
xmllint --noout your_test_file.xml
echo $?
```

#### XML pretty print: `xmllint` <a name="c2"></a>

```bash
xmllint --format 8.xml >> 8f.xml
```

### Directory Tree Structure <a name="d"></a>
#### Syntax <a name="d1"></a>
```bash
tree
tree /path/to/directory
tree [options]
tree [options] /path/to/directory
```

#### See all files: `tree -a` <a name="d2"></a>
```bash
tree -a /path/to/directory
```

#### See directories only: `tree -d` <a name="d3"></a>
```bash
tree -d /path/to/directory
```
---
### VIM <a name="e"></a>

#### Reverse search <a name="e1"></a>
* In order to do a reverse search in vim `[esc]`, `[shift]+[:]`:
```
:?[SEARCH_STRING]
```
----
### ARRAY <a name="f"></a>

#### Declaring an empty `array` <a name="f1"></a>
```
array=()
```

#### `array` push <a name="f2"></a>
```
ARRAY=()
ARRAY+=('foo')
ARRAY+=('bar')
```

#### **Associative `array`** <a name="f3"></a>
##### **Declare** <a name="f3a"></a>
```
declare -A array
```
##### **Add Values** <a name="f3b"></a>
```
array[foo]=bar
array[bar]=foo
```
##### **Access Keys** <a name="f3c"></a>
```
${!array[@]}
```
##### **Access Values** <a name="f3d"></a>
```
${array[@]}
```
##### **Count** <a name="f3e"></a>
```
${#array[@]}
```
##### **Iterate** <a name="f3f"></a>
```
for i in "${!array[@]}"
do
  echo "key  : $i"
  echo "value: ${array[$i]}"
done
```
