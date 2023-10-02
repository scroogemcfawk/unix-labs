#!/usr/bin/bash

quiet=0
buildDir="build"
manifest=".mf"
mainClass="App"

clean () {
  ls -A | grep $1 | xargs rm -r &> /dev/null
}

cleanTemp () {
  say ":cleanTemp"
  clean "^$buildDir$"
}

cleanBuild () {
  say ":cleanBuild"
  clean "^\(out\|build\)$"
}

cleanAll () {
  say ":cleanAll"
  cleanBuild
  cleanTemp
  clean "*.mf"
  clean "*.jar"
}

say () {
  if [[ $quiet -eq 1 ]]; then
    return
  fi
  echo -e "$@"
}

createManifest () {
  echo "Main-Class: $buildDir.$mainClass" > "$manifest"
  echo "" >> "$manifest"
}

checkMain () {
  say ":checkMain"
  if [[ ! "$(find . -name $mainClass.class | wc -l)" -eq 1 ]]; then
    return 0
  fi
  return 1
}

sayAskClasses () {
  echo "Show all classes? [y/n]"
  read prompt
  case $prompt in
    "y")
      find . -name "*.class"
    ;;
    *)
    ;;
  esac
}

buildJar () {
  say ":buildJar"
  build
  if checkMain ; then
    say "Class $mainClass not found."
    sayAskClasses
    cleanAll
    EXIT "Main class $mainClass not found."
  fi
  jar -cfe "$mainClass.jar" "$mainClass" -C "$buildDir" .
}

jjar () {
  say ":jjar"
  buildJar
  cleanBuild
  cleanTemp
  clean "*.mf"
}

build () {
  say ":build"
  cleanAll
  mkdir "$buildDir"
  compile
}

compile () {
  say ":compile"
  javac -d $buildDir -cp ./src ./src/*.java
}

EXIT () {
  if [[ $# -eq 0 ]]; then
    exit 0
  fi
  say "EXIT:" "$@"
  exit 1
}

sayHelp () {
  say "grdl commands:"
  say "\\tclean - clean everything"
  say "\\tbuild - compile classes from 'src/' into '\$buildDir/'"
  say "\\tjar - build and make executable \$mainClass.jar"
}

taskHandler () {
  case $1 in
    "clean")
      say "Task: clean"
      cleanAll
    ;;
    "build")
      say "Task: build"
      build
    ;;
    "jar")
      say "Task: jar"
      if [[ ! $# -eq 2 ]]; then
        EXIT "Illegal number of arguments. jjar must contain only main class name."
      fi
      mainClass=$2
      buildJar
    ;;
    "jjar")
      say "Task: jjar"
      if [[ ! $# -eq 2 ]]; then
        EXIT "Illegal number of arguments. jjar must contain only main class name."
      fi
      mainClass=$2
      jjar
    ;;
    *)
      say "Task is not recognized. See options:"
      sayHelp
      EXIT "Task not found."
    ;;
  esac
}

if [[ $# == 0 ]]; then
  sayHelp
  EXIT
fi

taskHandler "$@"
