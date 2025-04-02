#!/bin/bash

# Define a function to check if the script is being run with root privileges
function check_root() {
  # Compare the user ID of the current user to 0, which is the ID for root
  if [ "$(id -u)" -ne 0 ]; then
    # If the user ID is not 0 (i.e., not root), print an error message
    echo "Error: This script must be run as root."
    # Exit the script with a status code of 1, indicating an error
    exit 1 # Exit the script with an error code.
  fi
}

# Call the check_root function to verify that the script is executed with root privileges
check_root

# Define a function to gather and store system-related information
function system_information() {
  # Check if the /etc/os-release file exists, which contains information about the OS
  if [ -f /etc/os-release ]; then
    # If the /etc/os-release file is present, source it to load system details into environment variables
    # shellcheck source=/dev/null  # Instructs shellcheck to ignore warnings about sourcing files
    source /etc/os-release
    # Set the CURRENT_DISTRO variable to the system's distribution ID (e.g., 'ubuntu', 'debian')
    CURRENT_DISTRO=${ID}
    # Set the CURRENT_DISTRO_VERSION variable to the system's version ID (e.g., '20.04' for Ubuntu 20.04)
    CURRENT_DISTRO_VERSION=${VERSION_ID}
    # Set the CURRENT_SYSTEM_ARCHITECTURE variable to the system's architecture (e.g., 'x86_64', 'arm64')
    CURRENT_SYSTEM_ARCHITECTURE=$(uname -m)
  fi
}

# Call the system_information function to gather the system details
system_information

# Define a function to check system requirements and install missing packages
function installing_system_requirements() {
  # Check if the current Linux distribution is one of the supported distributions
  if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ] || [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ] || [ "${CURRENT_DISTRO}" == "amzn" ] || [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ] || [ "${CURRENT_DISTRO}" == "alpine" ] || [ "${CURRENT_DISTRO}" == "freebsd" ] || [ "${CURRENT_DISTRO}" == "ol" ] || [ "${CURRENT_DISTRO}" == "mageia" ] || [ "${CURRENT_DISTRO}" == "opensuse-tumbleweed" ]; }; then
    # If the distribution is supported, check if the required packages are already installed
    if { [ ! -x "$(command -v curl)" ] || [ ! -x "$(command -v cut)" ] || [ ! -x "$(command -v tar)" ] || [ ! -x "$(command -v bash)" ] || [ ! -x "$(command -v locale-gen)" ] || [ ! -x "$(command -v ps)" ]; }; then
      # If any of the required packages are missing, begin the installation process for the respective distribution
      if { [ "${CURRENT_DISTRO}" == "ubuntu" ] || [ "${CURRENT_DISTRO}" == "debian" ] || [ "${CURRENT_DISTRO}" == "raspbian" ] || [ "${CURRENT_DISTRO}" == "pop" ] || [ "${CURRENT_DISTRO}" == "kali" ] || [ "${CURRENT_DISTRO}" == "linuxmint" ] || [ "${CURRENT_DISTRO}" == "neon" ]; }; then
        # For Debian-based distributions, update package lists and install required packages
        apt-get update
        apt-get install curl coreutils lbzip2 bash locales procps-ng -y
      elif { [ "${CURRENT_DISTRO}" == "fedora" ] || [ "${CURRENT_DISTRO}" == "centos" ] || [ "${CURRENT_DISTRO}" == "rhel" ] || [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ] || [ "${CURRENT_DISTRO}" == "amzn" ]; }; then
        # For Red Hat-based distributions, check for updates and install required packages
        yum check-update
        if { [ "${CURRENT_DISTRO}" == "almalinux" ] || [ "${CURRENT_DISTRO}" == "rocky" ]; }; then
          # Install necessary packages for AlmaLinux
          yum install epel-release elrepo-release -y
        else
          yum install epel-release elrepo-release -y --skip-unavailable
        fi
        # Install necessary packages for Red Hat-based distributions
        yum install curl coreutils lbzip2 bash locales procps-ng -y --allowerasing
      elif { [ "${CURRENT_DISTRO}" == "arch" ] || [ "${CURRENT_DISTRO}" == "archarm" ] || [ "${CURRENT_DISTRO}" == "manjaro" ]; }; then
        # Check for updates.
        pacman -Sy
        # Initialize the GPG keyring.
        pacman-key --init
        # Populate the keyring with the default Arch Linux keys
        pacman-key --populate archlinux
        # For Arch-based distributions, update the keyring and install required packages
        pacman -Sy --noconfirm --needed archlinux-keyring
        pacman -Su --noconfirm --needed curl coreutils lbzip2 bash locales procps-ng
      elif [ "${CURRENT_DISTRO}" == "alpine" ]; then
        # For Alpine Linux, update package lists and install required packages
        apk update
        apk add curl coreutils lbzip2 bash locales procps-ng
      elif [ "${CURRENT_DISTRO}" == "freebsd" ]; then
        # For FreeBSD, update package lists and install required packages
        pkg update
        pkg install curl coreutil lbzip2 bash locales procps-ng
      elif [ "${CURRENT_DISTRO}" == "ol" ]; then
        # For Oracle Linux (OL), check for updates and install required packages
        yum check-update
        yum install curl coreutils lbzip2 bash locales procps-ng -y --allowerasing
      elif [ "${CURRENT_DISTRO}" == "mageia" ]; then
        urpmi.update -a
        yes | urpmi curl coreutils lbzip2 bash locales procps-ng
      elif [ "${CURRENT_DISTRO}" == "opensuse-tumbleweed" ]; then
        zypper refresh
        zypper install -y curl coreutils lbzip2 bash locales procps-ng
      fi
    fi
  else
    # If the current distribution is not supported, display an error and exit the script
    echo "Error: Your current distribution ${CURRENT_DISTRO} version ${CURRENT_DISTRO_VERSION} is not supported by this script. Please consider updating your distribution or using a supported one."
    exit 1 # Exit the script with an error code.
  fi
}

