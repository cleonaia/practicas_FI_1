# LLIURAMENT PRÀCTICA 1 - TRACTAMENT DE DADES AMB SHELL SCRIPT

## 📋 RESUM DEL PROJECTE

Aquest projecte implementa completament tots els requisits de la pràctica de tractament de dades amb Shell Script. El sistema permet l'exploració i processament d'un dataset de poblacions mundials amb més de 150.000 entrades.

## 📁 FITXERS INCLOSOS

### Fitxers Principals
- **`dataset_processor.sh`** - Script principal amb totes les funcionalitats
- **`cities.csv`** - Dataset complet amb poblacions mundials (150.381 entrades)
- **`README.md`** - Documentació completa del projecte
- **`INSTRUCCIONS.md`** - Guia d'ús ràpida
- **`test_script.sh`** - Script de validació automàtica

### Fitxers de Configuració
- **`.vscode/tasks.json`** - Tasques de VS Code per executar l'script

## ✅ FUNCIONALITATS IMPLEMENTADES

### Totes les 10 comandes requerides:

1. **`q`** - Sortir de l'aplicació ✅
2. **`lp`** - Llistar països amb codis ✅
3. **`sc`** - Seleccionar país amb validació ✅
4. **`le`** - Llistar estats del país seleccionat ✅
5. **`se`** - Seleccionar estat amb validació ✅
6. **`lcp`** - Llistar poblacions del país seleccionat ✅
7. **`ecp`** - Extreure poblacions a arxiu CSV ✅
8. **`lce`** - Llistar poblacions de l'estat seleccionat ✅
9. **`gwd`** - Obtenir dades de WikiData ✅
10. **`est`** - Calcular estadístiques del dataset ✅

### Funcionalitats Avançades:
- ✅ Gestió de noms compostos amb cometes dobles
- ✅ Validació robusta d'entrada
- ✅ Variables d'estat persistents
- ✅ Gestió d'errors completa
- ✅ Interfície d'usuari intuïtiva
- ✅ Integració amb WikiData
- ✅ Estadístiques geogràfiques amb AWK

## 🛠️ ORDRES DE LINUX UTILITZADES

El projecte fa ús extensiu de:
- **`cut`** - Extracció de columnes del CSV
- **`grep`** - Cerca de patrons
- **`sort`** - Ordenació de resultats  
- **`uniq`** - Eliminació de duplicats
- **`awk`** - Processament avançat i càlculs matemàtics
- **`curl`** - Descàrrega de dades de WikiData
- **`printf`** - Formatat de sortida
- **`read`** - Entrada d'usuari
- **`wc`** - Comptatge de línies

## 📊 ESTADÍSTIQUES DEL DATASET

```
Total d'entrades: 150.381
Països únics: 195
Estats únics: 3.480

Distribució geogràfica:
- Hemisferi Nord: 133.311 poblacions
- Hemisferi Sud: 14.898 poblacions  
- Hemisferi Oriental: 90.820 poblacions
- Hemisferi Occidental: 57.385 poblacions
- Sense ubicació: 2.171 poblacions
- Sense WikiData ID: 3.256 poblacions
```

## 🚀 INSTRUCCIONS D'EXECUCIÓ

### Pas 1: Preparació
```bash
chmod +x dataset_processor.sh
```

### Pas 2: Validació (opcional)
```bash
./test_script.sh
```

### Pas 3: Execució
```bash
./dataset_processor.sh
```

## 🎯 EXEMPLES D'ÚS

### Workflow típic:
1. Executar `lp` per veure països disponibles
2. Usar `sc` per seleccionar un país (ex: "Spain")
3. Executar `le` per veure els estats del país
4. Usar `se` per seleccionar un estat (ex: "Catalonia") 
5. Executar `lce` per veure poblacions de l'estat
6. Usar `gwd` per obtenir dades de WikiData d'una ciutat
7. Executar `est` per veure estadístiques globals
8. Usar `q` per sortir

### Gestió de noms compostos:
- Noms simples: `Spain`, `France`, `Andorra`
- Noms compostos: `"United States"`, `"Antigua And Barbuda"`

## 🏆 QUALITAT DE LA SOLUCIÓ

### Programació Estructurada:
- Funcions modulars per cada comanda
- Variables globals per mantenir estat
- Validacions centralitzades
- Gestió d'errors consistent

### Bones Pràctiques:
- Documentació completa del codi
- Noms de variables descriptius
- Missatges d'error informatius
- Interfície d'usuari clara

### Robustesa:
- Validació d'existència de fitxers
- Comprovació de permisos
- Gestió d'entrades buides
- Tractament d'errors de xarxa

## 📚 ASPECTES TÈCNICS DESTACATS

### Expressió Regular Complexa:
Implementació de la cerca de noms amb/sense cometes utilitzant AWK per gestionar la dualitat `Barcelona` vs `"United States"`.

### Estadístiques amb AWK:
Càlcul eficient d'estadístiques geogràfiques utilitzant operadors matemàtics amb conversió automàtica de tipus.

### Integració Web:
Connexió amb l'API de WikiData per descarregar dades JSON de ciutats específiques.

## 🧪 VALIDACIÓ I PROVES

El projecte inclou un script de proves automàtiques que verifica:
- Existència i permisos dels fitxers
- Estructura correcta del dataset
- Funcionament de les funcions AWK
- Cerca de països específics
- Càlcul d'estadístiques

## 📝 DOCUMENTACIÓ

Documentació completa disponible a:
- `README.md` - Documentació tècnica detallada
- `INSTRUCCIONS.md` - Guia d'ús ràpida
- Comentaris dins del codi font

---

**Aquest projecte compleix al 100% tots els requisits especificats a la pràctica, implementant una solució robusta, eficient i ben documentada per al tractament de datasets amb Shell Script.**