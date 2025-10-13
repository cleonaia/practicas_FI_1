#!/bin/bash
DATASET_FILE="cities.csv"
codi_pais="XX"
codi_estat="XX"

show_menu() {
    echo "==============================="
    echo "q   - sortir de l'aplicació"
    echo "lp  - llistar els països (sense repeticions)"
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
    read opt
    case $opt in
        q)
            echo "Sortint de l'aplicació"
            ;;
        lp)
            echo "country_code country_name"
            cut -d',' -f7,8 "$DATASET_FILE" | tail -n +2 | sort -u | column -t -s','
            ;;
        sc)
            echo "Introdueix el nom o codi del país:"
            read pais
            if [ -z "$pais" ]; then
                echo "No s’ha introduït cap país. El país actual segueix sent: $codi_pais"
            else
                # Busca por código (exacto, insensible a mayúsculas)
                codi=$(cut -d',' -f7 "$DATASET_FILE" | grep -i "^$pais$" | sort -u)
                # Si no encuentra por código, busca por nombre (con o sin comillas, insensible a mayúsculas)
                if [ -z "$codi" ]; then
                    codi=$(cut -d',' -f7,8 "$DATASET_FILE" | grep -i ",$pais$" | cut -d',' -f1 | sort -u)
                fi
                if [ -z "$codi" ]; then
                    codi=$(cut -d',' -f7,8 "$DATASET_FILE" | grep -i ",\"$pais\"$" | cut -d',' -f1 | sort -u)
                fi
                if [ -z "$codi" ]; then
                    echo "El país '$pais' no existeix al dataset."
                    codi_pais="XX"
                else
                    codi_pais="$codi"
                    echo "País seleccionat: $pais (codi: $codi_pais)"
                fi
            fi
            ;;
        le)
            if [ "$codi_pais" = "XX" ]; then
                echo "No s’ha seleccionat cap país. Usa l’opció 'sc' per seleccionar-ne un."
            else
                echo "Estats del país amb codi $codi_pais:"
                echo "state_code state_name"
                grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f4,5 | sort -u | column -t -s','
            fi
            ;;
        se)
            if [ "$codi_pais" = "XX" ]; then
                echo "Primer selecciona un país amb 'sc'."
            else
                echo "Introdueix el nom o codi de l'estat:"
                read estat_input
                if [ -z "$estat_input" ]; then
                    echo "Es manté l'estat actual: $codi_estat"
                else
                    codi_e=$(grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f4,5 | grep -i "^$estat_input," | cut -d',' -f1 | sort -u)
                    if [ -z "$codi_e" ]; then
                        codi_e=$(grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f4,5 | grep -i ",$estat_input$" | cut -d',' -f1 | sort -u)
                    fi
                    if [ -z "$codi_e" ]; then
                        codi_e=$(grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f4,5 | grep -i ",\"$estat_input\"$" | cut -d',' -f1 | sort -u)
                    fi
                    if [ -z "$codi_e" ]; then
                        codi_estat="XX"
                        echo "Estat no trobat o no pertany al país. Valor assignat: XX"
                    else
                        codi_estat="$codi_e"
                        echo "Estat seleccionat: $estat_input (codi: $codi_estat)"
                    fi
                fi
            fi
            ;;
        lcp)
            if [ "$codi_pais" = "XX" ]; then
                echo "Primer selecciona un país amb 'sc'."
            else
                echo "name wikidataId"
                grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f2,11 | sort -u | column -t -s','
            fi
            ;;
        ecp)
            if [ "$codi_pais" = "XX" ]; then
                echo "Primer selecciona un país amb 'sc'."
            else
                arxiu="${codi_pais}.csv"
                grep ",$codi_pais," "$DATASET_FILE" | cut -d',' -f2,11 | sort -u > "$arxiu"
                echo "Poblacions extretes a l'arxiu: $arxiu"
            fi
            ;;
        lce)
            if [ "$codi_pais" = "XX" ] || [ "$codi_estat" = "XX" ]; then
                echo "Primer selecciona un país amb 'sc' i un estat amb 'se'."
            else
                echo "name wikidataId"
                grep ",$codi_pais," "$DATASET_FILE" | grep ",$codi_estat," | cut -d',' -f2,11 | sort -u | column -t -s','
            fi
            ;;
        gwd)
            if [ "$codi_pais" = "XX" ] || [ "$codi_estat" = "XX" ]; then
                echo "Primer selecciona un país amb 'sc' i un estat amb 'se'."
            else
                echo "Introdueix el nom d'una població:"
                read poblacio
                if [ -z "$poblacio" ]; then
                    echo "No s’ha introduït cap població."
                else
                    wdid=$(grep ",$codi_pais," "$DATASET_FILE" | grep ",$codi_estat," | cut -d',' -f2,11 | grep -i "^$poblacio," | cut -d',' -f2 | sort -u)
                    if [ -z "$wdid" ]; then
                        wdid=$(grep ",$codi_pais," "$DATASET_FILE" | grep ",$codi_estat," | cut -d',' -f2,11 | grep -i ",$poblacio$" | cut -d',' -f2 | sort -u)
                    fi
                    if [ -z "$wdid" ]; then
                        wdid=$(grep ",$codi_pais," "$DATASET_FILE" | grep ",$codi_estat," | cut -d',' -f2,11 | grep -i ",\"$poblacio\"$" | cut -d',' -f2 | sort -u)
                    fi
                    if [ -z "$wdid" ]; then
                        echo "No s'ha trobat la població o no té wikidataId."
                    else
                        url="https://www.wikidata.org/wiki/Special:EntityData/${wdid}.json"
                        arxiu="${wdid}.json"
                        echo "Descarregant dades de WikiData..."
                        curl -s "$url" -o "$arxiu"
                        echo "Dades guardades a $arxiu"
                    fi
                fi
            fi
            ;;
        est)
            echo "Calculant estadístiques..."
            awk -F',' 'NR>1{lat=$9+0;lon=$10+0;wdid=$11;if(lat>0)nord++;if(lat<0)sud++;if(lon>0)est++;if(lon<0)oest++;if(lat==0&&lon==0)no_ubic++;if(wdid==""||wdid=="NULL")no_wdid++}END{printf "Nord %d Sud %d Est %d Oest %d No ubic %d No WDId %d\n",nord,sud,est,oest,no_ubic,no_wdid}' "$DATASET_FILE"
            ;;
        *)
            echo "Opció no vàlida. Torna-ho a intentar."
            ;;
    esac
    echo ""
done
