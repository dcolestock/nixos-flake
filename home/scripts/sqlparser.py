import sys
from subprocess import Popen, PIPE
from pathlib import Path

logfile = Path.home() / "sqlparser.log"

contents = sys.stdin.read()

with logfile.open("a") as f:
    f.write("\n\n" + repr(contents))
    f.write(f"\nargs:{sys.argv}")

p = Popen(['sql-formatter'], stdout=PIPE, stdin=PIPE, stderr=PIPE)
result = p.communicate(input=contents.encode())[0].decode()

# Keep as one line if started as one line to prevent
# messing up SQL in regular quotes (not always in block quotes)
if "\n" not in contents.removesuffix("\n"):
    result = " ".join(line.strip() for line in result.splitlines()) + "\n"

print(result)
