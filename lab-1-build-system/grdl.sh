#!/usr/bin/bash

quiet=0
buildDir="build"
manifest=".mf"
mainClass=""
mainClassResolution="._tempMainClassResolution"

clean () {
  ls -A | grep $1 | xargs rm -r &> /dev/null
}

cleanTemp () {
  say ":cleanTemp"
  clean "^\(build\.\w\{3\}\.tempBuild\)$"
}

cleanBuild () {
  say ":cleanBuild"
  clean "^\(out\|build\)$"
  cleanTemp
}

cleanAll () {
  say ":cleanAll"
  cleanBuild
  cleanTemp
  clean "*.mf"
  clean "*.jar"
  clean $mainClassResolution
}

cancelBuild () {
    say ":cancel"
    cleanAll
    EXIT "Build has been cancelled"
}

say () {
  if [[ $quiet -eq 1 ]]; then
    return
  fi
  echo -e "$@"
}

sayTask () {
  say "TASK $1"
}

sayComplete () {
  say "TASK $1 DONE"
}

createManifest () {
  echo "Main-Class: $buildDir.$mainClass" > "$manifest"
  echo "" >> "$manifest"
}

resolveMain () {
    if [[ $# -eq 1 ]]; then
        grep -Rnwl ./src/ -e '\/\/\/MainClass\/\/\/' > $mainClassResolution
        if [[ ! $(wc -l < $mainClassResolution) -eq 1 ]]; then
            EXIT "Main class not found."
        fi
        mainClass=$(sed 's/\(\.\w\+\|\(\(\w\|\.\)\+\/\)\)//g' < $mainClassResolution)
    elif [[ $# -eq 2 ]]; then
        mainClass=$2
        return
    fi
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
  cleanTemp
}

jjar () {
  say ":jjar"
  buildJar
  cleanBuild
  cleanTemp
  clean "*.mf"
  clean $mainClassResolution
}

build () {
  say ":build"
  cleanAll
  mktemp -d --suffix=".tempBuild" "$buildDir"".XXX" >> /dev/null
  compile
  cleanTemp
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
    "clean") # delete all temp and build files
      sayTask "clean"
      cleanAll
      sayComplete "clean"
    ;;
    "build") # build src into $buildDir
      sayTask "build"
      build
      sayComplete "build"
    ;;
    "jar") # build task, but make jar
      sayTask "jar"
      resolveMain $#
      buildJar
      sayComplete "jar"
    ;;
    "jjar") # jar task, but delete build
      sayTask "jjar"
      resolveMain $#
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

trap cancelBuild SIGINT
taskHandler "$@"
