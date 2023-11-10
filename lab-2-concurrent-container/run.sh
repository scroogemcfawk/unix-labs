getOS () {
    shopt -s nocasematch
    windows=".*windows.*"
    linux=".*linux.*"
    if [[ $OS =~ $windows ]]; then
        echo "windows"
        return
    fi
    if [[ $OS =~ $linux ]]; then
        echo "linux"
        return
    fi
    exit
}

getPWD () {
    if [[ $1 == "windows" ]]; then
        pwd -W
    elif [[ $1 == "linux" ]]; then
        pwd
    fi
}

setUp () {
    [[ -d "script" ]] || mkdir script
    [[ -d "shared" ]] || mkdir shared
    [[ -f "/script/script.sh" ]] || cp "./script.sh" "./script/script.sh"
}

os=$(getOS)

pwd=$(getPWD "$os")

setUp

n=$1
if [[ ! $n ]]; then
    n=1
fi

./clean.sh
# shellcheck disable=SC2034
for i in $(seq 1 $n)
do
    docker run -v "$pwd/script":/script -v "$pwd/shared":/shared -tid smf/lab2:latest
done
