#!/bin/bash
 
# smazal jsem sort2


# TODO vypisy obrazovek: nohup jkmorseovka.sh -h | tee vystup.out
# TODO dat vystup do prikazu column
# TODO pismena neopakuji do omrzeni spatne pismeno
# TODO 

zvukovy_soubor="jkmorseovka.ogg" # toto uklada do aktualniho adresare, ale je to pomalejsi
zvukovy_soubor="/dev/shm/jkmorseovka.ogg" # uklada do shared memory virtualniho disku v RAM pameti pocitace - je to velmi rychle, ale po vypnuti pocitace se to maze.
Gpocet_pismen_cviceni=5 # nahodile cviceni jede po 5 pismenech
Gpocet_pismen_opisovani=5 # pouze u cviceni, jinak opisuje cely zadany text
Gpocet_pismen_cviceni=2 # nahodile cviceni jede po 5 pismenech

debug=":" #nebo " "
Grychlost=100 # 120 strední
Grychlost=50 # 120 strední
Grychlost=150 # 120 strední
Grychlost=120 # 120 strední - vychozi
Gmezi_znaky=100 # 100 strední

# globalni promenne krome logickych promennych
# 	Gtext - zadani z prikazove radky, napr cviceni123
# 	Gvyber - z jakych pismen se vybira, "bflmpsvz"
# 	Gcviceni_text - nahodile preskupene Gvyber
# 	Gpocet_pismen_cviceni
# 	ostatni promenne obvykle povazuji za lokalni

#defaultni nastaveni
if [ "$(whereis sox | cut -d: -f2)" == "" ]||[ "$(whereis feh | cut -d: -f2)" == "" ]||[ "$(whereis bc | cut -d: -f2)" == "" ]; then
	# [ "$(whereis feh | cut -d: -f2)" == "" ] && sudo apt install feh # mozno pouzit jiny zobrazovac obrazku
	echo Musime nainstalovat sox, feh a bc
	sudo apt install sox feh bc # pro prikaz play, obrazek a vypocty
	fi
	
