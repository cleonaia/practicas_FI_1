# Instruccions d'Execució

## Pas 1: Preparació
```bash
chmod +x dataset_processor.sh
```

## Pas 2: Execució
```bash
./dataset_processor.sh
```

## Exemples de Comandaments

### Llistar països
```
Introduïu una ordre: lp
```

### Seleccionar un país (España)
```
Introduïu una ordre: sc
Introduïu el nom del país: Spain
```

### Seleccionar un país amb espais (Estats Units)
```
Introduïu una ordre: sc
Introduïu el nom del país: "United States"
```

### Llistar estats del país seleccionat
```
Introduïu una ordre: le
```

### Seleccionar un estat
```
Introduïu una ordre: se
Introduïu el nom de l'estat: Catalonia
```

### Veure estadístiques
```
Introduïu una ordre: est
```

### Sortir
```
Introduïu una ordre: q
```

## Notes Importantes

1. **Noms amb espais**: Utilitzeu cometes dobles `"nom compost"`
2. **Sensibilitat**: Els noms són sensibles a majúscules/minúscules
3. **Dataset**: El fitxer `cities.csv` ha d'estar al mateix directori
4. **Internet**: La funcionalitat WikiData (gwd) requereix connexió a internet

## Funcions Implementades

- ✅ q - Sortir
- ✅ lp - Llistar països  
- ✅ sc - Seleccionar país
- ✅ le - Llistar estats
- ✅ se - Seleccionar estat
- ✅ lcp - Llistar ciutats del país
- ✅ ecp - Extreure ciutats del país
- ✅ lce - Llistar ciutats de l'estat
- ✅ gwd - Obtenir dades WikiData
- ✅ est - Estadístiques del dataset