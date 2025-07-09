Este repositorio contiene scripts para el análisis de mutaciones somáticas a partir de datos de ADN circulante tumoral (ctDNA), combinando herramientas de la plataforma **BaseSpace** (DRAGEN Enrichment) y procesamiento/análisis posterior en **R** con el paquete `maftools`.

---

## 📁 Estructura del proyecto
.
├── scripts/
│   ├── lanzador\_dragen\_ctdna.sh      # Script para lanzar trabajos en BaseSpace (Bash)
│   └── filtrar\_analizar\_maf.R        # Procesamiento, filtrado y análisis de archivos MAF (R)
├── README.md


---

## ⚙️ Requisitos

### 1. Para el script de Bash (`script_ctdna_dragen-enrichment-4.3.sh`)
- Acceso a [BaseSpace CLI](https://developer.basespace.illumina.com/docs/content/documentation/cli/cli-overview) correctamente configurado.
- Permisos sobre el proyecto BaseSpace donde se lanzarán los análisis.
- Versiones recomendadas:
  - DRAGEN Enrichment v4.3.13
  - Referencia: `hg38-alt_masked.graph.cnv.hla.rna_v4`

### 2. Para el script en R (`plots_maf.R`)
- R >= 4.0
- Paquetes requeridos:
  - `maftools`
  - `stringr`
  - `dplyr`
  - `tools`

Instalación de dependencias en R:
```r
install.packages(c("dplyr", "stringr", "tools"))
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("maftools")
````

---

## 🚀 Uso

### 1. Lanzamiento de análisis DRAGEN Enrichment (Bash)

Edita el archivo `script_ctdna_dragen-enrichment-4.3.sh`:

* Añade tus `SAMPLE_IDs` en la línea:

```bash
SAMPLE_IDS=(ID_1 ID_2 ID_3 ...)
```

* Verifica que el `project-id` y `target_bed_id` corresponden a tu entorno BaseSpace.

Lanza el script:

```bash
bash scripts/script_ctdna_dragen-enrichment-4.3.sh
```

Este paso genera archivos `.maf` para cada muestra, que serán descargables desde BaseSpace.

---

### 2. Procesamiento y análisis de MAFs (R)

Edita el script `plots_maf.R`:

* Modifica la línea `carpeta_mafs <- ""` con la ruta local donde tengas los archivos `.maf` descargados.

Ejecuta el script en R:

```r
source("scripts/filtrar_analizar_maf.R")
```

Esto hará lo siguiente:

* Leer múltiples archivos `.maf`
* Aplicar filtros estrictos de calidad y anotación
* Estandarizar nomenclatura para uso con `maftools`
* Combinar todos los archivos en un único objeto MAF
* Generar múltiples visualizaciones:

  * Resumen de mutaciones
  * Oncoplot
  * Posiciones mutacionales (lollipop)
  * Frecuencia alélica variante (VAF)
  * Interacciones entre genes mutados

---

## 📌 Notas importantes

* El filtrado considera alelos raros (AF < 0.01), profundidad mínima (≥10 lecturas) y transcripciones canónicas (`BIOTYPE == "mRNA"` y `CANONICAL == "YES"`).
* Se excluyen genes como IG y ENSG\* para evitar regiones poco informativas o anotaciones automáticas.

---

## 🧬 Contexto

Este pipeline fue diseñado como parte de un trabajo de investigación en ctDNA utilizando paneles dirigidos con UMIs (non-random duplex), y está adaptado a entornos clínicos y de investigación biomédica.

---

## 📄 Licencia

MIT License. Libre para modificar y distribuir con atribución.

---

## ✍️ Autor

**Carmen \[Tu Apellido]**
TFM - Bioinformática

---
