---
up: "[[Linux CLI]]"
related: []
note_type: cheatsheet
library_type: linux-cli
desc: "lsof command"
tags: [Linux, CLI, linux-cli]
---

# `lsof` Command (List Open Files)

The `lsof` command is used to list all open files by running processes. In Linux, "everything is a file," including network sockets, pipes, devices, and regular files. This makes it a very powerful tool for debugging issues related to port occupancy, filesystem activity, or processes that do not release resources.

## Basic Usage and Common Options:

*   **`lsof`**: Displays a very extensive list of all files opened by all processes. It's useful to pipe its output to `less` or `grep`.
    ```bash
    lsof | less
    ```

*   **List open files by a specific process (PID)**:
    ```bash
    lsof -p <PID>
    ```
    For example, for an Apache web server: `lsof -p $(pgrep apache2)`

*   **List processes that have a file or directory open**:
    ```bash
    lsof <file_or_directory_name>
    ```
    Example: `lsof /var/log/syslog`

*   **List all network connections (sockets)**:
    ```bash
    lsof -i
    ```

*   **List network connections on a specific port**:
    ```bash
    lsof -i :<port_number>
    ```
    Example: `lsof -i :80` (for HTTP)

*   **List TCP/UDP connections**:
    ```bash
    lsof -i tcp
    lsof -i udp
    ```

*   **List connections by user**:
    ```bash
    lsof -u <username>
    ```
    Example: `lsof -u www-data`

*   **View the command associated with open files**:
    ```bash
    lsof -c <command_name>
    ```
    Example: `lsof -c sshd`

*   **Exclude users**:
    ```bash
    lsof -u ^root
    ```
    (Excludes files opened by the `root` user)

## Common Use Cases for `lsof`:

*   Identify which process is using a specific port (useful for "Address already in use" errors).
*   Find out which process is locking a file or device.
*   Audit a process's activity by seeing what resources it's accessing.
*   Diagnose filesystem mount/unmount issues.

