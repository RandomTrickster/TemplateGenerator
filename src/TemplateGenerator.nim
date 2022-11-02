import os
import strformat

proc printHelp() =
  echo fmt"Usage: {getAppFilename()} <Template> [Destination]"

proc main(): int =
  if (paramCount() == 0):
    printHelp()
    return 1
  else:
    var plate = paramStr(1)
    if (dirExists(getConfigDir() / "templateGenerator" / plate)):
      if (paramCount() >= 2):
        var target = paramStr(2)
        copyDir(getConfigDir() / "templateGenerator" / plate, target)
      else:
        copyDir(getConfigDir() / "templateGenerator" / plate, lastPathPart(plate))
    else:
      echo "Template not found. Is it case-sensitive?"
      return 1

when isMainModule:
  var exitCode = main()
  quit(exitCode)