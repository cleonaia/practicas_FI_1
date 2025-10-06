#!/bin/bash

# Script complet corregit per a la pràctica: implementa les ordres del dataset
# Variables globals
DATASET_FILE="cities.csv"
codi_pais="XX"
codi_estat="XX"

show__menu() {
    printf "\n===============================\n"
    printf "        Menú de comandes      \n"
    printf "===============================\n"
    printf "  q   - Sortir de l'aplicació\n"
    printf "  lp  - Llistar països\n"
    printf "  sc  - Seleccionar país\n"
    printf "  le  - Llistar els estats del país seleccionat\n"
    printf "  se  - Seleccionar estat\n"
    printf "  lcp - Llistar poblacions del país\n"
    printf "  ecp - Extreure poblacions del país\n"
    printf "  lce - Llistar poblacions de l'estat\n"
    printf "  gwd - Obtenir dades WikiData\n"
    printf "  est - Obtenir estadístiques\n"
    printf "===============================\n"
    [ "$codi_pais" != "XX" ] && printf "País seleccionat: %s\n" "$codi_pais"
    [ "$codi_estat" != "XX" ] && printf "Estat seleccionat: %s\n" "$codi_estat"
}

while true; do
    print_menu
    read -p "Introdueix una opció: " opcio
    echo ""

    case "$opcio" in
        q)
            echo "Sortint de l'aplicació"
            exit 0
            ;;

        lp)
            echo "country_code country_name"
            cut -d',' -f7,8 "$DATASET_FILE" | tail -n +2 | sort | uniq | column -s, -t
            ;;

        sc)
            echo "Introdueix el nom o codi del país:"; read pais
            if [ -z "$pais" ]; then
                echo "No has introduït cap país. El valor no canvia."
            else
                pais_trim=$(echo "$pais" | sed 's/^\s*//;s/\s*$//')
                codi=""
                # si sembla un codi curt, provar per codi (case-insensitive)
                if printf "%s" "$pais_trim" | grep -Eq '^[A-Za-z0-9]{1,3}$'; then
                    codi=$(grep -i ",${pais_trim}," "$DATASET_FILE" | head -n1 | cut -d',' -f7)
                    if [ -n "$codi" ]; then
                        nom=$(grep -i ",${codi}," "$DATASET_FILE" | head -n1 | cut -d',' -f8 | sed 's/^"//;s/"$//')
                        codi_pais="$codi"
                        echo "País seleccionat: $nom ($codi_pais)"
                    fi
                fi

                # si no trobat per codi, provar per nom (case-insensitive)
                if [ -z "$codi" ]; then
                    codi=$(awk -F',' 'NR>1{n=$8; gsub(/^"|"$/,"",n); print $7","n}' "$DATASET_FILE" | grep -i ",${pais_trim}$" | cut -d',' -f1 | uniq)
                    if [ -n "$codi" ]; then
                        codi_pais="$codi"
                        echo "País seleccionat: $pais_trim ($codi_pais)"
                    else
                        codi_pais="XX"
                        echo "País no trobat. Variable assignada a XX."
                    fi
                fi
            fi
            ;;

        le)
            if [ -z "$codi_pais" ] || [ "$codi_pais" = "XX" ]; then
                echo "No hi ha cap país seleccionat."
            else
                echo "state_code state_name"
                awk -F',' -v cp="$codi_pais" 'NR>1 && $7==cp {print $4","$5}' "$DATASET_FILE" | sort | uniq | column -s, -t
            fi
            ;;

        se)
            echo "Introdueix el nom o codi de l'estat:"; read estat
            if [ -z "$estat" ]; then
                echo "No has introduït cap estat. El valor no canvia."
            else
                estat_trim=$(echo "$estat" | sed 's/^\s*//;s/\s*$//')
                codi_e=""
                # provar per codi d'estat (exacte) dins del país seleccionat
                if printf "%s" "$estat_trim" | grep -Eq '^[A-Za-z0-9]+$'; then
                    codi_e=$(awk -F',' -v cp="$codi_pais" -v code="$estat_trim" 'NR>1 && $7==cp && $4==code {print $4; exit}' "$DATASET_FILE")
                fi
                # si no trobat per codi, provar per nom (case-insensitive) de forma portable
                if [ -z "$codi_e" ]; then
                    estat_lc=$(printf '%s' "$estat_trim" | tr '[:upper:]' '[:lower:]')
                    codi_e=$(awk -F',' -v cp="$codi_pais" 'NR>1 && $7==cp {n=$5; gsub(/^"|"$/,"",n); print $4","n}' "$DATASET_FILE" | tr '[:upper:]' '[:lower:]' | grep -F ",${estat_lc}" | cut -d',' -f1 | uniq)
                fi
                if [ -z "$codi_e" ]; then
                    codi_estat="XX"
                    echo "Estat no trobat o no pertany al país. Variable assignada a XX."
                else
                    codi_estat="$codi_e"
                    echo "Estat seleccionat: $estat_trim ($codi_estat)"
                fi
            fi
            ;;

        lcp)
            if [ -z "$codi_pais" ] || [ "$codi_pais" = "XX" ]; then
                echo "No hi ha cap país seleccionat."
            else
                echo "name wikidataId"
                awk -F',' -v cp="$codi_pais" 'NR>1 && $7==cp {print $2","$11}' "$DATASET_FILE" | sort | uniq | column -s, -t
            fi
            ;;

        ecp)
            if [ -z "$codi_pais" ] || [ "$codi_pais" = "XX" ]; then
                echo "No hi ha cap país seleccionat."
            else
                arxiu="${codi_pais}.csv"
                awk -F',' -v cp="$codi_pais" 'NR>1 && $7==cp {print $2","$11}' "$DATASET_FILE" | sort | uniq > "$arxiu"
                echo "Poblacions extretes a l'arxiu: $arxiu"
            fi
            ;;

        lce)
            if [ -z "$codi_pais" ] || [ "$codi_pais" = "XX" ]; then
                echo "No hi ha cap país seleccionat."
            elif [ -z "$codi_estat" ] || [ "$codi_estat" = "XX" ]; then
                echo "No hi ha cap estat seleccionat."
            else
                echo "name wikidataId"
                awk -F',' -v cp="$codi_pais" -v ce="$codi_estat" 'NR>1 && $7==cp && $4==ce {print $2","$11}' "$DATASET_FILE" | sort | uniq | column -s, -t
            fi
            ;;

        gwd)
            if [ -z "$codi_pais" ] || [ "$codi_pais" = "XX" ]; then
                echo "No hi ha cap país seleccionat."
            elif [ -z "$codi_estat" ] || [ "$codi_estat" = "XX" ]; then
                echo "No hi ha cap estat seleccionat."
            else
                echo "Introdueix el nom de la població:"; read poblacio
                if [ -z "$poblacio" ]; then
                    echo "No has introduït cap població."
                else
                    wikidata_id=$(awk -F',' -v cp="$codi_pais" -v ce="$codi_estat" -v p="$poblacio" 'NR>1 && $7==cp && $4==ce {n=$2; gsub(/^"|"$/, "", n); if (n==p) {print $11; exit}}' "$DATASET_FILE")
                    if [ -z "$wikidata_id" ]; then
                        echo "Població no trobada o sense WikiData ID."
                    else
                        arxiu="${wikidata_id}.json"
                        url="https://www.wikidata.org/wiki/Special:EntityData/${wikidata_id}.json"
                        echo "Descarregant dades de WikiData..."
                        curl -s "$url" > "$arxiu"
                        echo "Dades descarregades a: $arxiu"
                    fi
                fi
            fi
            ;;

        est)
            echo "Calculant estadístiques..."
            awk -F',' '
            BEGIN { nord=0; sud=0; est=0; oest=0; no_ubic=0; no_wdid=0 }
            NR > 1 {
                lat = $9+0; lon = $10+0; wdid = $11
                if (lat > 0) nord++
                if (lat < 0) sud++
                if (lon > 0) est++
                if (lon < 0) oest++
                if (lat == 0 && lon == 0) no_ubic++
                if (wdid == "" || wdid == "NULL") no_wdid++
            }
            END {
                printf "Nord %d Sud %d Est %d Oest %d No ubic %d No WDId %d\n", nord, sud, est, oest, no_ubic, no_wdid
            }
            ' "$DATASET_FILE"
            ;;

        *)
            echo "Opció no vàlida. Torna-ho a intentar."
            ;;
    esac
done
