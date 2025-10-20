## Introduction

I'll explain how to clone a KVM virtual guest from the CLI on a host machine, starting from a domain named `terminal-001`.

## Understanding KVM Cloning

**Basic technology context**: KVM (Kernel-based Virtual Machine) is a virtualization technology built into Linux. When you create virtual machines (called "domains" or "guests"), they consist of two main components: a configuration file (XML) that defines the VM's settings, and disk image files that contain the actual data. Cloning creates a copy of both.

## Cloning Process

### Method 1: Using virt-clone (Recommended)

The `virt-clone` utility is specifically designed for this purpose and handles all the complexity automatically.

**Basic syntax:**
```bash
sudo virt-clone \
  --original terminal-001 \
  --name terminal-002 \
  --auto-clone
```

**With custom disk location:**
```bash
sudo virt-clone \
  --original terminal-001 \
  --name terminal-002 \
  --file /var/lib/libvirt/images/terminal-002.qcow2
```

**Breaking down the options:**
- `--original`: The source domain name (terminal-001)
- `--name`: The new clone's name
- `--auto-clone`: Automatically generates new disk paths and MAC addresses
- `--file`: Manually specify where the cloned disk should be stored

### Method 2: Manual Cloning (More Control)

If you need more control or `virt-clone` isn't available:

**Step 1: List existing domains**
```bash
virsh list --all
```

**Step 2: Shutdown the source VM (recommended)**
```bash
virsh shutdown terminal-001
```

**Step 3: Export the domain XML**
```bash
virsh dumpxml terminal-001 > terminal-002.xml
```

**Step 4: Copy the disk image**
```bash
# Find the disk location first
virsh domblklist terminal-001

# Copy the disk (assuming qcow2 format)
sudo cp /var/lib/libvirt/images/terminal-001.qcow2 \
        /var/lib/libvirt/images/terminal-002.qcow2
```

**Step 5: Edit the XML file**
```bash
sudo nano terminal-002.xml
```

Change:
- `<name>terminal-001</name>` → `<name>terminal-002</name>`
- Remove the `<uuid>` line (a new one will be generated)
- Update disk path to point to the new disk image
- Change MAC address in `<mac address='...'/>` (or remove the line)

**Step 6: Define the new domain**
```bash
virsh define terminal-002.xml
```

**Step 7: Start the cloned VM**
```bash
virsh start terminal-002
```

## Verification

Check that the clone was created successfully:
```bash
virsh list --all
virsh dominfo terminal-002
```

## Important Considerations

1. **VM State**: It's best to clone when the source VM is shut down to ensure data consistency
2. **Disk Space**: Ensure you have enough space for the cloned disk
3. **Network**: The clone will get a new MAC address to avoid conflicts
4. **Hostname**: After cloning, you should change the hostname inside the guest OS to avoid confusion
