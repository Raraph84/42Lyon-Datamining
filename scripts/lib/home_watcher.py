#!/usr/bin/env python3

import time
import subprocess
import argparse
import os
import logging
from logging.handlers import RotatingFileHandler

LOG_DIR_NAME = '/tmp/home_watcher_logs'
LOGFILE_NAME = 'home_watcher.log'

# Set up the logger with a fallback mechanism
def setup_logger(username):
    """Set up the logger with rotating file handler and fallback to console if logfile is inaccessible."""
    logger = logging.getLogger('home_watcher')
    logger.setLevel(logging.INFO)  # Set the logging level

    try:
        logdir = LOG_DIR_NAME + "-" + username

        if not os.path.exists(logdir):
            os.makedirs(logdir, exist_ok=True)
            os.chmod(logdir, 0o1744)

        logfile = os.path.join(logdir, LOGFILE_NAME)

        if not os.path.exists(logfile):
            open(logfile, 'a').close()  # Create the file if it doesn't exist


        # Create a rotating file handler (1MB per file, with 3 backups)
        handler = RotatingFileHandler(logfile, maxBytes=1*1024*1024, backupCount=3)
        handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
        logger.addHandler(handler)

    except Exception as e:
        # If the logfile is inaccessible, log to the console
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
        logger.addHandler(console_handler)
        logger.error(f"Failed to access logfile {logfile}: {e}. Falling back to console logging.")

    return logger

# Execute a shell command and log the result
def cmd(arg, logger):
    rc = subprocess.getstatusoutput(arg)
    logger.info('%s => %d (%s)' % (arg, rc[0], rc[1]))
    return rc

# Simulate access to the user's home directory to detect issues
def simulate_directory_access_error(username, logger):
    """Simulate access to a directory within the user's home directory."""
    test_dir_path = f"/home/{username}"
    try:
        # Attempt to list the contents of the directory
        os.listdir(test_dir_path)
        logger.info(f"Access to directory {test_dir_path} succeeded.")
        return True
    except Exception as e:
        logger.error(f"Access to directory {test_dir_path} failed with error: {e}")
        return False

# Monitor the home directory and terminate session if it becomes inaccessible
def watch_home(username, logger):
    """Watch the user's home directory and terminate the session if it's inaccessible."""
    if not simulate_directory_access_error(username, logger):
        logger.error(f"Home directory for user {username} is inaccessible. Triggering session termination...")

        # Terminate the user's GNOME session
        rc, out = cmd("/usr/bin/gnome-session-quit --logout --no-prompt", logger)
        if rc == 0:
            logger.info(f"Session for user {username} successfully logged out.")
        else:
            logger.error(f"Failed to log out the session for user {username}. Output: {out}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Watch a user\'s home directory.')
    parser.add_argument('username', type=str, help='Username of the home directory to watch')
    
    args = parser.parse_args()
    username = args.username

    # Setup logging
    logger = setup_logger(username)

    # Start the directory watch loop
    while True:
        logger.info('home_watcher initialized')
        watch_home(username, logger)
        time.sleep(5)
