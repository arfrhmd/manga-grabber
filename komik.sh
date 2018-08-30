#!/bin/bash
# Pecintakomik.com Images Grabber
# Coded by Arif

hijau='\e[38;5;82m'
merah='\e[38;5;196m'
end='\033[0m'

useragent="Mozilla/5.0 (X11; Linux x86_64; rv:56.0) Gecko/20100101 Firefox/56.0";

# ambil link gambar
function getlink(){
	judul=$(echo "$title" | sed 's: :%20:g');
	curl -s http://www.pecintakomik.com/manga/$judul/$chapter/full | grep -Po '(?<=src=")[^"]*.jpg(?=")' > links.txt
	sed -i 's: :%20:g' links.txt
}

# download gambar
function download(){
	victim=$1;
	wkwk=$(echo "$victim" | sed 's: :%20:g');
	down=$(wget "http://www.pecintakomik.com/manga/$wkwk" -q --show-progress -P "$title/$chapter");
		echo "$down";
}
clear
cat << "EOF"
._______________________________.
[                               ]
[        Pecintakomik.com       ]
[         Images Grabber        ]
[                               ]
[  arief@smkbinateknika.sch.id  ]
[_______________________________]

EOF

echo -n "Manga title : "; read title;
echo -n "Chapter : "; read chapter;
echo ' ';
getlink
echo 'Total images: ['$(cat links.txt | wc -l)']';

for target in $(cat links.txt); do
	echo '[+] Downloading: '$target;
	download $target
	echo ' ';
done
echo 'Total downloaded: '$(ls "$title/$chapter" | wc -l)'';
rm -f links.txt
rm -f wget-log
