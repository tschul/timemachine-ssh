[![Bountysource](https://www.bountysource.com/badge/tracker?tracker_id=6846776)](https://www.bountysource.com/trackers/6846776-hypery2k-timemachine-ssh?utm_source=6846776&utm_medium=shield&utm_campaign=TRACKER_BADGE)

> A small shell script that tunnels the AFP port of your disk station (and propably every other NAS with AFP and SSH services running) over ssh to your client computer.
> So you can access your files and do Time Machine backups on a secured SSH connection via internet, e.g [Ubuntu](http://ubuntuforums.org/showthread.php?t=2105755)
> You can access the remote AFP server via port on your local machine. After running the script, the host should show up in Finder on Mac OS.

## Usage


You run the script via cron to ensure that the connection still exists. If the tunnel is broken, it will be established again. 
To kill the tunnel you can use '-k' or '--kill' as command line parameters:

```
timemaschine-ssh.sh -k
```

or just use '-h' for getting a list of all options

```
timemaschine-ssh.sh -h
```

So basic four steps are needed
* Run the script `timemaschine-ssh.sh`
* go to the share in find and login, save the login details in keychain
* open the desired share
* now open TimeMachine and select you're share


## Changelog

### 2014-11-23
- Improved documentation

### 2014-10-09
- Added quiet mode
- Refactoring
- Removed config file support

### 2012-07-03
- Added support for config files
- Added support for ssh keys

### 2011-12-27
- Added a help screen (-h or --help)

### 2011-12-26
- Fixed some small bugs with background processes regarding hangups of the script
- Added verbose mode (-v or --verbose)
- Implemented a cleaner way to kill the processes

### 2011-12-24
- Initial release

