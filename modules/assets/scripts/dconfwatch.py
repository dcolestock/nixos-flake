import subprocess
from pathlib import Path

outfile = Path.home() / ".dconf_history"

ignore_list = ["last-panel", "search-filter-time-type", "command-history"]


def log(message):
    if not message.endswith("\n"):
        message += "\n"
    with outfile.open("a") as f:
        f.write(message)


def process_previous_lines(commands):
    if len(commands) == 0:
        return
    if len(commands) != 2:
        log(f"Error: Expecting 2 lines. Instead, got {commands}")
        return
    dconfpath, dconfvar = commands[0][1:].rsplit("/", 1)
    value = commands[1].replace("'", '"').replace(",", " ")
    if dconfvar not in ignore_list:
        log(f'"{dconfpath}".{dconfvar} = {value};')


def main():
    process = subprocess.Popen(["dconf", "watch", "/"], stdout=subprocess.PIPE)
    if process.stdout is None:
        log("dconf had no stdout")
        return

    commands = []
    for rawline in iter(process.stdout.readline, ""):
        line = rawline.decode().strip()
        if line == "":
            process_previous_lines(commands)
            commands = []
        else:
            commands.append(line)


if __name__ == "__main__":
    main()