abeceda=( a b c d e f g h ch i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 " " ä ë ö ü "," "." ":" ";" "?" "!" "-" "/" "=" "_" "“" "<->" "@" ")" "("  )	# ch se samozrejme nevyhodnocuje
abecedamorseova=( ".-" "-..." "-.-." "-.." "." "..-." "--." "...." "----" ".." ".---" "-.-" ".-.." "--" "-." "---" ".--." "--.-" ".-." "..." "-" "..-" "...-" ".--" "-..-"  "-.--" "--.." "-----" ".----" "..---" "...--" "...-" "....." "-...." "--..." "---.." "----." " " ".-.-" "..-.." "---." "..--" "--..--" ".-.-.-" "---..." "-.-.-." "..--.." "--...-" "-....-" "-..-." "-...-" "..--.-" ".-..-." ".----." ".--.-." "-.--.-" "-.--." )	
abecedaslovem=( "akát" "blýskavice" "cílovníci" "dálava" "erb" "Filipíny" "Grónská zem" "hrachovina" "chvátá k nám sám" "ibis" "jasmín bílý" "krákorá" "lupíneček" "mává" "národ" "ó náš pán" "papírníci" "qílí orkán" "rarášek" "sekera" "trám" "uličník" "vyučený" "wagón klád" "xénokratés" "ýgar mává" "známá žena" 0 1 2 3 4 5 6 7 8 9 "mezera" "a umlaut"  "e umlaut" "o umlaut" "u umlaut" "Čárka" "Tečka" "Dvojtečka" "Středník" "Otazník" "Vykřičník" "Pomlčka" "Lomítko" "Rovnítko" "Podtržítko" "Uvozovka" "Tabulátor" "Zavináč" "Kulatá závorka zavírací" "Kulatá závorka otevírací" )
# intestines=$(printf "%s\n" ${names[@]} | awk '{ print "["$1"]="FNR  }' | tr "\n" " ")
# echo "declare -A abeceda_asociativni=( $(printf "%s\n" ${abeceda[@]} | awk '{ print "["$1"]="FNR  }' | tr "\n" " ") )"; exit # toto je radka, ktera vytvori nasledujici retezec 
declare -A abeceda_asociativni=( [a]=1 [b]=2 [c]=3 [d]=4 [e]=5 [f]=6 [g]=7 [h]=8 [ch]=9 [i]=10 [j]=11 [k]=12 [l]=13 [m]=14 [n]=15 [o]=16 [p]=17 [q]=18 [r]=19 [s]=20 [t]=21 [u]=22 [v]=23 [w]=24 [x]=25 [y]=26 [z]=27 [0]=28 [1]=29 [2]=30 [3]=31 [4]=32 [5]=33 [6]=34 [7]=35 [8]=36 [9]=37 [ä]=38 [ë]=39 [ö]=40 [ü]=41 [,]=42 [.]=43 [:]=44 [;]=45 [?]=46 [!]=47 [-]=48 [/]=49 [=]=50 [_]=51 [“]=52 [<->]=53 ["@"]=54 [)]=55 [(]=56  )
# echo ${abeceda_asociativni[-]} # OK funguje
abeceda_statistika_chyby=( $(printf  '0 %.0s' $(seq 1 ${#abeceda[@]}))) # vytvori n-nul
abeceda_statistika_pokusy=( $(printf  '0 %.0s' $(seq 1 ${#abeceda[@]}))) # vytvori n-nul
abeceda_statistika_sekundy=( $(printf  '0 %.0s' $(seq 1 ${#abeceda[@]}))) # vytvori n-nul
nazev_programu="$(basename $0)"
nazev_obrazku="$(basename -s sh $0 )png"
adresar_programu=$(dirname $(whereis "$nazev_programu" | cut -f2 -d' ' ))
pracovni_adresar=$(pwd)
cesta_obrazek=$adresar_programu/$nazev_obrazku

# echo $nazev_programu $nazev_obrazku $adresar_programu $pracovni_adresar $cesta_obrazek
# exit

function Fvypis_znaku {

# column -t -s$'\t' <<mezirici
column -t -s$'\t' <<mezirici
PÍSMENO 	KÓD 	POMOCNÉ SLOVO
A	/.-/	Akát
B	/-.../	Blýskavice
C	/-.-./	Cílovníci
D	/-../	Dálava
E	/./	Erb
F	/..-./	Filipíny
G	/--./	Grónská zem
H	/..../	Hrachovina
CH	/----/	Chvátá k nám sám
I	/../	Ibis
J	/.---/	Jasmín bílý
K	/-.-/	Krákora
L	/.-../	Lupíneček
M	/--/	Mává
N	/-./	Nástup; Národ
O	/---/	Ó náš pán
P	/.--./	Papírníci
Q	/--.-/	Qílí orkán
R	/.-./	Rarášek
S	/.../	Sekera
T	/-/	Trám
U	/..-/	Uličník
V	/...-/	Vyvolený
W	/.--/	Vagón klád
X	/-..-/	Xénokratés
Y	/-.--/	Ý se krátí; Ýgar mává 
Z	/--../	Známá žena
mezirici
read

column -t -s$'	' <<mezirici
ČÍSLICE 	KÓD 	ZKRÁCENÝ KÓD
0	/-----/	/-/
1	/.----/	/.-/
2	/..---/	/..-/
3	/...--/	/...-/
4	/....-/	Není
5	/...../	/./
6	/-..../	Není
7	/--.../	/-.../
8	/---../	/-../
9	/----./	/-./
mezirici
echo

column -t -s$'	' <<mezirici
PÍSMENO 	KÓD
Ä	/.-.-/
Ë	/..-../
Ö	/---./
Ü	/..--/
mezirici
read

column -t -s$'	' <<mezirici
SPECIÁLNÍ ZNAK 	NÁZEV 	KÓD
,	Čárka	/--..--/
.	Tečka	/.-.-.-/
:	Dvojtečka	/---.../
;	Středník	/-.-.-./
?	Otazník	/..--../
!	Vykřičník	/--...-/
-	Pomlčka	/-....-/
/	Lomítko	/-..-./
=	Rovnítko	/-...-/
_	Podtržítko	/..--.-/
„“	Uvozovka	/.-..-./
(	Kulatá závorka otevírací	/-.--./
)	Kulatá závorka zavírací	/-.--.-/
<->	Tabulátor	/.----./
@	Zavináč	/.--.-./
mezirici
read 

column -t -s$'	' <<mezirici
ZVLÁŠTNÍ SIGNÁL	KÓD
Začátek vysílání	/-.-.-.-./
Konec vysílání	/...-.-/
Rozumím	/----.-/
Nerozumím	/......./
Pomaleji	/-.-.-../
Čekejte	/.-.../
Omyl	/././././././
Opakuji	/../../../../../../
SOS, Pomoc	/.../---/.../
mezirici
echo; echo Prevzato z http://morseovaabeceda.cz/
	}	
function Fnastaveni_rychlosti { #$1 Grychlost 50 - 150
# 	Grychlost=$1
	tecka_trvani=$(bc -l <<<"scale=3;10/$Grychlost") # je-li Grychlost 100, pak tecka trva 100ms
	carka_trvani=$(bc -l <<<"scale=3;3*$tecka_trvani")
	pauza_tecka_carka=$(bc -l <<<"scale=3;$tecka_trvani / 2") # dobre, ale pomerne rychle
 	pauza_tecka_carka=$tecka_trvani 
	pauza_pismeno=$(bc -l <<<"scale=3;$carka_trvani*$Gmezi_znaky/100") #$carka_trvani
	pauza_slovo=$(bc -l <<<"scale=3;7*$tecka_trvani*$Gmezi_znaky/100")
	nota=E4
	nota=E6
	# Každé písmeno by mělo být odděleno pauzami stejné délky jako pomlčka (tj. Třikrát delší než zvuk tečky). Každé slovo by mělo být obklopeno pauzami, délka pauz by měla být přibližně 7krát delší než bod. Čím lépe si procvičíte pauzu, tím snazší bude porozumět vašemu kódu.
	# tento navod neupravuje pauzu mezi teckami carkami, pouzivam trvani tecky ci jeho polovinu. 
	}
function Fvypis_konstant {
column -t -s$'	' <<mezirici
Trvani tecky [s]: $tecka_trvani
Trvani carky [s]: $carka_trvani
Pauza mezi teckou a carkou [s]: $pauza_tecka_carka
Pauza mezi pismeny [s]: $pauza_pismeno
Pauza mezi slovy [s]: $pauza_slovo
Hraná nota: $nota
mezirici
	echo -e	"\tParametry jsou nastaveny podle tohoto návodu: \n\"Každé písmeno by mělo být odděleno pauzami stejné délky jako pomlčka, tj. třikrát delší než zvuk tečky. \nKaždé slovo by mělo být obklopeno pauzami. Délka pauz by měla být přibližně sedmkrát delší než bod. \nČím lépe si procvičíte pauzu, tím snazší bude porozumět vašemu kódu.\" \nPauza mezi teckami a carkami je nastavena na trvani tecky ci jeho polovinu."
	}
function Fusage_old {
		echo
		echo Program na uceni Morseovy abecedy
		echo
		echo "Pouziti:" 
		echo -e "\tNejaky parametr z techto zavorek je povinny {}."
		echo -e "\tParametry v [] jsou volitelne." 
		echo -e "\tKratke parametry s jednou pomlckou (napr. -p) jsou ekvivalentni dlouhym parametrum s dvema pomlckami (--pismena)"
		echo
		echo "$nazev_programu {-v|--vypis-znaku|-p|--pismena|-P|--pismena-vizualne|-c|--cviceni|-d|--diktat|-o|--opis|-m|--morse|-l|--latinka|-h|--help} [-r|--rychlost číslo 50 - 150] [-R|--mezi-pismeny číslo 10 - 1000] [-x|--pocet-pismen číslo 2-20 ]  {VasText|cviceni1, podobně cviceni2,12,3,3a,3b,13,23,123,4,4a,4b,4c,4ab,4ac,4bc,14,24,34,1234,5,12345} "
		echo
		echo Postup uceni a vysvetleni jednotlivych znaku
		echo
		echo Povinne parametry
		echo "--vypis-znaku - tabulky vsech pismen, znaku a signalu"
		echo "$nazev_programu --vypis_znaku # Nekolikrat si prectete prehled znaku a pismen"
		echo
		echo "--pismena-vizualne - je nejlepsi pro uplne zacatecniky - uci jednotliva pismena a vypisuje je i na obrazovku"
		echo "$nazev_programu --pismena-vizualne cviceni1 # testuje jednoznakova pismena, tzn. e, t, a zobrazuje je"
		echo "$nazev_programu -P cviceni12 # testuje jedno- a dvouznakova pismena, tzn. etimna, a zobrazuje je"
		echo
		echo "--pismena - procvicuje jednotliva pismena, ale bez zrakove opory. Zaciname po zvladnuti predchozich"
		echo "$nazev_programu --pismena cviceni23 # testuje dvou- a triznakova pismena bez zobrazeni"
		echo "$nazev_programu -p cviceni3a # testuje po pismenu z prvni polovinu triznakových pismen"
		echo
		echo "--opis - opisovani zadaneho textu do morse pomoci klaves .- a enter (mezera)"
		echo "$nazev_programu --opis "Pepa Smolik" # vyzaduje presny opis tohoto textu"
		echo "$nazev_programu -o cviceni1234 # vytvori nahodnou kombinaci beznych pismen"
		echo
		echo "--cviceni - prijem skupin nahodile vybranych pismen z daneho cviceni"
		echo "$nazev_programu --cviceni bflmpsvz # procvicuje obojetne souhlasky"
		echo "$nazev_programu -c cviceni4 --mezi-pismeny 1000 --pocet-pismen 3 # procvicuje po trech ctyrznakova pismena, ale dela mezi nimi velke pauzy"
		echo
		echo "$nazev_programu --diktat # nadiktujte si vlastni text morseovkou"
		echo "--diktat - vysilani vlastniho textu"
		echo
		echo "--morse - prevede zadany text do morseovy abecedy"
		echo "$nazev_programu --rychlost 200 --morse \"salamista\" # prevede latinsky text do morse a zahraje jej velmi rychle. Vystupni soubor bude $zvukovy_soubor"
		echo
		echo "--latinka - prevede zadane morse znaky do latinky"
		echo "$nazev_programu --latinka \"/.../.-/--/.-/\" nebo \"|...-|---|-..|.-|\""
		echo
		echo Volitelne parametry
		echo "--rychlost - pocet pismen na cviceni (výchozí: 120)"
		echo "--mezi-pismeny - navyšení pauzy mezi znaky a slovy (v: 100)"
		echo "--pocet-pismen - pocet znaku ve cviceni (v: 2)"
		echo "Dalsi parametry, napr. hrana nota, se nastavuji uvnitr skriptu."
		echo
		echo "Zvukový soubor prave hraneho zvuku: $zvukovy_soubor"
		echo
		echo "Zname chyby: Nedela pismeno CH a nektere divne znaky, pouze anglickou abecedu"
		echo ""
		read -p "Enter - další stránka"
# 		echo "Postup učení Morseovy abecedy"
		echo
		Fvypis_konstant
		echo
		echo Autor a licence:
		echo -e "\tPhDr. Mgr. Jeroným Klimeš, Ph.D."
		echo -e "\twww.klimes.us"
		echo -e "\tLicences under GNU GPLv3 and WTFPL"
		
		feh  --zoom 200 --geometry $(feh  -l "$cesta_obrazek" | awk '(NR==2) {print(($3*2)"x"($4*2));}') "$cesta_obrazek"
		exit
	}
function Fusage {
less <<mezirici

Program na uceni Morseovy abecedy

Pouziti: 
	Nejaky parametr z techto zavorek je povinny {}.
	Parametry v [] jsou volitelne. 
	Kratke parametry s jednou pomlckou (napr. -p) jsou ekvivalentni dlouhym parametrum s dvema pomlckami (--pismena)

$nazev_programu {-v|--vypis-znaku|-p|--pismena|-P|--pismena-vizualne|-c|--cviceni|-d|--diktat|-o|--opis|-m|--morse|-l|--latinka|-h|--help} [-r|--rychlost číslo 50 - 150] [-R|--mezi-pismeny číslo 10 - 1000] [-x|--pocet-pismen číslo 2-20 ]  {VasText|cviceni1, podobně cviceni2,12,3,3a,3b,13,23,123,4,4a,4b,4c,4ab,4ac,4bc,14,24,34,1234,5,12345} 

Postup uceni a vysvetleni jednotlivych znaku

Povinne parametry
--vypis-znaku - tabulky vsech pismen, znaku a signalu
$nazev_programu --vypis_znaku # Seznamte se s mnemotechnickymi akrostichy znaku a pismen, nemusite se je ucit zpameti.

--pismena-vizualne - je nejlepsi pro uplne zacatecniky - uci jednotliva pismena a vypisuje je i na obrazovku
$nazev_programu --pismena-vizualne cviceni1 # testuje jednoznakova pismena, tzn. e, t, a zobrazuje je
$nazev_programu -P cviceni12 # testuje jedno- a dvouznakova pismena, tzn. etimna, a zobrazuje je
	Po trech chybach se objevi spravna odpoved. 
	Velke volni usili nema smysl, protoze drilujeme plazi mozek ne racionalni savci.

--pismena - procvicuje jednotliva pismena, ale bez zrakove opory. Zaciname po zvladnuti predchozich
$nazev_programu --pismena cviceni23 # testuje dvou- a triznakova pismena bez zobrazeni
$nazev_programu -p cviceni3a # testuje po pismenu z prvni polovinu triznakových pismen

--opis - opisovani zadaneho textu do morse pomoci klaves .- a enter (mezera)
$nazev_programu --opis "Pepa Smolik" # vyzaduje presny opis tohoto textu
$nazev_programu -o cviceni1234 # vytvori nahodnou kominaci beznych pismen

--cviceni - prijem skupin nahodile vybranych pismen z daneho cviceni
$nazev_programu --cviceni bflmpsvz # procvicuje obojetne souhlasky
$nazev_programu --c cviceni4 --mezi-pismeny 1000 --pocet-pismen 3 # procvicuje po trech ctyrznakova pismena, ale dela mezi nimi velke pauzy

--diktat - vysilani vlastniho textu
$nazev_programu --diktat # nadiktujte si vlastni text morseovkou

--morse - prevede zadany text do morseovy abecedy
$nazev_programu --rychlost 200 --morse "salamista" # prevede latinsky text do morse a zahraje jej velmi rychle. Vystupni soubor bude $zvukovy_soubor"

--latinka - prevede zadane morse znaky do latinky
$nazev_programu --latinka "/.../.-/--/.-// nebo |...-|---|-..|.-|"

Volitelne parametry
--rychlost <cislo mezi 50 a 300> - pocet pismen na cviceni (výchozí: 120)
--mezi-pismeny <cislo mezi 100 az 1000> - navyšení pauzy mezi znaky a slovy (v: 100)
--znaku-cviceni <cislo mezi 2 az 20>- pocet znaku ve cviceni (v: 2)
Dalsi parametry, napr. hrana nota, se nastavuji uvnitr skriptu.

Zvukový soubor prave hraneho zvuku: $zvukovy_soubor

Zname chyby: Nedela pismeno CH a nektere divne znaky, pouze anglickou abecedu.

$(Fvypis_konstant)

Autor a licence:
	PhDr. Mgr. Jeroným Klimeš, Ph.D.
	www.klimes.us
	Licences under GNU GPLv3 and WTFPL
	
Konec napovedy: Zmacknete klavesu q a zobrazi se obrazek 

mezirici
	feh  --zoom 200 --geometry $(feh  -l "$cesta_obrazek" | awk '(NR==2) {print(($3*2)"x"($4*2));}') "$cesta_obrazek" &
	exit
	}
function Fcviceni { #nacita Gtext modifikuje Gvyber Gcviceni_text
	Gcviceni_text=""
	nasel=true
	if   [ "$Gtext" == "cviceni1"  ]; 	then Gvyber="te"
	elif [ "$Gtext" == "cviceni2"  ]; 	then Gvyber="mnai"
	elif [ "$Gtext" == "cviceni12" ]; 	then Gvyber="temnai"
	elif [ "$Gtext" == "cviceni3"  ]; 	then Gvyber="ogkdwrus"
	elif [ "$Gtext" == "cviceni3a" ]; 	then Gvyber="ogkd"
	elif [ "$Gtext" == "cviceni3b" ]; 	then Gvyber="wrus"
	elif [ "$Gtext" == "cviceni13" ]; 	then Gvyber="teogkdwrus"
	elif [ "$Gtext" == "cviceni23" ]; 	then Gvyber="mnaiogkdwrus"
	elif [ "$Gtext" == "cviceni123" ]; 	then Gvyber="temnaiogkdwrus"
	elif [ "$Gtext" == "cviceni4"  ]; 	then Gvyber="qzycxbjplfvh"
	elif [ "$Gtext" == "cviceni14" ]; 	then Gvyber="teqzycxbjplfvh"
	elif [ "$Gtext" == "cviceni24" ]; 	then Gvyber="mnaiqzycxbjplfvh"
	elif [ "$Gtext" == "cviceni34" ]; 	then Gvyber="ogkdwrusqzycxbjplfvh"
	elif [ "$Gtext" == "cviceni4a" ]; 	then Gvyber="qzyc"
	elif [ "$Gtext" == "cviceni4b" ]; 	then Gvyber="xbjp"
	elif [ "$Gtext" == "cviceni4c" ]; 	then Gvyber="lfvh"
	elif [ "$Gtext" == "cviceni4ab"   ]; then Gvyber="qzycxbjp"
	elif [ "$Gtext" == "cviceni4ac"   ]; then Gvyber="qzyclfvh"
	elif [ "$Gtext" == "cviceni4bc"   ]; then Gvyber="xbjplfvh"
	elif [ "$Gtext" == "cviceni1234"  ]; then Gvyber="temnaiogkdwrusqzycxbjplfvh"
	elif [ "$Gtext" == "cviceni5"     ]; then Gvyber="0123456789"
	elif [ "$Gtext" == "cviceni12345" ]; then Gvyber="temnaiogkdwrusqzycxbjplfvh0123456789"
	elif [ "$Gtext" == "cvicenitecky" ]; then Gvyber="eish"
	elif [ "$Gtext" == "cvicenicarky" ]; then Gvyber="tmo"
	elif [ "$Gtext" == "cviceniteckycarka" ]; then Gvyber="auv"
	elif [ "$Gtext" == "cvicenicarkytecka" ]; then Gvyber="ng"
	else Gvyber=$Gtext
		nasel=false
	fi
	delka_vyber=${#Gvyber}
# 	echo "cviceni($cviceni) opisovani($opisovani) nasel($nasel)"
# 	if $cviceni || ( $opisovani && $nasel ) ; then 
	if $cFlag; then 
		for ((m=0; m<$Gpocet_pismen_cviceni; m++)); do
			nahodily=$(( $RANDOM % $delka_vyber ))			
# 				{ for ((i=0;i<40000;i++)); do echo $(($RANDOM % 4)); done; } | grep -c 3 # toto je test nahodilosti  
			Gcviceni_text=$Gcviceni_text${Gvyber:nahodily:1}
		done
	elif $oFlag && $nasel ; then 
		for ((m=0; m<$Gpocet_pismen_opisovani; m++)); do
			nahodily=$(( $RANDOM % $delka_vyber ))			
			Gcviceni_text=$Gcviceni_text${Gvyber:nahodily:1}
		done 
	elif $oFlag && ! $nasel; then 
		Gcviceni_text=$Gtext
	else 
		Gcviceni_text=$Gvyber
	fi
	}
function Ftecka { # kdyz je   $1 ":" pak to potlaci vystup
	$1 echo -n "."
# 	play -n synth $tecka_trvani sine $nota &> /dev/null
	play -n synth $tecka_trvani sine $nota &> /dev/null
	}
function Fcarka { # kdyz je   $1 ":" pak to potlaci vystup
	$1 echo -n "-"
	play -n synth $carka_trvani sine $nota &> /dev/null
	}
function Fpauza { # kdyz je   $1 ":" pak to potlaci vystup
	$1 echo -n " "
	sleep $pauza_slovo
	}
function Fpismeno_do_morse { # $1 jedno pismeno latinkou vraci morsekod
	for ((j=0; j<${#abeceda[@]}; ++j)); do
		preskoc=false
		if [ "${abeceda[$j]}" == "$1" ];then 
			cislo_pismena=$j;
			pismeno_morse="${abecedamorseova[$cislo_pismena]}"
			pismeno_slovem="${abecedaslovem[$cislo_pismena]}"
			break
		fi
	done
		if [ $j -eq ${#abeceda[@]} ]; then # pokud to dobeho az na konec array a stale nic, tak preklad pismene neexistuje
			preskoc=true # dačo čudného
			return 1
		fi 
	printf %s "$pismeno_morse"
	return 0
	#  	echo;echo "$i cislo_pismena($cislo_pismena); pismeno_morse($pismeno_morse); pismeno_slovem($pismeno_slovem)"
	}
function Fpismeno_do_slov { # $1 jedno pismeno latinkou vraci morsekod mnemotechnikou pomůckou
	pismeno_slovem=""
	for ((j=0; j<${#abeceda[@]}; ++j)); do
		preskoc=false
		if [ "${abeceda[$j]}" == "$1" ];then 
			cislo_pismena=$j;
# 			pismeno_morse=${abecedamorseova[$cislo_pismena]}
			pismeno_slovem=${abecedaslovem[$cislo_pismena]}
			break
		fi
	done
		if [ $j -eq ${#abeceda[@]} ]; then # pokud to dobeho az na konec array a stale nic, tak preklad pismene neexistuje
			preskoc=true # dačo čudného
			return 1
		fi 
	echo "$pismeno_slovem"
	return 0
	#  	echo;echo "$i cislo_pismena($cislo_pismena); pismeno_morse($pismeno_morse); pismeno_slovem($pismeno_slovem)"
	}
function Fmorse_do_latinky { # $1 morse znaky 
	latinka_z_morse=""
	pocet_kodu=$(sed  's/[^|]//g' <<<$1 | awk '{ print length +1 }')
	for ((n=1; n <= pocet_kodu; n++ )); do
		morse_kod=$(cut -f$n -d\| <<<$1)
		if [ "$morse_kod" == "" ]; then morse_kod=" "; fi # prevadi || na | |, ale takto by to slo take # $(sed  's/||/| |/g' <<<$1)
		for ((j=0; j<${#abecedamorseova[@]}; ++j)); do
			preskoc=false
			if [ "${abecedamorseova[$j]}" == "$morse_kod" ];then 
	# 			echo "${abecedamorseova[$j]}" --- "$1"
				cislo_pismena=$j;
				pismeno_latinkou=${abeceda[$cislo_pismena]}
				pismeno_morse=${abecedamorseova[$cislo_pismena]}
				pismeno_slovem=${abecedaslovem[$cislo_pismena]}
#  				if [ "$morse_kod" == " " ]; then echo naslo mezeru; fi
# 	  	echo;echo "$i cislo_pismena($cislo_pismena); pismeno_morse($pismeno_morse); pismeno_slovem($pismeno_slovem)"
				break # v techto promennych je posledni znak - 
			fi
		done
			if [ $j -eq ${#abeceda[@]} ]; then # pokud to dobehlo az na konec array a stale nic, tak preklad pismene neexistuje
				preskoc=true # dačo čudného
			else
				latinka_z_morse="$latinka_z_morse$pismeno_latinkou" #
			fi 
	done
	printf "$latinka_z_morse"
	}	
function Flatinka_do_morse { # $1 latinskytext, vystup morse string 
	latinka="$1"
	vystup_morse=""
	pocet_znaku=$(( ${#latinka} - 1 ))
	for i in $(seq 0 $pocet_znaku); do
		pismeno="${latinka:i:1}"
# 	 	echo "$i >>>$pismeno<<<"
		vystup_morse="$vystup_morse|$(Fpismeno_do_morse "$pismeno")"
	done
	echo -n "$vystup_morse|"
	}	
function Fmorseovka_hrani { #$1 - morse string  $2 ":" potlacuje vizualni vystup
	string=$1
	fade=" fade l .001 "
# 	$2 echo $string	toto by psat nemelo
# 	echo $string	
	string=$(sed "s/ /_/g" <<<$string)
#   	echo upraveny string: $string 
	sox_parametr=""
	vcera_mezera_byla=0
	while read -N1 znak; do
# 		echo -n $znak vypisuje to znaky, ktere bude hrat
		if [ "$znak" == "-" ]; then 
			if [ $(bc <<<"($vcera_mezera_byla > 0)") -eq 1  ]; then 
				sox_parametr=$sox_parametr" trim 0.0 $vcera_mezera_byla : " # toto je jedine misto, kde se vklada mezera
				fi # vlozi nejdelsi predchazejici mezeru
			sox_parametr=$sox_parametr" synth $carka_trvani sin $nota $fade  : " # vlozi ton
			vcera_mezera_byla=$pauza_tecka_carka # priste vlozit toto, nebude-li delsi pauza
		elif [ "$znak" == "." ]; then 
			if [ $(bc <<<"($vcera_mezera_byla > 0)") -eq 1  ]; then 
				sox_parametr=$sox_parametr" trim 0.0 $vcera_mezera_byla : " # toto je jedine misto, kde se vklada mezera
				fi # vlozi nejdelsi predchazejici mezeru
			sox_parametr=$sox_parametr" synth $tecka_trvani sin $nota $fade : " # vlozi ton tecka
			vcera_mezera_byla=$pauza_tecka_carka # priste vlozit toto, nebude-li delsi pauza
		elif [ "$znak" == "|" ]&&[ $(bc <<<"( $pauza_pismeno > $vcera_mezera_byla)") -eq 1  ]; then 
# 			echo znak $znak vcera $vcera_mezera_byla 
			vcera_mezera_byla=$pauza_pismeno # priste vlozit toto, nebude-li delsi pauza
		elif [ "$znak" == "_" ]&&[ $(bc <<<"( $pauza_slovo > $vcera_mezera_byla)") -eq 1  ]; then 
#  			echo jsem tu
			vcera_mezera_byla=$pauza_slovo # priste vlozit toto, nebude-li delsi pauza
		elif [ "$znak" == $'\n' ]; then 
			: # konec radku ignoruj
		else
			: echo "Debug: String obsahuje nejaky divne znaky >>$znak<< mimo -.| a mezery"
		fi
		done <<<$string
# 	echo	
# 	echo $sox_parametr
 	sox -n $zvukovy_soubor $sox_parametr trim 0.0 $pauza_tecka_carka &> /dev/null # chtelo by to jeste vyhladit pres fade
 	play $zvukovy_soubor &> /dev/null &
	}	
function align_left {		# $1pocet_znaku $2vlastni_text
	(($#==2)) || return 2
	((${#2}>$1)) && return 1
	printf '%s%*s' "$2" $(($1-${#2})) ''
	}
function align_right {		# $1pocet_znaku $2vlastni_text
	(($#==2)) || return 2
	((${#2}>$1)) && return 1
	printf '%*s%s' $(($1-${#2})) '' "$2"
	}
function align_center {		# $1pocet_znaku $2vlastni_text
	(($#==2)) || return 2
	((${#2}>$1)) && return 1
	l=$((($1-${#2})/2))
	printf '%*s%s%*s' $l '' "$2" $(($1-${#2}-l)) ''
	}
function Fpismena {
	start=$(date "+%s") # start programu
	pokusu=0
	spravne=0
	delka_vyber=${#Gvyber}
	REPLY=""
	pismeno_morse=""
	pismeno_slovem=""
	echo "Nápověda: Středník ; ukončuje cvičení"
	echo 
	date +%Y-%m-%d_%H-%M-%S >> jkmorseovka$(date +%Y-%m-%d).log
	s=0
	sekund_old=0
	while [ "$REPLY" != ";" ]	
		do 
		REPLY=""
		nahodile_pismeno=$(( $RANDOM % $delka_vyber ))
#  		echo "delka_vyber($delka_vyber) nahodile_pismeno($nahodile_pismeno)"
		pismeno=${Gvyber:nahodile_pismeno:1}
#  		echo "nahodile_pismeno: $nahodile_pismeno $pismeno (Gvyber $Gvyber)"
		cislo_pismena=$((abeceda_asociativni[$pismeno]-1)) # zpetne vyhleda cislo pismena v $abecede
# 		echo pismeno $pismeno cislo_pismena $cislo_pismena nahodile_pismeno $nahodile_pismeno z_abecedy ${abeceda[cislo_pismena]}; exit 
		pismeno_morse=$(Fpismeno_do_morse $pismeno)
		pismeno_slovem=$(Fpismeno_do_slov $pismeno)
		chybil=0
		while [ "$REPLY" != "$pismeno" ]
			do
			[ $chybil -lt 1 ] && ((pokusu++)) # navysi pocet pokusu u noveho pismena
			Fmorseovka_hrani $pismeno_morse $pismena_vizualne
			[ "$pismena_vizualne" == " " ] && echo -n $pismeno_morse 
# 			read -p "Pismeno? "
			read  -N1
			echo -ne "                                                                              \r"
			((abeceda_statistika_pokusy[$cislo_pismena]++)) 
			if [ "$REPLY" == ";" ]; then 
				echo -e "	(spravne/pokusu=$spravne/$pokusu=$(( 100*spravne/pokusu ))%)	v=$(( (6000*$s / $sekund ) / 100 )) zn/min\t$(( $sekund / $s )) s/zn"
				echo " $spravne/$pokusu=$(( 100*spravne/pokusu ))% v=$(( (6000*$s / $sekund ) / 100 )) z/min $(( $sekund / $s )) sekund/znak" >> jkmorseovka$(date +%Y-%m-%d).log 
					{
					echo 
					echo Statistika
					echo
						{
						for i in $(seq	0 $(( ${#abeceda[@]} - 1 )) )
							do 
							
							[ "${abeceda_statistika_pokusy[$i]}" != "0"  ] && echo  "${abeceda[$i]} ${abeceda_statistika_chyby[$i]}/${abeceda_statistika_pokusy[$i]}=$(bc -l <<<"scale=3;${abeceda_statistika_chyby[$i]}/${abeceda_statistika_pokusy[$i]}") ${abeceda_statistika_sekundy[$i]}/${abeceda_statistika_pokusy[$i]}=$(bc -l <<<"scale=3; ${abeceda_statistika_sekundy[$i]}/${abeceda_statistika_pokusy[$i]}")"
							done
						echo
						} |sort  --field-separator="=" -k3 > /dev/shm/jkmorseovka_statistika.tmp # --reverse
					}
					cat /dev/shm/jkmorseovka_statistika.tmp
					posledni_mohykani=$(sed "s/^\(.\).*/\1/" /dev/shm/jkmorseovka_statistika.tmp | tr -d "\n" )
					echo $posledni_mohykani
					echo 
					echo Z těchto znaků si vězměte nejpomalejších posledních pět a důkladně je procvičte, např:
					echo "jkmorseovka.sh --cviceni ${posledni_mohykani: -5} --mezi-pismeny 1000 --pocet-pismen 4" 
					echo 
					
				exit 
			elif [ "$REPLY" == "$pismeno" ]; then 
				sekund=$(( $(date "+%s") - $start ))
				abeceda_statistika_sekundy[$cislo_pismena]=$(( abeceda_statistika_sekundy[$cislo_pismena]+ $sekund - $sekund_old)) 
				((s++)) # dalsi pismeno
				[ $chybil == 0 ] && ((spravne++))
				if $statistika; then 
					echo -e "$(align_right 7 "$pismeno_morse")" "$(align_left 20 "$pismeno_slovem")" "$(align_right 5 "$(($sekund - $sekund_old))")"
					else
					echo -e "$(align_right 7 "$pismeno_morse")" "$(align_left 20 "$pismeno_slovem")"
				fi
# 				printf '     %-6s %15s %15d\n' "$pismeno_morse" "$pismeno_slovem" $(($sekund - $sekund_old))
				# echo			printf '\r%10s %-15s %15d \n'  "$pismeno_morse" "$pismeno_slovem" $(($sekund - $sekund_old))
				printf "\t%20s %15s% 15s%-15s\r" "spravne/pokusu=$spravne/$pokusu=$(( 100*spravne/pokusu ))%" "v=$(( (6000*$s / $sekund ) / 100 ))zn/min" "$(( $sekund / $s ))s/zn"
# 				echo -en "	(spravne/pokusu=$spravne/$pokusu=$(( 100*spravne/pokusu ))%)	v=$(( (6000*$s / $sekund ) / 100 )) zn/min	$(( $sekund / $s )) s/zn \r"
# 				echo " $pismeno_morse $pismeno_slovem	(spravne/pokusu=$spravne/$pokusu=$(( 100*spravne/pokusu ))%)"
				echo "$(date +%Y-%m-%d_%H-%M-%S) $pismeno 1 $(($sekund - $sekund_old))" >> jkmorseovka$(date +%Y-%m-%d).log
				chybil=0
				sekund_old=$sekund
			elif [ $chybil -gt 1  ]||[ "$REPLY" == "?" ]||[ "$REPLY" == "help" ]||[ "$REPLY" == "," ]; then echo; echo "Je to pismeno: $pismeno $pismeno_morse $pismeno_slovem"; 
				((chybil++))
			else 
				((chybil++))
				((abeceda_statistika_chyby[$cislo_pismena]++)) 
# 				echo "Chyba! Napoveda(?|help). Konec(;|exit|quit). spravne/pokusu=$spravne/$pokusu=$(( 100*spravne/pokusu ))%" 
				echo "$(date +%Y-%m-%d_%H-%M-%S) $pismeno 0" >> jkmorseovka$(date +%Y-%m-%d).log
 			fi
#  			echo 
		done
	done
	}
function Fcteni_znaku { # cte cele morse znaky, ale bez prubezneho zvuku; pomocna procedura k Fcviceni
		precteno_morse=""
		precteno_slovy=""
 		precteno_latinka=""
	while read -p "Morse znak (.-;): " -s precti_morse_znak; do # zadavaji se cele morse znaky --.
		pismeno_latinkou=$(Fmorse_do_latinky $precti_morse_znak)
		pismeno_slovem=$(Fpismeno_do_slov $pismeno_latinkou)
		pismeno_morse=$(Fpismeno_do_morse $pismeno_latinkou)
		Fmorseovka_hrani $pismeno_morse ":"
		echo "|$precti_morse_znak| = $pismeno_latinkou $pismeno_morse $pismeno_slovem"
		precteno_morse=$precteno_morse"|"$pismeno_morse
		precteno_latinka=$precteno_latinka"|"$pismeno_latinkou
		precteno_slovy=$precteno_slovy"|"$pismeno_slovem
		if [ "$precti_morse_znak" == ";" ]; then break; fi
		done
	Fmorseovka_hrani "$precteno_morse" ":"
	echo "	$precteno_morse"
	echo "	$precteno_latinka"	
	echo "	$precteno_slovy"	
	}
function Fdiktat	{ # $1 ":" vypina vypis
	if [ "$2" == ""  ]; then # nacte znaky z klavesnice
		echo "Jiny znak nez .- ukoncuje pismeno. Cely zapis ukoncuje strednik; "
		morse_diktat="" # cely diktat
		diktat_text="" #jednotlive tecky_carky
		pismeno_latinkou=""
		pismeno_morse="" 
		pismeno_slovem=""			
		cely_text="|"
		byla_mezera=0
# 		echo -n "|"
		while read -N1 -s diktat_text ; do
			if [ "$diktat_text" == "." ]; then
				Ftecka :
				echo -n "."
# 				Fmorseovka_hrani "." &>/dev/null
				morse_diktat="$morse_diktat."
				cely_text="$cely_text."
				byla_mezera=0
			elif [ "$diktat_text" == "-" ]; then
# 				Fmorseovka_hrani "-"  &>/dev/null
				Fcarka :
				echo -n "-"
				morse_diktat="$morse_diktat-"
				cely_text="$cely_text-"
				byla_mezera=0; 
			elif [ "$diktat_text" == ";" ]; then
				break		
				echo -n "|"
				cely_text="$cely_text|"
# 				echo "Cely text $cely_text"
			else # vse ostatni je konec znaku
#				morse_kod_do_latinky $morse_diktat
 				echo -e "\t$(Fmorse_do_latinky $morse_diktat)"
# 				echo;echo "morse_diktat($morse_diktat) cislo_pismena($cislo_pismena); pismeno_morse($pismeno_morse); pismeno_slovem($pismeno_slovem)"
				if [ $byla_mezera -eq 0 ]; then 
					byla_mezera=1; # toto je tedy konec znaku  
					cely_text="$cely_text|" #morse zapis
					cely_text_latinkou="$cely_text_latinkou$pismeno_latinkou"
				elif [ $byla_mezera -eq 1 ]; then 
					byla_mezera=2 # toto je tedy konec slova
					cely_text="$cely_text |" #morse zapis, vlozi mezeru
					cely_text_latinkou="$cely_text_latinkou " # vlozi mezeru
					byla_mezera=2; # uz byla mezera dalsi nepridavat 
				fi
# 						echo $pismeno_latinkou
# 			$1 printf "%10s %-10s %-10s %-10s \n"  "$morse_diktat" "$diktat_text" "$pismeno_latinkou" "$pismeno_slovem"
			morse_diktat="" 
			diktat_text=""
			pismeno_latinkou=""
			pismeno_morse="" 
			pismeno_slovem=""			
			fi
# 			Fpauza : &> /dev/null
# 			cely_text=""
# 			byla_mezera=0
		done
	else # morse text zadany z prikazove radky
		cely_text="$2"
	fi
		cely_text_latinkou=$(Fmorse_do_latinky "$cely_text")
	REPLY="y"
	while [ "$REPLY" == "y" ]; do 
		echo "$cely_text"
		echo "$cely_text_latinkou" 
		Fmorseovka_hrani "$cely_text" > /dev/null
		echo -e "\tZvukový soubor: $zvukovy_soubor"
		read -e -p "Prehrat jeste jednou? [y/N] "
		echo
	done
	}
function Fmorse_input	{ # $1 pocet znaku (0=neomezene) $2 ":" vypina vypis; $3 ":" vypina zvuk vraci input prevedeny do latinky
# 		echo "111 $1 222  $2 333 $3"  >&2
# 		echo "Jiny znak nez .- ukoncuje pismeno. Cely zapis ukoncuje strednik; "
		morse_diktat="" # cely diktat
		diktat_text="" #jednotlive tecky_carky
		pismeno_latinkou=""
		pismeno_morse="" 
		pismeno_slovem=""			
		cely_text="|"
		byla_mezera=0
# 		echo -n "|"
		i=0
		while read -N1 -s diktat_text ; do
			if [ "$diktat_text" == "." ]; then
				$3 Ftecka :
				$2 echo -n "." >&2
# 				Fmorseovka_hrani "." &>/dev/null
				morse_diktat="$morse_diktat."
				cely_text="$cely_text."
				byla_mezera=0
			elif [ "$diktat_text" == "-" ]; then
# 				Fmorseovka_hrani "-"  &>/dev/null
				$3 Fcarka :
				$2 echo -n "-" >&2
				morse_diktat="$morse_diktat-"
				cely_text="$cely_text-"
				byla_mezera=0; 
			elif [ "$diktat_text" == ";" ]; then
				break		
				$2 echo -n "|" >&2
				cely_text="$cely_text|"
# 				echo "Cely text $cely_text"
			else # vse ostatni je konec znaku
#  				$2 echo -e "\t$(Fmorse_do_latinky $morse_diktat)"
# 				echo;echo "morse_diktat($morse_diktat) cislo_pismena($cislo_pismena); pismeno_morse($pismeno_morse); pismeno_slovem($pismeno_slovem)"
				$2 echo -n "|" >&2
				if [ $byla_mezera -eq 0 ]; then 
					byla_mezera=1; # toto je tedy konec znaku  
					cely_text="$cely_text|" #morse zapis
					cely_text_latinkou="$cely_text_latinkou$pismeno_latinkou"
				elif [ $byla_mezera -eq 1 ]; then 
					byla_mezera=2 # toto je tedy konec slova
					cely_text="$cely_text |" #morse zapis, vlozi mezeru
					cely_text_latinkou="$cely_text_latinkou " # vlozi mezeru
					byla_mezera=2; # uz byla mezera dalsi nepridavat 
				fi
# 			$1 printf "%10s %-10s %-10s %-10s \n"  "$morse_diktat" "$diktat_text" "$pismeno_latinkou" "$pismeno_slovem"
			morse_diktat="" 
			diktat_text=""
			pismeno_latinkou=""
			pismeno_morse="" 
			pismeno_slovem=""			
			((i++)) # mame dalsi pismeno hotovo
			fi
# 			echo $i $1  >&2
		[ $i -eq $1 ]&& break;	
		done
# 		cely_text_latinkou="$(Fmorse_do_latinky "$cely_text")"
# 		echo "$cely_text_latinkou"
		Fmorse_do_latinky "$cely_text" 
	}
function Fopisovani {
# 	[ $nasel ] && opis_text="$Gcviceni_text" || opis_text="$Gtext"
	REPLY="y"
	while [ "$REPLY" == "y" ]||[ "$REPLY" == "" ]||[ "$REPLY" == "$(echo -e -n "\x0d")" ]||[ "$REPLY" == "p" ];do
		if [ "$REPLY" == "p" ]; then 
			Flatinka_do_morse "$Gcviceni_text"
			echo
			play "$zvukovy_soubor" &> /dev/null
		else	
			Gcviceni_text=""
			Fcviceni
			echo
			echo "Opiste tento text v morseovce: "
			echo "                                $Gcviceni_text"
			echo
			echo -n "|"
			Gpocet_pismen_opisovani=${#Gcviceni_text}
			cely_text_latinkou=$(Fmorse_input $Gpocet_pismen_opisovani $' ' $' ' ":")
			# 		Fdiktat : # :potlacuje graficky vystup
			echo
			if [ " $Gcviceni_text " == "$cely_text_latinkou"  ]; then 
				echo "	Shoda: $Gcviceni_text ==$cely_text_latinkou"
			else
				echo "	Neshoda: $Gcviceni_text !=$cely_text_latinkou"
			fi 
			morse=$(Flatinka_do_morse "$Gcviceni_text")
			Fmorseovka_hrani "$morse"
			echo
			cely_text_latinkou=""
		fi
		read -N1 -e -p "Vyzkouset jeste jednou? (p - prehrat znovu) [Y/n/p] "
		done 
	}		
function Fprocvicovani { # $1 textlatinkou
	latinka=$1
	echo
	echo -e "\t Hraji soubor: play $zvukovy_soubor "
	echo "Napoveda: [? help][; konec][cteni - hledani morse znaku]"
	echo
# 	REPLY="y"
	i=1
	s=0 # pocet opsanych pismen
	start=$(date "+%s") # start programu
	while true; do # [ "$REPLY" == "y" ];do
		morse=$(Flatinka_do_morse $latinka)
# 		echo "morse($morse) latinka($latinka)"
		Fmorseovka_hrani "$morse" &> /dev/null
		read -n $Gpocet_pismen_cviceni  -e -i "$odpoved"  -p "Co slyšíte? " odpoved
		if [[ "$odpoved" =~ .*\;.* ]];then break
		elif [ "$odpoved" == cteni ]; then Fcteni_znaku;
		elif [ "$odpoved" == "?" ]; then 
			echo Mělo by to být: $latinka;
		elif [ "$odpoved" == "$latinka" ];then	
			sekund=$(( $(date "+%s") - $start ))
			s=$(( Gpocet_pismen_cviceni + s )) # celkem pismen
			echo -e "\tSpravne na $i. pokus. Zadani: $latinka $morse	Rychlost: $s/$sekund=$(bc -l <<<"scale=3;60*$s/$sekund") zn/min" 
			echo "$(date +%Y-%m-%d_%H-%M-%S) $latinka $i $s/$sekund=$(bc -l <<<"scale=3;60*$s/$sekund")  zn/min" >> jkmorseovka$(date +%Y-%m-%d).log
			Fcviceni # vytvori novy nahodily retezec v Gcviceni_text
			latinka=$Gcviceni_text
			i=0
# 			read -N1 
			if [ "$REPLY" == ";" ];then break; fi
			odpoved=""
		else #if [ "$odpoved" != "$latinka" ];then 
			echo -e "\tSpatne ($i)."
		fi
		((i++))
	done 
	}	

# --- toto je main procedura --------------------------------
# ---function Fprikazova_radka {

    # =============================
    #      Argument Checking
    # =============================

    vFlag=false  # vypis znaku
    pFlag=false  # pismena
    PFlag=false  # pismena vizualne
    cFlag=false  # cviceni
    xFlag=false  # pocet znaku
    dFlag=false  # diktat
    oFlag=false  # opis
    mFlag=false  # do_morse
    lFlag=false  # do_latinky
    rFlag=false  # rychlost
    sFlag=false  # statistika
    hFlag=false  # help/usage
#     vypis_znaku=false # toto prednastaveni tam musi byt
    is_flag=false

#	 getopts does not support long options. We convert them to short one. # not used here
#		toto rozsiruje $@	./optarg.sh --dpi -i -p --pokus --primary # vystup je: -i -i -p --pokus -p
     for arg in "$@"; do
         shift
         case "$arg" in
		--pismena)      	set -- "$@" '-p' ;;
		--vypis-znaku)		set -- "$@" '-v' ;;
        	--pismena-vizualne) 	set -- "$@" '-P' ;; #
     		--cviceni)     		set -- "$@" '-c' ;;
         	--pocet-pismen)     	set -- "$@" '-x' ;;
            	--diktat)      		set -- "$@" '-d' ;;
            	--opis)			set -- "$@" '-o' ;;
            	--morse)      		set -- "$@" '-m' ;;
            	--latinka)     		set -- "$@" '-l' ;;
            	--rychlost)    		set -- "$@" '-r' ;;
            	--mezi-pismeny)    	set -- "$@" '-R' ;;
            	--statistika)    	set -- "$@" '-s' ;;
            	--help)    		set -- "$@" '-h' ;;
#             --)      set -- "$@" '-' ;;
            *)          set -- "$@" "$arg"
         esac
     done
    
    while getopts 'vhdsp:P:c:x:o:m:l:r:R:' opt     2> /dev/null ; do
        case $opt in
            # Long options
            r) 
				Grychlost="$OPTARG";  	
				rFlag=true; 
                ;;
            R) 
				Gmezi_znaky="$OPTARG";  	
				RFlag=true; 
                ;;
            v)  vFlag=true; 
                is_flag=true
                ;; 
            h)  hFlag=true; 
                is_flag=true;
				;;
            d)  dFlag=true; 
                is_flag=true; 
                ;;
            d)  sFlag=true; # statistika
#                 is_flag=true; 
                ;;
            p) 
			    if [ "$OPTARG" == "" ]; then
					echo "Text na procvicovani musi byt zadan: Bud vyctem pismen \"bflmpsvz\" nebo odkazem na cviceni: \"cviceni4a\", napr.:"
					echo "jkmorseovka.sh --pismena cviceni123"
					exit
				else
					Gtext="$OPTARG";  	
				fi
                pFlag=true; 
                is_flag=true; 
#                 break
                ;;
			P) 
                is_flag=true; 
				pFlag=true;   
				PFlag=true;   
			    if [ "$OPTARG" == "" ]; then
						echo "Text na procvicovani musi byt zadan: Bud vyctem pismen \"bflmpsvz\" nebo odkazem na cviceni: \"cviceni4a\", napr.:"
						echo "jkmorseovka.sh --pismena-vizualne cviceni123"
						exit
					else
						Gtext="$OPTARG";  	
					fi
				if $PFlag; then 
						pismena_vizualne=" " # dvojtecka respektive mezera - pri cviceni pismena se vypisuji carky tecky na obrazovku
					else
						pismena_vizualne=":" 				
					fi
# 				break	
				;;
            c) 
			    if [ "$OPTARG" == "" ]; then
					echo "Text na procvicovani musi byt zadan: Bud vyctem pismen \"bflmpsvz\" nebo odkazem na cviceni: \"cviceni4a\", napr.:"
					echo "jkmorseovka.sh --pismena cviceni123"
					exit
				else
					Gtext="$OPTARG";  	
				fi
                cFlag=true; 
                is_flag=true; 
                ;;
            x) 
				Gpocet_pismen_cviceni=$OPTARG
				Gpocet_pismen_opisovani=$OPTARG
                xFlag=true; 
                ;;
            o) 
			    if [ "$OPTARG" == "" ]; then
					echo "Text na opisovani musi byt zadan: Bud vyctem pismen \"bflmpsvz\" nebo odkazem na cviceni: \"cviceni4a\", napr.:"
					echo "jkmorseovka.sh --opisovani cviceni123"
					exit
				else
# 					Gtext="$OPTARG";
					Gtext=${OPTARG,,} # mala pismena
				fi
				oFlag=true; 
                is_flag=true; 
#                 break
                ;;
            m) 
#  				echo "optarg($OPTARG) Gpocet_pismen_cviceni($Gpocet_pismen_cviceni)"
			    if [ "$OPTARG" == "" ]; then
					echo "Text na prevod musi byt zadan latinkou, např.:"
					echo "jkmorseovka.sh --morse \"Ervenice\""
					exit
				else
# 					Gtext="$OPTARG";  	
					Gtext=${OPTARG,,} # prevede na mala pismena
#  				echo "optarg($OPTARG) Gtext($Gtext) Gpocet_pismen_cviceni($Gpocet_pismen_cviceni)"
				fi
                mFlag=true; 
                is_flag=true; 
                ;;
            l) 
#  				echo "optarg($OPTARG) Gpocet_pismen_cviceni($Gpocet_pismen_cviceni)"
			    if [ "$OPTARG" == "" ]; then
					echo "Text na prevod musi byt zadan morseovkou, např.:"
					echo "jkmorseovka.sh --morse \"/.../.-/--/.-/ |...-|---|-..|.-|\""
					exit
				else
					Gtext="$OPTARG";  	
				fi
                lFlag=true; 
                is_flag=true; 
                ;;
            \?) echo
				echo "Tento argument vyzaduje specifikovany text nebo cviceni (zpravidla cviceni1234)"
				echo
				Fusage 
				;;
            :)  echo dvojtecka;
				Fusage 
				;;
        esac
    done
    
if ! $is_flag ; then
	echo Program na učení morseovy abecedy
	echo ---------------------------------
	echo
	echo Program vyžaduje nějaké parametry, např. 
	echo "$nazev_programu --help"
	echo
fi

Fcviceni # nastavi promennou Gvyber Gcviceni_text
Fnastaveni_rychlosti $Grychlost

if $hFlag; then 
	Fusage
	exit
elif $pFlag; then 
	Fpismena
	exit
elif $vFlag; then 
	Fvypis_znaku
	exit
elif $dFlag; then
# 	echo $2
	Fdiktat "$(echo ' ')" "$2" #":" potlaci vizualni vystup pri psani
	exit
elif $cFlag; then
# 	echo "text($Gtext)" 
# 	echo "navrat Fcviceni $(Fcviceni $Gtext)"
	Fprocvicovani $Gcviceni_text
# 	echo Fprocvicovani $Gcviceni_text
	exit
elif $oFlag; then
	Fopisovani #$Gcviceni_text
	exit
elif $lFlag; then
#  	echo jsem do latinky
	latinka=$(echo "$Gtext" | sed "s:/:|:g")
	Fmorse_do_latinky "$latinka"
	echo
	exit
elif $mFlag; then
# 	echo jsem do morse
# 	latinka=$(echo $Gtext | sed "s:/:|:g")
	morse=$(Flatinka_do_morse "$Gtext")
	echo "$morse"
	Fmorseovka_hrani "$morse"
	echo -e "\tZvukový soubor: $zvukovy_soubor" >&2
	exit
	fi
exit
