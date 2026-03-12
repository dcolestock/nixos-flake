import sys
from subprocess import PIPE, Popen

contents = sys.stdin.read()

p = Popen(["sql-formatter"], stdout=PIPE, stdin=PIPE, stderr=PIPE)
result = p.communicate(input=contents.encode())[0].decode().removesuffix("\n")

# Keep as one line if started as one line to prevent
# messing up SQL in regular quotes (not always in block quotes)
if "\n" not in contents:
    result = " ".join(line.strip() for line in result.splitlines())

print(result)