# Call the function to check system requirements and install necessary packages if needed
installing_system_requirements

# The following function checks if the system architecture is supported.
function check_current_system_architecture() {
  # The list of allowed system architectures (case-insensitive).
  ALLOWED_SYSTEM_ARCHITECTURES=("x86_64" "amd64" "aarch64" "arm64" "powerpc64" "ppc64le" "s390x" "riscv64" "mips64" "sparc64" "i386" "i686" "armv7l" "armv6l" "mips" "mipsel" "ppc" "sparc" "riscv32")
  # Check if the current system architecture is in the list of allowed architectures
  if [[ ! "${ALLOWED_SYSTEM_ARCHITECTURES[*]}" =~ ${CURRENT_SYSTEM_ARCHITECTURE} ]]; then
    # If the system architecture is not allowed, display an error message and exit with an error code.
    echo "Error: The '${CURRENT_SYSTEM_ARCHITECTURE}' architecture is not supported. Please stay tuned for future updates."
    exit 1 # Exit the script with an error code.
  fi
}

# The function check if the current system architecture is one of the allowed options.
check_current_system_architecture

# The following function checks if the current init system is one of the allowed options.
function check_current_init_system() {
  # Get the current init system by checking the process name of PID 1.
  CURRENT_INIT_SYSTEM=$(ps -p 1 -o comm --no-headers) # Extract only the command name without the full path.
  # CURRENT_INIT_SYSTEM=$(ps -p 1 -o comm= | awk -F'/' '{print $NF}') # Old methord to extract the command name.
  # Convert to lowercase to make the comparison case-insensitive.
  CURRENT_INIT_SYSTEM=$(echo "$CURRENT_INIT_SYSTEM" | tr '[:upper:]' '[:lower:]')
  # Log the detected init system (optional for debugging purposes).
  echo "Detected init system: ${CURRENT_INIT_SYSTEM}"
  # Define a list of allowed init systems (case-insensitive).
  ALLOWED_INIT_SYSTEMS=("systemd" "sysvinit" "init" "upstart" "bash" "sh")
  # Check if the current init system is in the list of allowed init systems
  if [[ ! "${ALLOWED_INIT_SYSTEMS[*]}" =~ ${CURRENT_INIT_SYSTEM} ]]; then
    # If the init system is not allowed, display an error message and exit with an error code.
    echo "Error: The '${CURRENT_INIT_SYSTEM}' initialization system is not supported. Please stay tuned for future updates."
    exit 1 # Exit the script with an error code.
  fi
}

# The check_current_init_system function is being called.
check_current_init_system

# The following function checks if there's enough disk space to proceed with the installation.
function check_disk_space() {
  # This function checks if there is more than 1 GB of free space on the drive.
  FREE_SPACE_ON_DRIVE_IN_MB=$(df -m / | tr -s " " | tail -n1 | cut -d" " -f4)
  # This line calculates the available free space on the root partition in MB.
  if [ "${FREE_SPACE_ON_DRIVE_IN_MB}" -le 1024 ]; then
    # If the available free space is less than or equal to 1024 MB (1 GB), display an error message and exit.
    echo "Error: You need more than 1 GB of free space to install everything. Please free up some space and try again."
    exit 1 # Exit the script with an error code.
  fi
}

# Calls the check_disk_space function.
check_disk_space

