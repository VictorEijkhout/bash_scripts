# Bash scripts

This is a collection of bash scripts that I've found useful in my activities 
as a consultant on a unix-based supercomputer.

## `splitpath` : split a path variable

Usage:

```
splitpath LD_LIBRARY_PATH
```

This will break the value of the variable with one directory per line.

## `assemblepath` : inverse of splitting a path

Sample usage:

```
export CPATH=$( splitpath CPATH | grep -v lib64 | assemblepath )
```

## `findsymbol` : find definition of a symbol

Search all `lib*` for the `T` line that defines a symbol.

Usage:

```
# find in current directory
findsymbol nf_strerror
# find in given directory
findsymbol -d /usr/lib nf_strerror
# print all definition matches
findsymbol -v strerror
```

Option `-t` (for trace) prints all names of libs investigated.

## `linebreak` : break a long line (for CMake)

I have too many incredibly long cmake invocations. 
This breaks a commandline (which you scoop up from your terminal output)
into a nicely line-broken block.

Usage:

```
linebreak "cmake -D this=that -DCMAKE_PREFIX_DIR=/foo/bar ${HOME}/src/package
```


