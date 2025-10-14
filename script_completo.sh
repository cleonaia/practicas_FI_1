##################################################################
# Script creat per Zhengli Sun & Leo Aguayo                      #
#                                                                #
# Aquest script que fem permet a l'usuari interactuar amb un     #
# fitxer CSV que conté informació sobre ciutats,països i estats. #
# L'usuari pot llistar països, seleccionar-ne un, veure els      #
# estats d'un país, seleccionar un estat, llistar poblacions     #
# per país o estat, exportar-les, obtenir dades de WikiData      #  
# i calcular estadístiques bàsiques.                             #
#                                                                #
# Funcionament general:                                          #
# - El menú principal mostra totes les opcions disponibles.      #
# - L'usuari pot seleccionar opcions introduint el codi          #
#   corresponent.                                                #
# - Les seleccions de país i estat es guarden en variables       #
#   globals per facilitar la navegació entre opcions.            #
# - El tractament de dades es fa amb eines bàsiques de shell     #
#   (grep, cut, sort, column, sed, etc.), i només s'utilitza     #
#   awk per a les estadístiques.                                 #
#                                                                #
# -------------------------------------------------------------- #
# Ús d'ordres principals:                                        #
# -------------------------------------------------------------- #
# Aquest script utilitza diverses eines bàsiques de processament #
# de text de Unix per filtrar i formatar les dades del CSV.      #
# Les més importants són:                                        #
#   - grep   : Filtra línies que contenen un patró determinat.   #
#               S'utilitza per seleccionar només les files que   #
#               corresponen a un país, estat o ciutat concret.   #
#   - cut    : Extreu columnes específiques d'un fitxer CSV,     #
#               separant pel caràcter coma.                      #
#   - sort   : Ordena les línies alfabèticament o numèricament.  #
#               S'utilitza per garantir que les sortides no      #
#               tinguin duplicats i estiguin ordenades.          #
#   - uniq   : Elimina línies duplicades consecutives.           #
#               S'utilitza conjuntament amb sort per obtenir     #
#               llistats sense repeticions.                      #
#   - column : Dona format en columnes a la sortida per fer-la   #
#               més llegible a la terminal.                      #
#   - sed    : Fa substitucions o neteja caràcters especials,    #
#               com ara eliminar cometes.                        #
#   - awk    : Només s'utilitza per calcular estadístiques, ja   #
#               que permet processar i comptar camps numèrics    #
#               de manera eficient.                              #
# Aquestes ordres es combinen per filtrar, seleccionar i         #
# mostrar la informació de manera clara i estructurada segons    #
# les opcions del menú.                                          #
# -------------------------------------------------------------- #
#                                                                #
# Explicació de variables clau:                                  #
#   DATASET_FILE: Nom del fitxer CSV que conté el dataset.       #
#   codi_pais: Variable que emmagatzema el codi del país         #
#              seleccionat per l'usuari. Inicialment "XX".       #
#   codi_estat: Variable que emmagatzema el codi de l'estat      #
#               seleccionat per l'usuari. Inicialment "XX".      #
#                                                                #
# Cada opció del menú està implementada amb un bloc de codi      #
# dins d'un case, i es controla l'estat de selecció per evitar   #
# errors o consultes sense context.                              #
#                                                                #
# L'objectiu és poder oferir una eina robusta, clara i fàcil     #
# d'usar, seguint els requisits de la pràctica.                  #
##################################################################

#!/bin/bash  

DATASET_FILE="cities.csv"

opt="x" 
codi_pais="XX"
codi_estat="XX"

# Funció per mostrar el menú principal
show_menu() {
    echo "==============================="
    echo "q   - sortir de l'aplicació"
    echo "lp  - llistar els països"
    echo "sc  - seleccionar un país"
    echo "le  - llistar els estats d'un país"
    echo "se  - seleccionar un estat"
    echo "lcp - llistar ciutats per país"
    echo "ecp - exportar ciutats per país"
    echo "lce - llistar ciutats per estat"
    echo "gwd - obtenir dades de WikiData"
    echo "est - obtenir estadístiques"
    echo "==============================="
    echo "País seleccionat: $codi_pais"
    echo "Estat seleccionat: $codi_estat"
    echo "Selecciona una opció:"
}

