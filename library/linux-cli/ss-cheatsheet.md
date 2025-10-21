---
desc: "ss Command**
---

# `ss` Command (Socket Statistics)

The `ss` command is a utility for examining sockets, and it is a faster, more modern alternative to `netstat` (although `netstat` is still widely used). `ss` can display more TCP and state information than `netstat`, and is especially efficient at handling large numbers of connections.

## Basic Usage and Common Options:

*   **`ss`**: Displays a list of all open sockets (established, listening, etc.).

*   **Show listening sockets**:
    ```bash
    ss -l
    ```

*   **Show all sockets (listening and non-listening)**:
    ```bash
    ss -a
    ```

*   **Show only TCP sockets**:
    ```bash
    ss -t
    ```

*   **Show only UDP sockets**:
    ```bash
    ss -u
    ```

*   **Combine options (e.g., TCP listening sockets)**:
    ```bash
    ss -lt
    ```

*   **Show TCP sockets with port numbers instead of service names**:
    ```bash
    ss -nt
    ```

*   **Show detailed information (PID, user, etc.)**:
    ```bash
    ss -p
    ss -pli
    ```
    `-p` shows the process using the socket.
    `-i` shows internal TCP socket information.
    `-l` listening sockets.

*   **Show sockets by state**:
    You can filter by TCP states like `established`, `syn-sent`, `syn-recv`, `fin-wait-1`, `fin-wait-2`, `time-wait`, `close`, `close-wait`, `last-ack`, `listening`.
    ```bash
    ss -s # Shows a summary of socket statistics
    ss -t state established # Shows only established TCP connections
    ss -nt state time-wait # Shows sockets in TIME-WAIT state
    ```

*   **Filter by port**:
    ```bash
    ss -ltn 'sport = :80' # Listening sockets on source port 80
    ss -nt '( dport = :22 or sport = :22 )' # Connections on port 22 (source or destination)
    ```

## Common Use Cases for `ss`:

*   Get a quick overview of network connections.
*   Quickly identify which ports are in the `LISTENING` state.
*   Diagnose network performance issues or "hung" connections (e.g., many sockets in `TIME-WAIT` or `CLOSE-WAIT`).
*   Verify which programs are using a network connection.
*   Monitor the state of the connection table and detect potential SYN attacks.

