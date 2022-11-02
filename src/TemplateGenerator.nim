import os
import strformat
import strutils

proc printHelp() =
  echo fmt"""
  Usage: {relativePath(getAppFilename(), getCurrentDir())} <command>
  <command> can be one of the following:
    load <template> [target]           - copy <template> to a new directory [target] or template name
    create <directory> [template name] - create a new template from <diretory>, uses directory name if no name is given
    rename <template> <new name>       - rename <template>
    remove, rm <template>              - remove <template>
    list [subgroup]                    - list templates
    implode                            - remove all templates
  """

proc loadTemplate(plate: string, target: string): int =
    if (dirExists(getConfigDir() / "templateGenerator" / plate)):
      if (target.isEmptyOrWhitespace() == false):
        copyDir(getConfigDir() / "templateGenerator" / plate, target)
      else:
        copyDir(getConfigDir() / "templateGenerator" / plate, lastPathPart(plate))
    else:
      echo fmt"Template {plate} not found. Is it case-sensitive?"
      return 1

proc createTemplate(dir: string, name: string): int =
  if dirExists(dir) != true:
    echo fmt"Directory {dir} not found."
    return 1
  else:
    if (name.isEmptyOrWhitespace()):
      copyDir(dir, getConfigDir() / "templateGenerator" / lastPathPart(dir))
      echo fmt"Created template {lastPathPart(dir)}."
      return 0
    else:
      copyDir(dir, getConfigDir() / "templateGenerator" / name)
      echo fmt"Created template {name}."
      return 0

proc renameTemplate(plate: string, name: string): int =
  if dirExists(getConfigDir() / "templateGenerator" / plate) != true:
    echo fmt"Template {plate} not found. Is it case-sensitive?"
    return 1
  else:
    moveDir(getConfigDir() / "templateGenerator" / plate, getConfigDir() / "templateGenerator" / name)
    echo fmt"Renamed {plate} to {name}."
    return 0

proc removeTemplate(): int =
  for i in 2 .. paramCount():
    if (paramStr(i).isEmptyOrWhitespace):
      continue

    if (dirExists(getConfigDir() / "templateGenerator" / paramStr(i)) != true):
      echo fmt"Template {paramStr(i)} not found. Is it case-sensitive?"
      return 1
    else:
      removeDir(getConfigDir() / "templateGenerator" / paramStr(i))
      echo fmt"Removed {paramStr(i)}."

proc listTemplates(): int =
  for kind, path in walkDir(getConfigDir() / "templateGenerator"):
    if (kind == pcDir):
      echo relativePath(path, getConfigDir() / "templateGenerator")
  return 0

proc listTemplates(subgroup: string): int =
  if (dirExists(getConfigDir() / "templateGenerator" / subgroup) != true):
    echo fmt"Subgroup {subgroup} not found. Is it case-sensitive?"
    return 1

  for kind, path in walkDir(getConfigDir() / "templateGenerator" / subgroup):
    if (kind == pcDir):
      echo relativePath(path, getConfigDir() / "templateGenerator")
  return 0

proc implodeTemplates(): int =
  echo "!!!WARNING!!! This will remove all your templates and CANNOT BE UNDONE. Are you sure you want to proceed? [y/N]"
  if (stdin.readLine() == "y" or stdin.readline() == "yes"):
      removeDir(getConfigDir() / "templateGenerator")
      return 0
  else:
    return 0

proc main(): int =
    case paramCount()
    of 0:
      printHelp()
      return 1
    of 1:
      if (paramStr(1) == "list"):
        return listTemplates()
      else:
        if (paramStr(1) == "implode"):
          return implodeTemplates()

        printHelp()
        return 1
    else:
      if (paramStr(2).isEmptyOrWhitespace):
        printHelp()
        return 1

      case paramStr(1)
      of "load":
        return loadTemplate(paramStr(2), if paramCount() == 3: paramStr(3) else: "")
      of "create":
        return createTemplate(paramStr(2), if paramCount() == 3: paramStr(3) else: "")
      of "rename":
        if (paramCount() < 3):
          echo "Missing arguments."
          printHelp()
          return 1
        else:
          if (paramStr(3).isEmptyOrWhitespace()):
            echo "Missing arguments."
            printHelp()
            return 1
          else:
            return renameTemplate(paramStr(2), paramStr(3))
      of "remove":
        return removeTemplate()
      of "rm":
        return removeTemplate()
      of "list":
        return listTemplates(paramStr(2))
      else:
        printHelp()
        return 1

when isMainModule:
  var exitCode = main()
  quit(exitCode)