opt="x"

while [ "$opt" != "q" ]; do
    show_menu    
    read opt     # Llegeix l'opció introduïda per l'usuari
    case $opt in   # S'executa el bloc corresponent segons l'opció escollida
        q)
            echo "Sortint de l'aplicació"
            ;;
        lp)
            # Llista tots els països sense repeticions (mostra codi i nom)
            echo "country_code country_name"  # Mostra la capçalera
            # !Explicació d'ordres: cut: extreu les columnes de codi i nom de país | tail: elimina la capçalera original del CSV | sort -u: ordena i elimina duplicats | column: formata la sortida en columnes
            cut -d',' -f7,8 "$DATASET_FILE" | tail -n +2 | sort -u | column -t -s','
            ;;
        sc)
            # Permet seleccionar un país pel seu nom o codi
            echo "Introdueix el nom o codi del país:"
            read pais  
            if [ -z "$pais" ]; then  # Comprova si l'usuari no ha introduït cap valor per al país (cadena buida)
                echo "No s’ha introduït cap país. El país actual segueix sent: $codi_pais" # Si l'usuari no introdueix res, es manté el país actual
            else
                # !Explicació d'ordres:cut: extreu la columna de codi de país | grep -i: busca coincidència exacta pel codi (insensible a majúscules) | sort -u: elimina duplicats
                codi=$(cut -d',' -f7 "$DATASET_FILE" | grep -i "^$pais$" | sort -u) # Primer, busca pel codi exacte (omitint les majúscules/minúscules)
                # Si no troba pel codi, busca pel nom (sense o amb cometes)
                # !Explicació d'ordres: cut: extreu les columnes de codi i nom de país | grep -i: busca coincidència pel nom (insensible a majúscules) | cut: es queda només amb el codi | sort -u: elimina duplicats
                if [ -z "$codi" ]; then
                    codi=$(cut -d',' -f7,8 "$DATASET_FILE" | grep -i ",$pais$" | cut -d',' -f1 | sort -u)
                fi
                # Repeteix el procés però buscant noms entre cometes
                if [ -z "$codi" ]; then
                    codi=$(cut -d',' -f7,8 "$DATASET_FILE" | grep -i ',"$pais"$' | cut -d',' -f1 | sort -u)
                fi
                if [ -z "$codi" ]; then
                    # Si no es troba el país, es mostra un missatge d'error i es posa XX
                    echo "El país '$pais' no existeix al dataset."
                    codi_pais="XX"
                else
                    # Si es troba, s'actualitza la variable i es mostra el país seleccionat
                    codi_pais="$codi"
                    echo "País seleccionat: $pais (codi: $codi_pais)"
                fi
            fi
            ;;
        le)
            # Llista els estats del país seleccionat
            if [ "$codi_pais" = "XX" ]; then
                # Si no hi ha país seleccionat, es mostra un avís
                echo "No s’ha seleccionat cap país. Usa l’opció 'sc' per seleccionar-ne un."
            else
                # Mostra els estats del país amb el seu codi i nom
                echo "Estats del país amb codi $codi_pais:"
                echo "state_code state_name"  # Mostra la capçalera
                # !Explicació d'ordres: grep: filtra només les files del país seleccionat | cut: extreu les columnes de codi i nom d'estat | sort -u: ordena i elimina duplicats | column: formata la sortida en columnes
                grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f4,5 | sort -u | column -t -s','
            fi
            ;;
        se)
            # Permet seleccionar un estat pel seu nom o codi
            if [ "$codi_pais" = "XX" ]; then
                echo "Primer selecciona un país amb 'sc'."
            else   # Si no hi ha país seleccionat, no es pot seleccionar estat
                echo "Introdueix el nom o codi de l'estat:"
                read estat_input  # Llegeix el valor introduït per l'usuari
                if [ -z "$estat_input" ]; then
                    # Si no s'introdueix res, es manté l'estat actual
                    echo "Es manté l'estat actual: $codi_estat"
                else
                    # !Explicació ordres: Busca primer pel codi exacte (omitint majúscules/minúscules) amb l'ús d'ordres | grep: filtra només les files del país seleccionat | cut: extreu les columnes de codi i nom d'estat | grep -i: busca coincidència exacta pel codi d'estat (insensible a majúscules) | cut: es queda només amb el codi | sort -u: elimina duplicats
                    codi_e=$(grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f4,5 | grep -i "^$estat_input," | cut -d',' -f1 | sort -u)
                    # Si no troba pel codi, busca pel nom (sense o amb cometes) 
                    if [ -z "$codi_e" ]; then
                        codi_e=$(grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f4,5 | grep -i ",$estat_input$" | cut -d',' -f1 | sort -u)
                    fi
                    if [ -z "$codi_e" ]; then
                        codi_e=$(grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f4,5 | grep -i ',"$estat_input"$' | cut -d',' -f1 | sort -u)
                    fi
                    if [ -z "$codi_e" ]; then
                        # Si no es troba l'estat, es mostra un missatge i es posa XX
                        codi_estat="XX"
                        echo "Estat no trobat o no pertany al país. Valor assignat: XX"
                    else
                        # Si es troba, s'actualitza la variable i es mostra l'estat seleccionat
                        codi_estat="$codi_e"
                        echo "Estat seleccionat: $estat_input (codi: $codi_estat)"
                    fi
                fi
            fi
            ;;
        lcp)
        # Comprovem si el codi del país ha estat selecionat
            if [ "$codi_pais" = "XX" ]; then
            # Si no li demanem que ho seleccioni
                echo "Primer selecciona un país amb 'sc'."
            else
            # Si ja ha seleccionat un país, busquem el país al l'arxiu (DATASET_FILE), tallem les columnes 2 i 11, ordenem els resultats i elimina els duplicats, guarda els resultats en format taula i utilitza ',' com a separador
                echo "name wikidataId"
                #Fiquem les dos comes al codi_pais ja que així ens asegurem que busquem exactamen un camp complert.
                grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f2,11 | sort -u | column -t -s','
            fi
            ;;
        ecp)
            if [ "$codi_pais" = "XX" ]; then
            # Comprovem si s'ha seleccionat el país, si no li demanem que ho seleccioni.
                echo "Primer selecciona un país amb 'sc'."
            else
            # Si ja l'ha seleccionat li demanem que crei un arxiu amb el codi del país
                arxiu="${codi_pais}.csv"
                #Busca ls linees que contenen el país a l'arxiu DATASET_FILE, i talle les linees 2 i 11 separades per comes, les ordena i elimina duplicats, gurada el resultat en $arxiu.
                grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f2,11 | sort -u > "$arxiu"
                echo "Poblacions extretes a l'arxiu: $arxiu"
            fi
            ;;
        lce)
            #Comprovem si el codi del pais o el codi de l'estat ja estan asignats amb una condició "or"
            if [ "$codi_pais" = "XX" ] || [ "$codi_estat" = "XX" ]; then
            # Si no estan asignats, li demanem que ho asigni
                echo "Primer selecciona un país amb 'sc' i un estat amb 'se'."
            else
            # Si ja estan asignats, busquem el país seleccionat (,$codi_pais,) a l'arxiu ($DATASET_FILE), busquem l'estat i ens quedem amb les columnes 2 i 11, ordenem els resultats i creem una taula on li diem que la separació de camps és la ','
                echo " "
                grep ",$codi_pais," "$DATASET_FILE" | grep ",$codi_estat," | cut -d',' -f2,11 | sort -u | column -t -s','
            fi
            ;;
        gwd) #Guardem les dades del país selecionat en un arxiu json
            #Dividim amb un if i un else, ja que volem comprovar que totes les dades per executar aquest codi ja estiguin assignades
            if [ "$codi_pais" = "XX" ] || [ "$codi_estat" = "XX" ]; then #Comprovem si el pais i l'estat ja estan asignats mitjançant un "or"
                echo "Primer selecciona un país amb 'sc' i un estat amb 'se'." #Si no estan seleccionats demanem que es seleccioni el país o l'estat
            #Si ja han estat assignats li demanem el nom d'una població
            else
                echo "Introdueix el nom d'una població:"
                read poblacio
                if [ -z "$poblacio" ]; then #Comprovem si la població no existeix o no és correcta avisem
                    echo "No s’ha introduït cap població."
                else
                # Si la població introduida és correcta busquem a l'arxiu(DATASET_FILE) el país (codi_pais), un cop trobats el paisos busquem l'estat(codi_estat), tallem i ens quedem les columnes 2 i 11, busquem les línies en les que la primera columna continguin la població ignorant majuscules i minúscules, ordenem els resultst i eliminem els duplicats i el resultat es queda en la variable "wdid"
                    wdid=$(grep ",$codi_pais," "$DATASET_FILE" | grep ",$codi_estat," | cut -d',' -f2,11 | grep -i "^$poblacio," | cut -d',' -f2 | sort -u)
                    if [ -z "$wdid" ]; then
                    #Comprovem si la variable està buida, si ho està, fem el mateix procediment però aquest cop en comptes de buscar-ho a la primera columna ($poblacio,), la busquem a la segona columna (,$poblacio$)
                        wdid=$(grep ",$codi_pais," "$DATASET_FILE" | grep ",$codi_estat," | cut -d',' -f2,11 | grep -i ",$poblacio$" | cut -d',' -f2 | sort -u)
                    fi
                    if [ -z "$wdid" ]; then
                    #Comprovem si la variable està buida, si ho està, fem el mateix procediment però aquest cop en comptes de buscar-ho a la segona columna (,$poblacio$), busquem si el nom de la població acaba en una coma i està seguida del nom de la població (,\"$poblacio\"$)
                        wdid=$(grep ",$codi_pais," "$DATASET_FILE" | grep ",$codi_estat," | cut -d',' -f2,11 | grep -i ",\"$poblacio\"$" | cut -d',' -f2 | sort -u)
                    fi
                    if [ -z "$wdid" ]; then
                    #Si tot i això no troba la població li diem que no l'hem trobat
                        echo "No s'ha trobat la població o no té wikidataId."
                    else
                    #Si trobem la població la guardem en una url amb el WikiDatald del país
                        #Creem una url amb el WikiDatald del país
                        url="https://www.wikidata.org/wiki/Special:EntityData/${wdid}.json"
                        #Creem un arxiu amb el nom del WikiDatald del país
                        arxiu="${wdid}.json"
                        echo "Descarregant dades de WikiData..."
                        # Utilitzem curl per descarregar (-s) l'arxiu JSON desde la URL creada i guradem els resultats a l'arxiu
                        curl -s "$url" -o "$arxiu"
                        echo "Dades guardades a $arxiu"
                    fi
                fi
            fi
            ;;
        est)
            echo "Calculant estadístiques..."
