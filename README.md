# Arch Linux Install Script
This script is in active development. This is the first version avaliable for use i have managed to produce. Feel free to use.
This is something i use to make my arch install easier when i reinstall for any reason. This will be tailored to my configuration.

## Developer Notes

This script is built with system compatibility in mind. Works for installs on both Intel and AMD CPUs.
This script was built with static ips in mind so it is setup with systemd-networkd and systemd-resolved

Will add options to change this depening on user needs.

## Usage
Want to try it for yourself? 

Clone the repo with this command.
`git clone https://github.com/EpicPlayzGames/EpicArch`

After cloning the repo, make the script executable with this command.
`sudo chmod +x arch-install.sh`

And then simply launch the script with
`./arch-install.sh`

## Installer Notes
>[!WARNING]
>**${GPUDRIVER}** && **${GPUUTILS}** removed from pacstrap commmand duing the base_install() function, this script was tested in a vm, so the detectgpu() function has not been tested properly. 
The rest of this script works perfectly fine

Manual GPU Driver install until otherwise tested.

## Features To Come

Post install configuration like:

- DE Support, will add the ability to chose a select DE and then install the nessaccary requirements for this DE to function
- LUKS and Full Disk Encryption Options
- DHCP and Static IP config choise
- and more!

## Last Words

Want to contribute? Or find any issues? Feel free to open a pull request or an issue on github and ill be sure to get back to you.

## TO-DO
- [ ] Test detectgpu() function
- [ ] Add DHCP Support
- [ ] Add DE Selection Support
- [ ] Add Support for other filesystems
- [ ] Add Better Documentation
