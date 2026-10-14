#!/usr/bin/env python3
"""One shared JSON-lines sampler for the Quickshell session (Linux, no NM)."""

import argparse
import fcntl
import json
from pathlib import Path
import signal
import socket
import struct
import subprocess
import sys
import time


SYS_NET = Path("/sys/class/net")
BACKLIGHT = Path("/sys/class/backlight")

POWER_SUPPLY = Path("/sys/class/power_supply")

def read_int(path):
    return int(path.read_text().strip())


def cpu_counters():
    with open("/proc/stat") as source:
        fields = source.readline().split()
    if fields[0] != "cpu" or len(fields) < 9:
        raise ValueError("/proc/stat has no aggregate CPU counters")
    counters = [int(value) for value in fields[1:9]]
    # guest/guest_nice are already included in user/nice, so do not add them.
    return sum(counters), counters[3] + counters[4]


def memory_usage():
    values = {}
    with open("/proc/meminfo") as source:
        for line in source:
            key, value = line.split(":", 1)
            if key in ("MemTotal", "MemAvailable"):
                values[key] = int(value.split()[0])
    return round(100 * (1 - values["MemAvailable"] / values["MemTotal"]), 1)


def ipv4_address(name):
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as channel:
        try:
            result = fcntl.ioctl(channel, 0x8915, struct.pack("256s", name.encode()[:15]))
        except OSError:
            return ""
    return socket.inet_ntoa(result[20:24])

def ipv6_addresses():
    addresses = {}
    try:
        with open("/proc/net/if_inet6") as source:
            for line in source:
                fields = line.split()
                if int(fields[3], 16) == 0:  # Global, not link-local or loopback.
                    addresses.setdefault(fields[5], socket.inet_ntop(socket.AF_INET6, bytes.fromhex(fields[0])))
    except FileNotFoundError:
        pass  # IPv6 can be disabled by the kernel.
    return addresses


def select_interface():
    # Prefer a usable default route; retain IPv6-only links on iwd/networkd.
    routes = []
    with open("/proc/net/route") as source:
        next(source)
        for line in source:
            fields = line.split()
            if fields[1] == "00000000" and int(fields[3], 16) & 1:
                routes.append((int(fields[6]), fields[0]))
    try:
        with open("/proc/net/ipv6_route") as source:
            for line in source:
                fields = line.split()
                flags = int(fields[8], 16)
                if fields[0] == "0" * 32 and fields[1] == "00" and flags & 1 and not flags & 0x200:
                    routes.append((int(fields[5], 16), fields[9]))
    except FileNotFoundError:
        pass
    ipv6 = ipv6_addresses()
    defaults = [name for _, name in sorted(routes)]
    physical = sorted(path.name for path in SYS_NET.iterdir()
                      if (path / "device").exists() or (path / "wireless").exists())
    for name in dict.fromkeys(defaults + physical):
        if name == "lo":
            continue
        path = SYS_NET / name
        try:
            state = (path / "operstate").read_text().strip()
            carrier = read_int(path / "carrier")
        except OSError:
            continue  # Removed, administratively down, or no usable carrier data.
        address = ipv4_address(name) or ipv6.get(name, "")
        if carrier == 1 and state in ("up", "unknown") and address:
            return name, address
    return "", ""


def command_output(command, accepted=(0,)):
    result = subprocess.run(command, text=True, capture_output=True, timeout=3, check=False)
    if result.returncode not in accepted:
        raise RuntimeError(f"{command[0]} exited {result.returncode}: {result.stderr.strip()}")
    return result.stdout.strip()


def wifi_name(name, iw_command):
    if not (SYS_NET / name / "wireless").exists():
        return name
    output = command_output(iw_command + ["dev", name, "link"])
    for line in output.splitlines():
        if line.lstrip().startswith("SSID: "):
            return line.lstrip()[6:]
    if "Not connected." in output:
        return ""
    raise ValueError(f"iw returned no link/SSID for {name}")


def backlight_status():
    candidates = []
    for path in BACKLIGHT.iterdir():
        try:
            maximum = read_int(path / "max_brightness")
            kind = (path / "type").read_text().strip()
            current = read_int(path / "brightness")
        except OSError:
            continue  # A device may disappear during enumeration.
        if maximum > 0:
            candidates.append(({"raw": 0, "platform": 1, "firmware": 2}.get(kind, 3),
                               path.name, current, maximum))
    if not candidates:
        return {"brightnessAvailable": False, "brightnessPercent": 0, "brightnessDevice": ""}
    _, name, current, maximum = min(candidates)
    return {"brightnessAvailable": True,
            "brightnessPercent": round(100 * current / maximum, 1),
            "brightnessDevice": name}


