#!/bin/bash

# ============================================================================
# TRACTAMENT DE DADES AMB SHELL SCRIPT
# Script per l'exploració i processament de datasets de poblacions mundials
# ============================================================================

# Variables globals
DATASET_FILE="cities.csv"
SELECTED_COUNTRY=""
SELECTED_STATE=""

# Funcions auxiliars
show_menu() {
    echo ""
    echo "=========================================="
    echo "    MENU PRINCIPAL"
    echo "=========================================="
    echo "q   - Sortir"
    echo "lp  - Llistar països"
    echo "sc  - Seleccionar país"
    echo "le  - Llistar estats del país seleccionat"
    echo "se  - Seleccionar estat"
    echo "lcp - Llistar poblacions del país seleccionat"
    echo "ecp - Extreure poblacions del país seleccionat"
    echo "lce - Llistar poblacions de l'estat seleccionat"
    echo "gwd - Obtenir dades d'una ciutat de WikiData"
    echo "est - Obtenir estadístiques"
    echo "=========================================="
    echo "País seleccionat: ${SELECTED_COUNTRY:-"Cap"}"
    echo "Estat seleccionat: ${SELECTED_STATE:-"Cap"}"
    echo "=========================================="
}

# Verificar existència del dataset
check_dataset() {
    if [ ! -f "$DATASET_FILE" ]; then
        echo "Error: No s'ha trobat el fitxer del dataset '$DATASET_FILE'"
        echo "Si us plau, descarregueu el dataset i anomeneu-lo '$DATASET_FILE'"
        exit 1
    fi
}

# 1. Sortir (q)
exit_program() {
    echo "Sortint de l'aplicació"
    exit 0
}

# 2. Llistar països (lp)
list_countries() {
    echo ""
    echo "country_code    country_name"
    echo "============    ============"
    cut -d',' -f7,8 "$DATASET_FILE" | tail -n +2 | sort -u | while IFS=',' read -r code name; do
        printf "%-15s %s\n" "$code" "$name"
    done
}

