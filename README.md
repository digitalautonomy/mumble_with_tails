# Mumble in Tails

The included shell scripts help the end user to host a Mumble server
as a Hidden service in Tor in Tails.

## Requirements

* Live running session of Tails in non-persistent mode.
* Tor should be up and running in Tails before running the script.
* Administrator password must be set at the Tails greeter screen.
* The scripts are expected to be executed in a root shell.
* The user should have access to the scripts locally or from a remote
  location.

  ### For persistent mode.

  * The persistent volume must be available and decrypted.

## How to use

* Make sure the scripts are in accessible location like
  `/home/amnesia/mumble-scripts`.
  * For persistent mode, it would be helpful to put the scripts in
    `/home/amnesia/Persistent/mumble-scripts` so that they are
    available after a reboot.
* Open a Terminal window.
* Switch to `root` user by typing in `sudo -i`.
* Make sure the scripts are executable by running
  `chmod 755 /home/amnesia/mumble-scripts/*.sh`.
* To setup a Mumble server run
  `/home/amnesia/mumble-scripts/setup-mumble.sh`.
* Remember to launch Mumble as a **non-root** user from a new terminal
  window.
* Type in `mumble` and press enter, this should bring up the Mumble
  client.
* Share the `.onion` URL with the people who wishes to join your
  Mumble server.

## Explanation of the scripts

### `setup-mumble.sh`

1. Updates the apt(8) repositories.
2. Installs the Mumble client and Mumble server.
3. Sets up the hidden service for Mumble server.
4. Shows the `.onion` URL to the user.
5. Also copies the URL to the clip board for easy pasting.
6. **For persistent mode**, copies the Mumble server settings and
   hidden service settings to the persistent volume.

### `purge-mumble.sh`

1. Removes the Mumble server hidden service.
2. Removes any unwanted additional packages that were installed as a
   part of installing Mumble client and Mumble server.
3. Removes the Mumble client and Mumble server.
4. **For persistent mode**, removes the Mumble server settings and
   hidden service settings from the persistent volume.

### `restore-mumble.sh`

1. Used only for **persistent mode**.
2. Copies the Mumble server settings and hidden service settings to
   the persistent volume.
3. Restarts Tor service to host the Mumble server hidden service.
4. Shows the `.onion` URL to the user.
5. Also copies the URL to the clip board for easy pasting.

## Potential improvements

* Give full support for saving / restoring states of server and
  service in persistent mode tails.
* Allow configurable variables for various things like Mumble port,
  Hidden Service port etc.
* Possibly extend the script to be functional outside Tails, in
  distributions like Debian for example.
* Add a GUI based installation mechanism to ease the end-user
  experience using tools like zenity(1).
