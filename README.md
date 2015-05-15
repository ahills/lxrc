# lxrc

Wrapper around LXC commands. Create a file with the name of the container to
wrap, and put the path to `lxrc` on the shebang line.

Here's an example that mounts some LVM filesystems, one of them encrypted:

```
#!/usr/bin/env lxrc

rollback = on
verbose = true

vgpath = /dev/VG0
rootname = {_}_root
dataname = {_}_data
cachename = common_cache

echo
echo '*** Container: {_} ***'
echo

echo '*** Mounting filesystems ***'
mount dev={vgpath}/{rootname} dst=
mount dev={vgpath}/{cachename} dst=var/cache
luksopen dev={vgpath}/{dataname} name={dataname} dst=var/lib
# The above three-argument luksopen is equivalent to the following:
#luksopen dev={vgpath}/{dataname} name={dataname}
#mount dev=/dev/mapper/{dataname} dst=var/lib

echo '*** Starting container ***'
start
info

echo
echo '*** Done with {_} ***'
echo

```

## Variable Reference

Variables are expanded using `{varname}` notation. To unset a variable, set its
value to nothing, e.g. `varname =`. Accessing a nonexistent variable is an
error. The following variables are special:

* **_** - The "default" variable, à la Perl. Used to indicate the container to
          process for commands like *start* (see below). Default: basename of
          the file.
* **0**, **1**, … - Positional arguments given to *lxrc* after a `--` on the
                    command line. By default, these do not exist unless they
                    are set. They are set in any *include*d file (see below).
* **cryptsetup** - Path to *cryptsetup* executable. Default: `$CRYPTSETUP`
                   environment variable, or just `cryptsetup`.
* **debug** - When set to anything, *lxrc* prints debugging information, such
              as system commands executed. Default: unset.
* **echo** - When set to anything, *lxrc* prints each command just before
             processing it. Default: unset.
* **lxcpath** - LXC path, as given to LXC commands via the *-P*/*--lxc-path*
                option. Default: `$LXCPATH` environment variable, or
                `/var/lib/lxc`.
* **mount** - Path to *mount* executable. Default: `$MOUNT` environment
              variable, or just `mount`.
* **mount_opt** - Default options for *mount* command (see below). Default:
                  unset.
* **path** - Colon-separated list of directories to search for *lxrc* files for
             the *include* command. Default: `/etc/lxrc.d:.`.
* **rollback** - When set to anything, *lxrc* attempts to roll back mounts and
                 LUKS openings if any command fails. Default: unset.
* **stdout** - Output of system command run by *exec* (see below). Default:
               unset.
* **umount** - Path to *umount* executable. Default: `$UMOUNT` environment
               variable, or just `umount`.
* **verbose** - When set to anything, *lxrc* prints verbose information about
                the actions being performed. Default: unset.

## Command Reference

Commands have a similar form as Bourne shell commands, taking whitespace-
separated arguments, which are quoted the same way as the Bourne shell. (See
Python's *shlex* module, and *lxrc*'s *get_lexer*/*get_linelexer* functions,
for details.) Some commands take keyword arguments, which can be in any order.
The naïve parser treats any argument with an "=" in it as a keyword argument;
this is a bug/limitation. If any command fails, processing is halted, and, if
the *rollback* variable is set, rollbacks are attempted (see above).

* **echo** - Exactly what you'd expect: prints its arguments.
* **exec** - Executes a shell command, which is the arguments joined by
             spaces, and puts the resulting output in the *stdout* variable. If
             the command fails, processing is halted.
* **include** - Processes other *lxrc* files in place. Positional arguments are
                still set (see above), and variables are shared. The *path*
                variable is parsed for directories to search for the file, if
                it does not exist. The arguments are the file list.
* **info** - Runs the LXC *lxc-info* command for each target given as an
             argument, or for the default variable (see above).
* **luksclose** - Closes a LUKS-encrypted device. The *name* keyword argument
                  is required, and represents the mapper name of the device to
                  close. The executable to which the *cryptsetup* variable
                  points is executed (see above). This command is automatically
                  added to the rollback action stack by a *luksopen* command.
* **luksopen** - Opens a LUKS-encrypted device, and optionally mounts it. The
                 *dev* and *name* keyword arguments are required, and represent
                 the full path to the encrypted device and the desired mapper
                 name, respectively. (These are the arguments to `cryptsetup
                 luksOpen`.) If the *dst* keyword argument is supplied, the
                 opened LUKS device will be mounted there. See *mount* below
                 for details on specifying this parameter. The executable to
                 which the *cryptsetup* variable points is executed (see
                 above).
* **mount** - Mounts the device given in the *dev* keyword argument at mount
              point *dst*, also a keyword argument. The *dst* argument is
              automatically prefixed by *lxcpath* and the default variable (see
              above) unless it is an absolute path.
* **start** - Runs the LXC *lxc-start* command for each target given as an
              argument, or for the default variable (see above).
* **unmount** - Unmounts the device given in the *dev* keyword argument or the
                mount point given in the *dst* keyword argument. One or the
                other is required. This command is automatically added to the
                rollback action stack by a *mount* command.

Copyright © 2015 Andrew Hills. See LICENSE for details.
