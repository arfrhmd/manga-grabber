#!/bin/bash
# Manga Images Grabber v2
# Coded by Arif Rahmadi W

h='\e[38;5;85m' # HIJAU
m='\e[38;5;196m' # MERAH
ch='\e[38;5;195m' # CYAN HIJAU
c='\e[38;5;87m' # CYAN
df='\033[0m' # DEFAULT
hh='\e[38;5;117m'
a='\e[38;5;201m'
b='\e[38;5;207m'
c='\e[38;5;213m'
d='\e[38;5;219m'
e='\e[38;5;225m'
f='\e[38;5;231m'

ua="Mozilla/5.0 (X11; Linux x86_64; rv:56.0) Gecko/20100101 Firefox/56.0"

function getinfo(){
	judul=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's: :-:g');
	getin=$(curl -s -A "$ua" "https://www.pecintakomik.com/manga/$judul/" | sed -e 's:<[^>]*>::g' > info.tmp);
	genres=$(cat info.tmp | grep -Po 'Genres:[^:]*' | sed 's:Published::g; s:Genres\:::g'); # menampilkan genre
	status=$(cat info.tmp | grep -Po 'Status: (Ongoing|Completed)' | sed 's/Status: //g'); # cek status manga (ongoing/completed)
	latch=$(cat info.tmp | grep -Po 'Latest Chapter: Chapter [0-9]*' | sed 's/Latest Chapter: //g'); # cek chapter terbaru
	if [[ $(curl -s -A "$ua" -w "%{http_code}\\n" "https://www.pecintakomik.com/manga/$judul/") =~ "301" ]]; then
		echo -e "${m}MANGA NOT FOUND / TIDAK DITEMUKAN${df}";
		exit 0
	else
		echo -e "${c}Title  : ${h}$title";
		echo -e "${c}Genres : ${h}$genres";
		echo -e "${c}Status : ${h}$status";
		echo -e "${c}Latest Chapter : ${h}$latch ${df}";
		echo " ";
	fi
}

function getlink(){
	getData=$(curl -s -A "$ua" "https://www.pecintakomik.com/${judul}-chapter-${chapter}/" | grep -Po '(?<=src=")[^"]*.jpg(?=")' > links.txt);
}


function download(){
	url=$1;
	if [[ -z links.txt ]]; then
		echo "URL not found!";
		exit 0
	else
		wget -q --user-agent="$ua" "$url" -P "$title/$chapter";
	fi
}

clear
echo -e "${a}++===============================++"
echo -e "${b}||                               ||"
echo -e "${b}||      Manga Images Grabber     ||"
echo -e "${c}||   based on pecintakomik.com   ||"
echo -e "${d}||                               ||"
echo -e "${e}||         Coded by Arif         ||"
echo -e "${e}||                               ||"
echo -e "${f}++===============================++"
echo " ";
printf "${ch}";
echo -n "Masukkan Judul : "; read title;
echo -e "${df}"; getinfo;
echo -n "Masukkan Chapter : "; read chapter; getlink;
echo ' ';
echo -e "${hh}[INFO] Total images: $(cat links.txt | wc -l) ";
echo "==> Downloading on Progress...";

for target in $(cat links.txt)
do
	echo -n ''; download $target;
done

if [[ $(ls "$title/$chapter/*.jpg" &> /dev/null) =~ " " ]];then
	echo "[ERROR] File not downloaded!";
else
	echo -e "[INFO] Total downloaded: ${h}"$(ls "$title/$chapter" | wc -l)"${df}";
fi
printf "${df}";
rm -f wget-log
rm -f info.tmp
rm -f links.txt

# EOF