# This is a Bash function named "get_network_information" that retrieves network information.
function get_network_information() {
  # This variable will store the IPv4 address of the default network interface by querying the "ipengine" API using "curl" command and extracting it using "jq" command.
  DEFAULT_INTERFACE_IPV4="$(curl --ipv4 --connect-timeout 5 --tlsv1.2 --silent 'https://checkip.amazonaws.com')"
  # If the IPv4 address is empty, try getting it from another API.
  if [ -z "${DEFAULT_INTERFACE_IPV4}" ]; then
    DEFAULT_INTERFACE_IPV4="$(curl --ipv4 --connect-timeout 5 --tlsv1.3 --silent 'https://icanhazip.com')"
  fi
  # This variable will store the IPv6 address of the default network interface by querying the "ipengine" API using "curl" command and extracting it using "jq" command.
  DEFAULT_INTERFACE_IPV6="$(curl --ipv6 --connect-timeout 5 --tlsv1.3 --silent 'https://ifconfig.co')"
  # If the IPv6 address is empty, try getting it from another API.
  if [ -z "${DEFAULT_INTERFACE_IPV6}" ]; then
    DEFAULT_INTERFACE_IPV6="$(curl --ipv6 --connect-timeout 5 --tlsv1.3 --silent 'https://icanhazip.com')"
  fi
}

# Global Variables
# Sets the base directory for TeamSpeak server files
TEAMSPEAK_SERVER_DIR="/etc/teamspeak-server/"
# Set the default locale to English (US) with UTF-8 encoding
export LANG=en_US.UTF-8
# Override all locale settings with English (US) and UTF-8 encoding
export LC_ALL=en_US.UTF-8
# Set the language to English (US) with UTF-8 encoding
export LANGUAGE=en_US.utf8

# Check if the teamspeak-server directory exists,
if [ ! -d "${TEAMSPEAK_SERVER_DIR}" ]; then

  # Function to set the locale to English (US) with UTF-8 encoding
  function set-locales() {
    # Set the locale to English (US) with UTF-8 encoding
    locale-gen en_US.UTF-8
    # Update the system locale settings
    update-locale LANG=en_US.UTF-8
  }

  # Call the set-locales function to set the locale
  set-locales

  # Function to install the TeamSpeak server
  function install-teamspeak-server() {
    # Install the TeamSpeak server using the curl command to download the latest version from the official website.
    if { [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "x86_64" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "amd64" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "aarch64" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "arm64" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "powerpc64" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "ppc64le" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "s390x" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "riscv64" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "mips64" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "sparc64" ]; }; then
      # Download the 64-bit version of the TeamSpeak server.
      curl https://files.teamspeak-services.com/releases/server/3.13.7/teamspeak3-server_linux_amd64-3.13.7.tar.bz2 --create-dirs -o /etc/teamspeak-server/teamspeak3-server_linux_amd64-3.13.7.tar.bz2
      # Extract the downloaded tarball to the /etc/teamspeak-server directory.
      tar -xf /etc/teamspeak-server/teamspeak3-server_linux_amd64-3.13.7.tar.bz2 -C /etc/teamspeak-server/
      # Start the server.
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_amd64/ts3server_startscript.sh start
    elif { [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "i386" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "i686" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "armv7l" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "armv6l" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "mips" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "mipsel" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "ppc" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "sparc" ] || [ "${CURRENT_SYSTEM_ARCHITECTURE}" == "riscv32" ]; }; then
      # Download the 32-bit version of the TeamSpeak server.
      curl https://files.teamspeak-services.com/releases/server/3.13.7/teamspeak3-server_linux_x86-3.13.7.tar.bz2 --create-dirs -o /etc/teamspeak-server/teamspeak3-server_linux_x86-3.13.7.tar.bz2
      # Extract the downloaded tarball to the /etc/teamspeak-server directory.
      tar -xf /etc/teamspeak-server/teamspeak3-server_linux_x86-3.13.7.tar.bz2 -C /etc/teamspeak-server/
      # Start the server.
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_x86/ts3server_startscript.sh start
    else
      echo "Unsupported architecture: ${CURRENT_SYSTEM_ARCHITECTURE}. Please use a 64-bit or 32-bit system."
      # Exit the script with an error code.
      exit 1
    fi
  }

  # Call the install-teamspeak-server function to install the TeamSpeak server.
  install-teamspeak-server