def battery_status():
    # Both hosts already expose batteries through sysfs; no new root daemon or
    # UPower requirement is needed just to replace Waybar.
    for path in sorted(POWER_SUPPLY.iterdir()):
        if (path / "type").read_text().strip() != "Battery":
            continue
        if (path / "scope").exists() and (path / "scope").read_text().strip() == "Device":
            continue
        if (path / "present").exists() and not read_int(path / "present"):
            continue
        state = (path / "status").read_text().strip()
        charging = state == "Charging"
        remaining = ""
        if state in ("Charging", "Discharging"):
            for unit, rate in (("energy", "power"), ("charge", "current")):
                if not all((path / name).exists() for name in (unit + "_now", unit + "_full", rate + "_now")):
                    continue
                amount = read_int(path / (unit + "_now"))
                full = read_int(path / (unit + "_full"))
                speed = read_int(path / (rate + "_now"))
                if speed > 0:
                    minutes = round(60 * (full - amount if charging else amount) / speed)
                    remaining = f"{minutes // 60}h {minutes % 60}m"
                break
        return {"batteryAvailable": True, "batteryPercent": read_int(path / "capacity"),
                "batteryCharging": charging, "batteryTime": remaining}
    return {"batteryAvailable": False, "batteryPercent": 0, "batteryCharging": False, "batteryTime": ""}


def rate_text(value):
    for unit in ("B/s", "KiB/s", "MiB/s", "GiB/s"):
        if value < 1024 or unit == "GiB/s":
            return f"{value:.1f} {unit}" if unit != "B/s" else f"{value:.0f} {unit}"
        value /= 1024


class Sampler:
    def __init__(self, args):
        self.args = args
        self.previous_cpu = None
        self.previous_network = None

    def sample(self):
        result = {"cpuUsage": None, "memoryUsage": None,
                  "networkName": "", "networkAddress": "", "networkUp": False,
                  "downloadRate": "", "uploadRate": "",
                  "brightnessAvailable": False, "brightnessPercent": 0,
                  "brightnessDevice": "", "keyboardActive": False}
        result.update(batteryAvailable=False, batteryPercent=0, batteryCharging=False, batteryTime="")
        result.update(powerProfilesAvailable=False, powerProfilesError="")
        errors = []
        try:
            current = cpu_counters()
            if self.previous_cpu is not None:
                total = current[0] - self.previous_cpu[0]
                idle = current[1] - self.previous_cpu[1]
                if total > 0 and 0 <= idle <= total:
                    result["cpuUsage"] = round(100 * (total - idle) / total, 1)
            self.previous_cpu = current
        except (OSError, ValueError) as error:
            self.previous_cpu = None
            errors.append(f"CPU: {error}")
        try:
            result["memoryUsage"] = memory_usage()
        except (OSError, ValueError, KeyError, ZeroDivisionError) as error:
            errors.append(f"Memory: {error}")
        try:
            name, address = select_interface()
            if name:
                label = wifi_name(name, self.args.iw_command)
                if label:  # A Wi-Fi disassociation must not appear connected.
                    path = SYS_NET / name / "statistics"
                    received = read_int(path / "rx_bytes")
                    sent = read_int(path / "tx_bytes")
                    now = time.monotonic()
                    result.update(networkName=label, networkAddress=address, networkUp=True)
                    previous = self.previous_network
                    if previous and previous[0] == name:
                        elapsed = now - previous[3]
                        if elapsed > 0 and received >= previous[1] and sent >= previous[2]:
                            result["downloadRate"] = rate_text((received - previous[1]) / elapsed)
                            result["uploadRate"] = rate_text((sent - previous[2]) / elapsed)
                    self.previous_network = (name, received, sent, now)
                else:
                    self.previous_network = None
            else:
                self.previous_network = None
        except (OSError, ValueError, IndexError, RuntimeError, subprocess.TimeoutExpired) as error:
            self.previous_network = None
            errors.append(f"Network: {error}")
        try:
            result.update(backlight_status())
        except (OSError, ValueError) as error:
            errors.append(f"Backlight: {error}")
        try:
            result.update(battery_status())
        except (OSError, ValueError) as error:
            errors.append(f"Battery: {error}")
        # Native QML supplies live profiles/capabilities, but has no service-availability API.
        # Probe only the machine-readable active profile, with the shared three-second bound.
        if self.args.powerprofiles_command:
            try:
                profile = command_output(self.args.powerprofiles_command + ["get"])
                if profile not in ("power-saver", "balanced", "performance"):
                    raise ValueError(f"unexpected power profile: {profile}")
                result["powerProfilesAvailable"] = True
            except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
                result["powerProfilesError"] = str(error)
        if self.args.keyboard_unit:
            try:
                state = command_output(self.args.systemctl_command +
                                       ["--user", "is-active", self.args.keyboard_unit], (0, 3))
                if state not in ("active", "inactive", "failed", "activating", "deactivating", "reloading"):
                    raise ValueError(f"unexpected keyboard unit state: {state}")
                result["keyboardActive"] = state in ("active", "reloading")
            except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
                errors.append(f"Keyboard: {error}")
        result["errors"] = errors
        return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iw-command", type=json.loads, default=["iw"], help="JSON argv array")
    parser.add_argument("--keyboard-unit", default="")
    parser.add_argument("--systemctl-command", type=json.loads, default=["systemctl"], help="JSON argv array")
    parser.add_argument("--powerprofiles-command", type=json.loads, default=[], help="JSON argv array")
    args = parser.parse_args()
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    sampler = Sampler(args)
    while True:
        print(json.dumps(sampler.sample(), ensure_ascii=False, allow_nan=False), flush=True)
        time.sleep(5)


if __name__ == "__main__":
    main()