#Primer li diem a awk que el separador de camps és una coma
#NR significa número de registre, i NR>1 salta a la primera línea
#Comprovem les diferents condicions, si la latitud és major de 0 incrementem nord, si és més petita incrementem sud, si la longitud és més gran de 0 incrementem est, si és més petita incrementem oest
#(if(lat==0&&lon==0) no_ubic++) Suma les coordenades, si són (0,0) indica que no estan ubicades
#(if(wdid==""||wdid=="NULL")no_wdid++) Si el camp wdid esta buit o té NULL indica que no té indentificador
#Acaba amb el END, imprimint els resultats dels comptadors
#(DATASET_FILE) ens indica d'on llegeix l'awk
            awk -F',' 'NR>1{lat=$9+0;lon=$10+0;wdid=$11;if(lat>0)nord++;if(lat<0)sud++;if(lon>0)est++;if(lon<0)oest++;if(lat==0&&lon==0)no_ubic++;if(wdid==""||wdid=="NULL")no_wdid++}END{printf "Nord %d Sud %d Est %d Oest %d No ubic %d No WDId %d\n",nord,sud,est,oest,no_ubic,no_wdid}' "$DATASET_FILE"
            ;;
        *)
            #Si l'opció no és vàlida, avisem a l'usuari
            echo "Opció no vàlida. Torna-ho a intentar."
            ;;