else

  # Function to exit the script
  function exit_script() {
    echo "Exiting the script..."
    exit 0
  }

  # Function to display TeamSpeak server status
  function display_teamspeak_status() {
    if [ -d "/etc/teamspeak-server/teamspeak3-server_linux_amd64/" ]; then
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_amd64/ts3server_startscript.sh status
    elif [ -d "/etc/teamspeak-server/teamspeak3-server_linux_x86/" ]; then
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_x86/ts3server_startscript.sh status
    fi
  }

  # Function to start the TeamSpeak server
  function start_teamspeak_server() {
    if [ -d "/etc/teamspeak-server/teamspeak3-server_linux_amd64/" ]; then
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_amd64/ts3server_startscript.sh start
    elif [ -d "/etc/teamspeak-server/teamspeak3-server_linux_x86/" ]; then
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_x86/ts3server_startscript.sh start
    fi
  }

  # Function to stop the TeamSpeak server
  function stop_teamspeak_server() {
    if [ -d "/etc/teamspeak-server/teamspeak3-server_linux_amd64/" ]; then
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_amd64/ts3server_startscript.sh stop
    elif [ -d "/etc/teamspeak-server/teamspeak3-server_linux_x86/" ]; then
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_x86/ts3server_startscript.sh stop
    fi
  }

  # Function to restart the TeamSpeak server
  function restart_teamspeak_server() {
    if [ -d "/etc/teamspeak-server/teamspeak3-server_linux_amd64/" ]; then
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_amd64/ts3server_startscript.sh restart
    elif [ -d "/etc/teamspeak-server/teamspeak3-server_linux_x86/" ]; then
      TS3SERVER_LICENSE=accept bash /etc/teamspeak-server/teamspeak3-server_linux_x86/ts3server_startscript.sh restart
    fi
  }

  # Function to add a new TeamSpeak user
  function add_teamspeak_user() {
    read -rp "Enter the username: " username
    read -rp "Enter the password: " password
    echo "Adding new user: $username"
    # Add commands to create a new user here
  }

  # Function to remove a TeamSpeak user
  function remove_teamspeak_user() {
    read -rp "Enter the username to remove: " username
    echo "Removing user: $username"
    # Add commands to remove a user here
  }

  # Function to list all TeamSpeak users
  function list_teamspeak_users() {
    echo "Listing all TeamSpeak users..."
    # Add commands to list users here
  }

  # Function to update the TeamSpeak server configuration
  function update_teamspeak_config() {
    echo "Updating TeamSpeak server configuration..."
    # Add commands to update configuration here
  }

  # Function to backup the TeamSpeak server configuration
  function backup_teamspeak_config() {
    echo "Backing up TeamSpeak server configuration..."
    # Add commands to backup configuration here
  }

  # Function to restore the TeamSpeak server configuration
  function restore_teamspeak_config() {
    echo "Restoring TeamSpeak server configuration..."
    # Add commands to restore configuration here
  }

  # Function to display the menu and handle user input
  function teamspeak_next_questions_interface() {
    echo "Please select an action:"
    echo "   1) Exit"
    echo "   2) Display TeamSpeak server status"
    echo "   3) Start TeamSpeak server"
    echo "   4) Stop TeamSpeak server"
    echo "   5) Restart TeamSpeak server"
    echo "   6) Add a new TeamSpeak user"
    echo "   7) Remove a TeamSpeak user"
    echo "   8) List all TeamSpeak users"
    echo "   9) Update TeamSpeak server configuration"
    echo "   10) Backup TeamSpeak server configuration"
    echo "   11) Restore TeamSpeak server configuration"
    until [[ "${TEAMSPEAK_OPTIONS}" =~ ^[0-9]+$ ]] && [ "${TEAMSPEAK_OPTIONS}" -ge 1 ] && [ "${TEAMSPEAK_OPTIONS}" -le 11 ]; do
      read -rp "Select an Option [1-11]:" -e -i 0 TEAMSPEAK_OPTIONS
    done
    case ${TEAMSPEAK_OPTIONS} in
    1)
      # Exit the script
      exit_script
      ;;
    2)
      # Display TeamSpeak server status
      display_teamspeak_status
      ;;
    3)
      # Start TeamSpeak server
      start_teamspeak_server
      ;;
    4)
      # Stop TeamSpeak server
      stop_teamspeak_server
      ;;
    5)
      # Restart TeamSpeak server
      restart_teamspeak_server
      ;;
    6)
      # Add a new TeamSpeak user
      add_teamspeak_user
      ;;
    7)
      # Remove a TeamSpeak user
      remove_teamspeak_user
      ;;
    8)
      # List all TeamSpeak users
      list_teamspeak_users
      ;;
    9)
      # Update TeamSpeak server configuration
      update_teamspeak_config
      ;;
    10)
      # Backup TeamSpeak server configuration
      backup_teamspeak_config
      ;;
    11)
      # Restore TeamSpeak server configuration
      restore_teamspeak_config
      ;;
    esac
  }

  # Running the TeamSpeak menu
  teamspeak_next_questions_interface

fi
