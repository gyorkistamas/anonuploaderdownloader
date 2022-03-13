#!/bin/sh


uploadfile()
{

    if  [ ! -f "$1" ]; then
		echo "A fájl nem létezik/nem található."
		return 0
    fi

    curl --silent -F "file=@$1" https://api.anonfiles.com/upload > .temp.txt

	STATE=$(jq .status .temp.txt)

    if [ "$STATE" = "true" ]; then
		echo "\nSikeres fájfeltöltés.\n"
		LINK=$(jq .data.file.url.short .temp.txt | sed 's/"//g')
		echo "Link: $LINK"
	else
		ERROR=jq .error.message .temp.txt
		echo "Hiba a feltöltés során: $ERROR"
	fi


	rm .temp.txt
}


downloadfile()
{
	curl --silent $1 > .temp.txt

	LINK=$(cat .temp.txt | grep "https://cdn-" | cut -d\" -f2)

	wget $LINK

	rm .temp.txt
}

help()
{
	echo "fileuploader - Gyors fájfeltöltés anonfiles.com-ra\n"
	echo "Használat: ./fileuploader.sh [opció] <argumentum>\n"
	echo "Kapcsolók: -u [elérési út]: fájl feltöltése\n"
	echo "           -d [link]: fájl letöltése anonfiles.com-ról\n"
	echo "           -h: Ezen segítség megjelenítése."

}


while getopts "u:d:h" opt; do

    case $opt in
	u)
	    uploadfile $OPTARG
	;;

	d)
		downloadfile $OPTARG
	;;

	h)
		help
	;;

	\?)
	    echo "Ismeretlen kapcsoló: $OPTARG"
	;;
    esac

done