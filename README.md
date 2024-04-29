# Arch Linux Install Script
This script is in active development. This is the first version avaliable for use I have managed to produce. Feel free to use it if youd like.
This is something I use to make my arch install easier when I reinstall for any reason. This will be tailored to my configuration.

## Developer Notes
This script is built with system compatibility in mind. It works for base installs on both Intel and AMD CPUs.
This script was built with static ips in mind so it is setup with systemd-networkd and systemd-resolved

I will add options to change this depening on user needs.

## Usage
Do you want to try it for yourself? 

Clone the repo with this command.
`git clone https://github.com/EpicPlayzGames/EpicArch`

After cloning the repo, make the script executable with this command.
`sudo chmod +x arch-install.sh`

Then simply launch the script with.
`./arch-install.sh`

## Features To Come
Pre-Install Configuration like:
- LUKS and Full Disk Encryption Options

Post Install Configuration like:

- DE Support, will add the ability to chose a select DE and then install the nessaccary requirements for this DE to function
- DHCP and Static IP config choice
- and more!

## Last Words
Want to contribute? Or find any issues? Feel free to open a pull request or an issue on github and I'll be sure to get back to you.

## TO-DO
- [ ] Add Conditional Statements to check of command failures
- [ ] Test detectgpu() function
- [ ] Add DHCP Support
- [X] Add DE Selection Support
- [ ] Add Support for other filesystems
- [X] Add Better Documentation
