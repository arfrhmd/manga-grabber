#!/bin/bash
# Manga Images Grabber v3
# Coded by Arief (W.S.J)

h='\e[38;5;85m' # HIJAU
m='\e[38;5;196m' # MERAH
ch='\e[38;5;195m' # CYAN HIJAU
c='\e[38;5;87m' # CYAN
hh='\e[38;5;118m' # HIJAU 2
df='\033[0m' # DEFAULT

ua="Mozilla/5.0 (X11; Linux x86_64; rv:56.0) Gecko/20100101 Firefox/56.0"

function getinfo(){
	judul=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's: :-:g');
	getin=$(curl -s -A "$ua" "https://www.pecintakomik.com/manga/$judul/" | sed -e 's:<[^>]*>::g' > info.tmp);
	genres=$(cat info.tmp | grep -Po 'Genre:[^:]*' | sed 's:\tDiterbitkan::g; s:Genre\: ::g'); # menampilkan genre
	status=$(cat info.tmp | grep -Po 'Status: (Ongoing|Completed)' | sed 's/Status: //g'); # cek status manga (ongoing/completed)
	latch=$(cat info.tmp | grep -Po 'Chapter Terakhir:Chapter [0-9]*' | sed 's/Chapter Terakhir://g'); # cek chapter terbaru
	if [[ $(curl -s -A "$ua" -w "%{http_code}\\n" "https://www.pecintakomik.com/manga/$judul/") =~ "301" ]]; then
		echo -e "${m}MANGA NOT FOUND / TIDAK DITEMUKAN${df}";
		exit 0
	else
		echo -e "${c}Title  : ${h}$title";
		echo -e "${c}Genres : ${h}$genres";
		echo -e "${c}Status : ${h}$status";
		echo -e "${c}Latest Ch. : ${h}$latch ${df}";
		echo " ";
	fi
}

function getlink(){
	getData=$(curl -s -A "$ua" "https://www.pecintakomik.com/${judul}-chapter-${chapter}/");
	if [[ $getData =~ "docs.google.com" ]]; then
			echo $getData | grep -Po '(?<=class="aligncenter" src=")[^"]*' > links.txt
		else
			echo $getData | grep -Po '(?<=src=")[^"]*.jpg(?=")' > links.txt
	fi
}


function download(){
	url=$1;
	if [[ $(cat links.txt) =~ ".google.com" ]]; then
		echo -e "${m}Images uploaded on Google Drive cannot be downloaded${df}"
	elif [[ ! -z links.txt ]]; then
		wget -q --user-agent="$ua" "$url" -P "$title/$chapter";
	else
		echo -e "${m}URL not found!${df}";
		exit 0
	fi
}

clear
printf "${hh}"
cat << "wibunisme"

  db   d8b   db    .d8888.       d88b 
  88   I8I   88    88'  YP       `8P' 
  88   I8I   88    `8bo.          88  
  Y8   I8I   88      `Y8b.        88  
  `8b d8'8b d8' db db   8D db db. 88  
   `8b8' `8d8'  VP `8888Y' VP Y8888P
  +=================================+
  +===.    Manga Grabber v3     .===+
  +======.  Coded by Arief   .======+
  +=================================+

wibunisme
printf "${ch}";
echo -n "Masukkan Judul : "; read title;
echo -e "${df}"; getinfo;
echo -ne "${ch}Masukkan Chapter : "; read chapter; getlink;
echo ' ';
if [[ $(cat links.txt | wc -l) =~ 0 ]]; then
	echo -e "${m}Image not found!"
	exit 0
else
	echo -e "${ch}[INFO] Total images: $(cat links.txt | wc -l) ";
	echo -n "[INFO] Downloading on Progress...";
fi

for target in $(cat links.txt)
do
	echo -n ''; download $target;
done

echo -e "[INFO] Total downloaded: ${h}"$(ls "$title/$chapter" | wc -l)"${df}";
printf "${df}";
rm -f wget-log
rm -f info.tmp
rm -f links.txt

# EOF
