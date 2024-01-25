import sys
import sqlparse
from pathlib import Path

logfile = Path.home() / "sqlparser.log"

contents = sys.stdin.read()

with logfile.open("a") as f:
    f.write("\n\n" + repr(contents))

result = sqlparse.format(
    contents,
    keyword_case="upper",
    identifier_case="lower",
    reindent=True,
    reindent_aligned=True,
    output_format="sql",
    wrap_after=80,
    comma_first=False,
)

if "\n" not in contents.removesuffix("\n"):
    result = " ".join(line.strip() for line in result.splitlines()) + "\n"

print(result)
