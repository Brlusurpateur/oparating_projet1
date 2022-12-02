#!/bin/bash
#num bot: 5984608472:AAFyjAeWv9aADfs7qUaMI1bFVMpeGp4m56k
OnOff=$(date +"%H")
OnOff=$(($OnOff+$un))
moyenne=0
douze=12
un=1
nbmin=$(date +"%M")
HDebut=9
HFin=21
min=16400
max=17000
deja=1  #cette variable permet de matriser s'il faut envoyer un message de compte rendu à 9h et 21h.Il se réintialise à chaque changement d'heure.
rm code.txt;
curl https://www.netdania.com/indices/bitcoin > code.txt;
prix=$(cat code.txt | sed -n '/nd-fq-last-container nd-fq-last/{n;p;}' | grep -oP "(?<=>)\w+");
Hprix=$prix
Bprix=$prix
prixdebut=$prix
prixfin=$prix
compt=0
declare -a tab

while true;
do

        rm code.txt;
        curl https://www.netdania.com/indices/bitcoin > code.txt;
        prix=$(cat code.txt | sed -n '/nd-fq-last-container nd-fq-last/{n;p;}' | grep -oP "(?<=>)\w+");

        #Somme des prix chaque heure
        if [ "$nbmin" == "60" ];
        then
                moyenne=$(($moyenne+$prix));
                Heure=$(date +"%H");
                Heure=$(($Heure+ 2))
                curl --data chat_id="-1001866478445" --data-urlencode "text=Il est $Heure H et le prix du BTC est actuellement à $prix" "https://api.telegram.org/bot5984608472:AAFyjAeWv9aADfs7qUaMI1bFVMpeGp4m56k/sendMessage?parse_node=HTML";
                OnOff=$(($OnOff+$un));
                deja=1;
                nbmin=0;
                #prend le prix dans un tableau toutes les heures
                tab[$compt]=$prix;
                compt=$(($compt+$un));
        fi
        nbmin=$(($nbmin+$un))
        
        #Message de debut de journée
        if [ "$deja" == "1" ];
        then
                if [ "$OnOff" == "9" ];
                then
                        moyenne=$(($moyenne/$compt));
                        for i in {0..11}
                        do
                                som=$(($som+(${tab[$i]}-$moyenne) ** 2));
                        done
                        Vol=$(($sqrt($som/$moyenne)));
                        compt=0

                        curl --data chat_id="-1001866478445" --data-urlencode "text=Bonjour, hier soir le prix du BTC était à $prixfin. Le prix moyen sur les 12 dernières heures était de $moyenne avec une volatilite de $Vol actuellement il est à $prix" "https://api.telegram.org/bot5984608472:AAFyjAeWv9aADfs7qUaMI1bFVMpeGp4m56k/sendMessage?parse_node=HTML";
                        prixdebut=$prix;
                        moyenne=0;
                        deja=0;
                fi
        fi

        #Message de fin de journee
        if [ "$deja" == "1" ];
        then
                if [ "$OnOff" == "21" ];
                then
                        moyenne=$(($moyenne/$douze));
                        curl --data chat_id="-1001866478445" --data-urlencode "text=Bonsoir, ce matin le prix du BTC était à $prixdebut. Le prix moyen sur les 12 dernières heures était de $moyenne, actuellement il est à $prix" "https://api.telegram.org/bot5984608472:AAFyjAeWv9aADfs7qUaMI1bFVMpeGp4m56k/sendMessage?parse_node=HTML";
                        prixfin=$prix;
                then
                        moyenne=$(($moyenne/$douze));
                        curl --data chat_id="-1001866478445" --data-urlencode "text=Bonsoir, ce matin le prix du BTC était à $prixdebut. Le prix moyen sur les 12 dernières heures était de $moyenne, actuellement il est à $prix" "https://api.telegram.org/bot5984608472:AAFyjAeWv9aADfs7qUaMI1bFVMpeGp4m56k/sendMessage?parse_node=HTML";
                        prixfin=$prix;
                        moyenne=0;
                        deja=0;
                fi
        fi

        #Alerte si le prix sort de la fourchette de prix
        if [ "$prix" \< "$min" ];
        then
                curl --data chat_id="-1001866478445" --data-urlencode "text=Alerte !!!! Le prix est sorti de sa fourchette, il est à $prix." "https://api.telegram.org/bot5984608472:AAFyjAeWv9aADfs7qUaMI1bFVMpeGp4m56k/sendMessage?parse_node=HTML";
        fi
        if [ "$prix" \> "$max" ];
        then
                curl --data chat_id="-1001866478445" --data-urlencode "text=Alerte !!!! Le prix est sorti de sa fourchette, il est à $prix." "https://api.telegram.org/bot5984608472:AAFyjAeWv9aADfs7qUaMI1bFVMpeGp4m56k/sendMessage?parse_node=HTML";
        fi

        if [ "$OnOff" == "24" ];
        then
                OnOff=0;
        fi

        sleep 60
done
