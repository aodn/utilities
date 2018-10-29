## Python FTP Folder uploader script

Boilerplate created initially for the usage of the RDC project - national repository of BRUV's data
https://github.com/aodn/backlog/issues/964

Can poll (or run once) uploading local changed files in a directory to an SFTP server

### Requirements

- Python 3.6
- pip install paramiko humanize

### Usage

- setup ftp.conf and/or supply command line overrides
- Example request: `$ python3 main.py -l /tmp/testFolder `

### Assumptions and TODOs

- This is boilerplate not nicely packaged
- Uses SFTP and should work across Windows, Mac, Linux
- Developed and tested on Mac sorry :)
- SFTP may have problems with large file transfers, No resuming retries
- Authentication method may need to change
- mtime of local and remote files need to be compared. 
Uneccessary transfers will occur currently.




#### Steps taken to setup @datasync-fileserver SFTP

- Add group 'sftp_users' then the user `tester`
```angular2html
 useradd -u tester -G sftp_users -p password -s /usr/sbin/nologin
```
- Create home directory and staging folder acceptable to chroot
(note ownership and permissions)

```
ubuntu@datasync-fileserver:/home/tester$ ls -la  /home/tester/
total 12
drwxr-xr-x 3 root root       4096 Oct 17 00:06 .
drwxr-xr-x 4 root root       4096 Oct 16 00:48 ..
drwxrwxr-x 3 root sftp_users 4096 Oct 16 23:48 staging
```

**ubuntu@datasync-fileserver:~$** sudo vi /etc/ssh/sshd_config
```angular2html
PasswordAuthentication yes
```
- todo: change authentication method ??

```angular2html
Match Group sftp_users
X11Forwarding no
AllowTcpForwarding no
ChrootDirectory %h/staging/
ForceCommand internal-sftp
```
