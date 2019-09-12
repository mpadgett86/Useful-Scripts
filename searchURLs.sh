#!/bin/bash

# Output Colors
RED='\033[0;31m'                # Set color to red
GRN='\033[0;32m'                # Set color to green
NOC='\033[0m'                   # Set color to none

## Array of search terms
## Will search all terms against all URLs
## *** Syntax : "term1" "term2" etc.
#########################################
wordlist=("Symmachus" "Antony" "Gregory of Tours" "Hypatius" "Theodosius I" "Constantine" "History of the Franks" "Belisarius" "Eternal City"
"Martin of Tours" "Clovis" "Priscus" "Prefect" "Julian" "Clothilde" "Atilla" "Ammianus Marcellinus" "Maximus" "Nicetius of Trier"
"Kreka" "Constantius" "Heretic" "Bede" "Corippus" "Theodosius II" "Orthodox" "Augustine" "Canterbury" "Avars" "Decurion" "Arianism"
"Bertha" "Justin II" "Constantinople" "Council of Chalcedon" "Ethelbert" "Severus ibn al-Mukaffa" "Gregory of Nazianzus" "Hellenic"
"Synod" "Whitby" "'Amr ibn al-Asi" "Basila" "Pagan" "Colman" "Benjamin" "Athens" "Augustine" "Hippo" "Wilfred" "Umar" "City of God"
"Procopius" "Einhard" "Altar of Victory" "Sidonius" "The Secret History" "Charlemagne" "Valentinian II" "Euric" "Justin I" "Saxons"
"Ambrose" "Cassiodorus" "Justinian" "Pope Leo III" "Athanasius" "Athalaric" "Theodora")

## Array of URLs
## will search all array elements
## *** Syntax : "URL1" "URL2" etc.
##########################################
websites=("https://sites.google.com/site/gmuhistory300/symmachus" "https://sites.google.com/site/gmuhistory300/ammianus"
"https://sites.google.com/site/gmuhistory300/cities" "https://sites.google.com/site/gmuhistory300/basil"
"https://sites.google.com/site/gmuhistory300/martin" "https://sites.google.com/site/gmuhistory300/symmachus-1"
"https://sites.google.com/site/gmuhistory300/ambrose" "https://sites.google.com/site/gmuhistory300/ambrose-1"
"https://sites.google.com/site/gmuhistory300/anthony" "https://sites.google.com/site/gmuhistory300/athanasius"
"https://sites.google.com/site/gmuhistory300/theodosian-code" "https://sites.google.com/site/gmuhistory300/chalcedon"
"https://sites.google.com/site/gmuhistory300/julian" "https://sites.google.com/site/gmuhistory300/basil-1"
"https://sites.google.com/site/gmuhistory300/augustine" "https://sites.google.com/site/gmuhistory300/sidonius"
"https://sites.google.com/site/gmuhistory300/cassiodorus" "https://sites.google.com/site/gmuhistory300/clovis"
"https://sites.google.com/site/gmuhistory300/nicetius" "https://sites.google.com/site/gmuhistory300/bede"
"https://sites.google.com/site/gmuhistory300/justinian" "https://sites.google.com/site/gmuhistory300/priscus"
"https://sites.google.com/site/gmuhistory300/corripus" "https://sites.google.com/site/gmuhistory300/mukaffa"
"https://sites.google.com/site/gmuhistory300/umar" "https://sites.google.com/site/gmuhistory300/charlemagne")
#################################################################################################################################################

keyword=""                                  # void
webserv=""                                  # void
cfinds=0                                    # number of found instances in URL
msg=""                                      # void

## if keyword exists in more than 1 occurrence in a website, mark as found,
## otherwise report as not found.
for keyword in "${wordlist[@]}"
do

    echo "Searching for $keyword ..."
    for webserv in "${websites[@]}"
    do

        cfinds=$(wget -q -O- "$webserv" | grep -i -c -oF "$keyword")

        if (($cfinds > 0))
        then
            msg="${NOC}........................ ${GRN}Found $cfinds in <$webserv>\n${NOC}"
        else
            msg="${NOC}........................ ${RED}** Not found in <$webserv>\n${NOC}"
        fi

        printf "$msg"
    done
done