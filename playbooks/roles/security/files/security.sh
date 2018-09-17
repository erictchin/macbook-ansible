# collected from various parts of the web
# some here: github.com/jamfprofessionalservices, some here: https://github.com/mathiasbynens/dotfiles

currentUser="$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')"

# enable auto update
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# enable app auto update
defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool true

# enable system data files and security update installs
defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true
defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

# turn off bluetooth if no paired devices exist
connectable="$( system_profiler SPBluetoothDataType | grep Connectable | awk '{print $2}' | head -1 )"
if [ "$connectable" = "Yes" ]; then
    defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -bool false
    killall -HUP blued
fi

# show bluetooth status in menubar
open "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"

# enable set time and date automatically
systemsetup -setusingnetworktime on

# restrict ntp server to loopback interface
cp /etc/ntp-restrict.conf /etc/ntp-restrict_old.conf
echo -n "restrict lo interface ignore wildcard interface listen lo" >> /etc/ntp-restrict.conf

# enable screensaver after 20 minutes of inactivity
defaults write /Users/"$currentUser"/Library/Preferences/ByHost/com.apple.screensaver."$hardwareUUID".plist idleTime -int 1200

#
# OS Security
#

# disable remote apple events
systemsetup -setremoteappleevents off

# disable internet sharing
/usr/libexec/PlistBuddy -c "Delete :NAT:AirPort:Enabled"  /Library/Preferences/SystemConfiguration/com.apple.nat.plist
/usr/libexec/PlistBuddy -c "Add :NAT:AirPort:Enabled bool false" /Library/Preferences/SystemConfiguration/com.apple.nat.plist
/usr/libexec/PlistBuddy -c "Delete :NAT:Enabled"  /Library/Preferences/SystemConfiguration/com.apple.nat.plist
/usr/libexec/PlistBuddy -c "Add :NAT:Enabled bool false" /Library/Preferences/SystemConfiguration/com.apple.nat.plist
/usr/libexec/PlistBuddy -c "Delete :NAT:PrimaryInterface:Enabled"  /Library/Preferences/SystemConfiguration/com.apple.nat.plist
/usr/libexec/PlistBuddy -c "Add :NAT:PrimaryInterface:Enabled bool false" /Library/Preferences/SystemConfiguration/com.apple.nat.plist

# disable screen sharing and remote management
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop

# disable print sharing
/usr/sbin/cupsctl --no-share-printers

# disable remote login
systemsetup -f -setremotelogin off

# disable bluetooth sharing
/usr/libexec/PlistBuddy -c "Delete :PrefKeyServicesEnabled"  /Users/"$currentUser"/Library/Preferences/ByHost/com.apple.Bluetooth."$hardwareUUID".plist
/usr/libexec/PlistBuddy -c "Add :PrefKeyServicesEnabled bool false"  /Users/"$currentUser"/Library/Preferences/ByHost/com.apple.Bluetooth."$hardwareUUID".plist

# don't wake for network access
pmset -a womp 0

# enable gatekeeper
spctl --master-enable

# enable firewall
defaults write /Library/Preferences/com.apple.alf globalstate -int 2

# enable firewall stealth mode (don't respond to ping, etc)
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# disable bonjour advertising service
defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

# show wifi status in the menu bar
open "/System/Library/CoreServices/Menu Extras/AirPort.menu"

# ensure nfs server is not running
nfsd disable
rm -rf /etc/export

# secure home folders
IFS=$'\n'
for userDirs in $( find /Users -mindepth 1 -maxdepth 1 -type d -perm -1 | grep -v "Shared" | grep -v "Guest" ); do
    chmod -R og-rwx "$userDirs"
done
unset IFS

# make sure system wide apps have appropriate permissions
IFS=$'\n'
for apps in $( find /Applications -iname "*\.app" -type d -perm -2 ); do
    chmod -R o-w "$apps"
done
unset IFS

# check for world writeable files in /System
IFS=$'\n'
for sysPermissions in $( find /System -type d -perm -2 | grep -v "Public/Drop Box" ); do
    chmod -R o-w "$sysPermissions"
done
unset IFS

# automatically lock login keychain for inactivity
# security set-keychain-settings -u -t 21600s /Users/"$currentUser"/Library/Keychains/login.keychain

# lock the login keychain when computer sleeps
security set-keychain-settings -l /Users/"$currentUser"/Library/Keychains/login.keychain

# enable OCSP and CRL certificate checking
defaults write com.apple.security.revocation OCSPStyle -string RequireIfPresent
defaults write com.apple.security.revocation CRLStyle -string RequireIfPresent
defaults write /Users/"$currentUser"/Library/Preferences/com.apple.security.revocation OCSPStyle -string RequireIfPresent
defaults write /Users/"$currentUser"/Library/Preferences/com.apple.security.revocation CRLStyle -string RequireIfPresent

# don't enable the 'root' account
dscl . -create /Users/root UserShell /usr/bin/false

# password on wake from sleep or screensaver
defaults write /Users/"$currentUser"/Library/Preferences/com.apple.screensaver askForPassword -int 1

# require admin password to access system-wide preferences
security authorizationdb read system.preferences > /tmp/system.preferences.plist
/usr/libexec/PlistBuddy -c "Set :shared false" /tmp/system.preferences.plist
security authorizationdb write system.preferences < /tmp/system.preferences.plist

# disable ability to login to another user's active and locked session
/usr/bin/security authorizationdb write system.login.screensaver "use-login-window-ui"

# disable fast user switching
defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false

# login window as name and password (not prompted for with a username)
defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# disable guest account
defaults write /Library/Preferences/com.apple.loginwindow.plist GuestEnabled -bool false

# disable allow guests to connect to shared folders
defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool no
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool no

# remote guest home folder
rm -rf /Users/Guest

# turn on filename extensions
sudo -u "$currentUser" defaults write NSGlobalDomain AppleShowAllExtensions -bool true
pkill -u "$currentUser" Finder

# disable automatic run of safe files in Safari
defaults write /Users/"$currentUser"/Library/Preferences/com.apple.Safari AutoOpenSafeDownloads -bool false

# reduce sudo timeout period
echo "Defaults timestamp_timeout=0" >> /etc/sudoers

