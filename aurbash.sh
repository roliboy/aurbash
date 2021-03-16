#!/bin/bash

package="$1"
scrape="$(curl -s https://aur.archlinux.org/packages/?K=$package | tr --delete '\n' | tr --delete '\t' | grep -shoP '<td.*?</td>' | sed 's/<\/td>//g' | sed 's/<td[^>]*>//g' | sed 's/<\/a>//g' | sed 's/<a[^>]*>//g' | sed "s/&#039;/'/g")"

SAVEIFS=$IFS
IFS=$'\n'
data=($scrape)
IFS=$SAVEIFS

for i in $(seq 0 $(expr ${#data[@]} / 6 - 1)); do
    index=$(expr $i \* 6)
    name="${data[$index]}"
    version="${data[$index+1]}"
    description="${data[$index+4]}"
    maintainer="${data[$index+5]}"

    printf "\033[0;35m%-3s\033[0m \033[0;34m%s\033[0m/%s \033[0;32m%s\033[0m\n" "$i" "$maintainer" "$name" "$version"
    printf "\t%s\n" "$description"
done

printf "\033[0;32m==> Package to install\033[0m\n"
printf "\033[0;32m==> \033[0m"
read index

package="${data[$(expr $index \* 6)]}"

cd /tmp
curl -sO "https://aur.archlinux.org/cgit/aur.git/snapshot/$package.tar.gz"
tar xfvz "$package.tar.gz" >/dev/null 2>&1
cd "$package"
makepkg -risc --noconfirm
cd ..
rm "$package.tar.gz"
rm -rf "$package"