# 3. Seleccionar país (sc)
select_country() {
    echo ""
    echo "Introduïu el nom del país:"
    read -r country_input
    
    # Si no s'introdueix res, mantenir el país actual
    if [ -z "$country_input" ]; then
        echo "País mantingut: ${SELECTED_COUNTRY:-"Cap"}"
        return
    fi
    
    # Buscar el país al dataset utilitzant l'expressió regular proporcionada
    # Busquem tant noms entre cometes com noms simples
    country_code=""
    
    # Primer intentem buscar amb el nom exacte (amb o sense cometes)
    if [[ "$country_input" == \"*\" ]]; then
        # Si l'usuari ha introduït cometes, busquem exactament així
        country_code=$(awk -F',' -v country="$country_input" '$8 == country {print $7; exit}' "$DATASET_FILE")
    else
        # Si no té cometes, busquem ambdues formes
        country_code=$(awk -F',' -v country="$country_input" '$8 == country || $8 == "\"" country "\"" {print $7; exit}' "$DATASET_FILE")
    fi
    
    if [ -z "$country_code" ]; then
        SELECTED_COUNTRY="XX"
        SELECTED_STATE=""
        echo "País no trobat. Variable assignada a XX"
    else
        SELECTED_COUNTRY="$country_code"
        SELECTED_STATE=""
        echo "País seleccionat: $country_input ($country_code)"
    fi
}

# 4. Llistar estats del país seleccionat (le)
list_states() {
    if [ -z "$SELECTED_COUNTRY" ] || [ "$SELECTED_COUNTRY" = "XX" ]; then
        echo "Error: Primer heu de seleccionar un país vàlid"
        return
    fi
    
    echo ""
    echo "Estats/Províncies del país seleccionat:"
    echo "======================================"
    awk -F',' -v country="$SELECTED_COUNTRY" '$7 == country {print $4 "," $5}' "$DATASET_FILE" | sort -u | while IFS=',' read -r code name; do
        printf "%-10s %s\n" "$code" "$name"
    done
}

# 5. Seleccionar estat (se)
select_state() {
    if [ -z "$SELECTED_COUNTRY" ] || [ "$SELECTED_COUNTRY" = "XX" ]; then
        echo "Error: Primer heu de seleccionar un país vàlid"
        return
    fi
    
    echo ""
    echo "Introduïu el nom de l'estat:"
    read -r state_input
    
    # Si no s'introdueix res, mantenir l'estat actual
    if [ -z "$state_input" ]; then
        echo "Estat mantingut: ${SELECTED_STATE:-"Cap"}"
        return
    fi
    
    # Buscar l'estat al país seleccionat
    state_code=""
    
    if [[ "$state_input" == \"*\" ]]; then
        # Si l'usuari ha introduït cometes, busquem exactament així
        state_code=$(awk -F',' -v country="$SELECTED_COUNTRY" -v state="$state_input" '$7 == country && $5 == state {print $4; exit}' "$DATASET_FILE")
    else
        # Si no té cometes, busquem ambdues formes
        state_code=$(awk -F',' -v country="$SELECTED_COUNTRY" -v state="$state_input" '$7 == country && ($5 == state || $5 == "\"" state "\"") {print $4; exit}' "$DATASET_FILE")
    fi
    
    if [ -z "$state_code" ]; then
        SELECTED_STATE="XX"
        echo "Estat no trobat en el país seleccionat. Variable assignada a XX"
    else
        SELECTED_STATE="$state_code"
        echo "Estat seleccionat: $state_input ($state_code)"
    fi
}

# 6. Llistar poblacions del país seleccionat (lcp)
list_cities_country() {
    if [ -z "$SELECTED_COUNTRY" ] || [ "$SELECTED_COUNTRY" = "XX" ]; then
        echo "Error: Primer heu de seleccionar un país vàlid"
        return
    fi
    
    echo ""
    echo "Poblacions del país seleccionat:"
    echo "==============================="
    awk -F',' -v country="$SELECTED_COUNTRY" '$7 == country {print $2 "," $11}' "$DATASET_FILE" | sort -u | while IFS=',' read -r city wikidata; do
        printf "%-30s %s\n" "$city" "$wikidata"
    done
}

# 7. Extreure poblacions del país seleccionat (ecp)
extract_cities_country() {
    if [ -z "$SELECTED_COUNTRY" ] || [ "$SELECTED_COUNTRY" = "XX" ]; then
        echo "Error: Primer heu de seleccionar un país vàlid"
        return
    fi
    
    output_file="${SELECTED_COUNTRY}.csv"
    awk -F',' -v country="$SELECTED_COUNTRY" '$7 == country {print $2 "," $11}' "$DATASET_FILE" | sort -u > "$output_file"
    
    echo "Poblacions extretes a l'arxiu: $output_file"
    echo "Total de poblacions: $(wc -l < "$output_file")"
}

# 8. Llistar poblacions de l'estat seleccionat (lce)
list_cities_state() {
    if [ -z "$SELECTED_COUNTRY" ] || [ "$SELECTED_COUNTRY" = "XX" ]; then
        echo "Error: Primer heu de seleccionar un país vàlid"
        return
    fi
    
    if [ -z "$SELECTED_STATE" ] || [ "$SELECTED_STATE" = "XX" ]; then
        echo "Error: Primer heu de seleccionar un estat vàlid"
        return
    fi
    
    echo ""
    echo "Poblacions de l'estat seleccionat:"
    echo "=================================="
    awk -F',' -v country="$SELECTED_COUNTRY" -v state="$SELECTED_STATE" '$7 == country && $4 == state {print $2 "," $11}' "$DATASET_FILE" | sort -u | while IFS=',' read -r city wikidata; do
        printf "%-30s %s\n" "$city" "$wikidata"
    done
}

# 9. Obtenir dades d'una ciutat de WikiData (gwd)
get_wikidata() {
    if [ -z "$SELECTED_COUNTRY" ] || [ "$SELECTED_COUNTRY" = "XX" ]; then
        echo "Error: Primer heu de seleccionar un país vàlid"
        return
    fi
    
    if [ -z "$SELECTED_STATE" ] || [ "$SELECTED_STATE" = "XX" ]; then
        echo "Error: Primer heu de seleccionar un estat vàlid"
        return
    fi
    
    echo ""
    echo "Introduïu el nom de la població:"
    read -r city_input
    
    if [ -z "$city_input" ]; then
        echo "Error: Heu d'introduir un nom de població"
        return
    fi
    
    # Buscar el wikiDataId de la ciutat
    wikidata_id=""
    
    if [[ "$city_input" == \"*\" ]]; then
        # Si l'usuari ha introduït cometes, busquem exactament així
        wikidata_id=$(awk -F',' -v country="$SELECTED_COUNTRY" -v state="$SELECTED_STATE" -v city="$city_input" '$7 == country && $4 == state && $2 == city {print $11; exit}' "$DATASET_FILE")
    else
        # Si no té cometes, busquem ambdues formes
        wikidata_id=$(awk -F',' -v country="$SELECTED_COUNTRY" -v state="$SELECTED_STATE" -v city="$city_input" '$7 == country && $4 == state && ($2 == city || $2 == "\"" city "\"") {print $11; exit}' "$DATASET_FILE")
    fi
    
    if [ -z "$wikidata_id" ] || [ "$wikidata_id" = "" ]; then
        echo "Error: Població no trobada o sense wikiDataId"
        return
    fi
    
    # Descarregar les dades de WikiData
    url="https://www.wikidata.org/wiki/Special:EntityData/${wikidata_id}.json"
    output_file="${wikidata_id}.json"
    
    echo "Descarregant dades de WikiData per a $city_input ($wikidata_id)..."
    
    if command -v curl >/dev/null 2>&1; then
        if curl -s -o "$output_file" "$url"; then
            echo "Dades descarregades correctament a: $output_file"
        else
            echo "Error: No s'han pogut descarregar les dades"
        fi
    else
        echo "Error: curl no està disponible al sistema"
    fi
}

# 10. Obtenir estadístiques (est)
get_statistics() {
    echo ""
    echo "Calculant estadístiques del dataset..."
    
    awk -F',' '
    BEGIN {
        nord = 0; sud = 0; est = 0; oest = 0; no_ubic = 0; no_wdid = 0
    }
    NR > 1 {
        lat = $9; lon = $10; wdid = $11
        
        # Comptar segons latitud
        if (lat + 0 > 0) nord++
        else if (lat + 0 < 0) sud++
        
        # Comptar segons longitud
        if (lon + 0 > 0) est++
        else if (lon + 0 < 0) oest++
        
        # Sense ubicació (lat i lon = 0)
        if (lat + 0 == 0 && lon + 0 == 0) no_ubic++
        
        # Sense wikidataId
        if (wdid == "" || wdid == "NULL") no_wdid++
    }
    END {
        printf "Nord %d Sud %d Est %d Oest %d No ubic %d No WDId %d\n", nord, sud, est, oest, no_ubic, no_wdid
    }
    ' "$DATASET_FILE"
}

# Funció principal
main() {
    echo "============================================================================"
    echo "  TRACTAMENT DE DADES AMB SHELL SCRIPT"
    echo "  Sistema d'exploració de datasets de poblacions mundials"
    echo "============================================================================"
    
    check_dataset
    
    while true; do
        show_menu
        echo ""
        echo -n "Introduïu una ordre: "
        read -r command
        
        case "$command" in
            "q")
                exit_program
                ;;
            "lp")
                list_countries
                ;;
            "sc")
                select_country
                ;;
            "le")
                list_states
                ;;
            "se")
                select_state
                ;;
            "lcp")
                list_cities_country
                ;;
            "ecp")
                extract_cities_country
                ;;
            "lce")
                list_cities_state
                ;;
            "gwd")
                get_wikidata
                ;;
            "est")
                get_statistics
                ;;
            *)
                echo "Ordre no reconeguda. Torneu-ho a provar."
                ;;
        esac
        
        echo ""
        echo "Premeu Enter per continuar..."
        read -r
    done
}

# Executar el programa principal
main