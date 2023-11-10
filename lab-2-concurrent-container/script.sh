getNameFromNumber () {
    if [[ $1 -lt 10 ]]; then
        echo "00$1"
        return
    fi
    if [[ $1 -lt 100 ]]; then
        echo "0$1"
        return
    fi
    echo "$1"
}

getFileName () {
    takenNames=$(ls | grep -E "^[0-9]{3}$" | tr "\n" " ")

    counter=1
    name="$(getNameFromNumber $counter)"
    pattern=".*$name.*"
    while [[ $takenNames =~ $pattern ]]
    do
        (( ++counter ))
        name="$(getNameFromNumber $counter)"
        pattern=".*$name.*"
    done

    echo "$name"
}

if [[ ! $CONTAINER_ID ]]; then
    CONTAINER_ID=$HOSTNAME
fi

writeFile () {
    fileName=$(getFileName)
    echo "$CONTAINER_ID $fileName" > "$fileName"
    echo "$fileName"
}

randTime () {
    echo $((1 + RANDOM % 10))
}

while true
do
    initial=$PWD
    cd /shared || exit
    if [[ $current ]]; then
        flock -s "$current" -c "rm $current"
        echo "$HOSTNAME DELETED $current"
        current=""
        sleepTime=$(randTime)
        echo "$HOSTNAME SLEEP $sleepTime"
        sleep $sleepTime
    else
        current=$(flock -s ".lock" -c "echo $(writeFile)")
        echo "$HOSTNAME CREATED $current"
        sleepTime=$(randTime)
        echo "$HOSTNAME SLEEP $sleepTime"
        sleep $sleepTime
    fi
    cd "$initial" || exit
done
