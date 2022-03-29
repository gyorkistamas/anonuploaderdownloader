#!/bin/bash


uploadfile()
{

    if  [ ! -f "$1" ]; then
		echo "A fájl nem létezik/nem található."
		return 0
    fi

    curl --silent -F "file=@$1" https://api.anonfiles.com/upload > /tmp/filetemp.txt

	STATE=`jq .status /tmp/filetemp.txt`

    if [ "$STATE" = "true" ]; then
		echo -e "Sikeres fájfeltöltés."
		LINK=`jq .data.file.url.short /tmp/filetemp.txt | sed 's/"//g'`
		echo "Link: $LINK"
	else
		ERROR=`jq .error.message /tmp/filetemp.txt`
		echo "Hiba a feltöltés során: $ERROR"
	fi


	rm /tmp/filetemp.txt
}


downloadfile()
{
	curl --silent $1 > /tmp/filetemp.txt

	LINK=`cat /tmp/filetemp.txt | grep "https://cdn-" | cut -d\" -f2`

	wget $LINK

	rm /tmp/filetemp.txt
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