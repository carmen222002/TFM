
# Importar librerias

library(maftools)
library(stringr)
library(dplyr)
library(tools)


###########################################
##### LEER, FILTRAR Y COMBINAR ############
###########################################

# Función para leer, filtrar y traducir .maf

leer_filtrar_maf <- function(path) {
  df <- read.delim(path, comment.char = "#", stringsAsFactors = FALSE)
  
  # Filtro 1: solo mutaciones con FILTER == PASS
  df <- df %>% filter(FILTER == "PASS")
  
  # Filtro 2: EUR_MAF < 0.1 o igual a "."
  df <- df %>% filter(EUR_MAF == "." | as.numeric(EUR_MAF) < 0.01)
  
  # Filtro 3: ExAC_AF_NFE < 0.1 o igual a "."
  df <- df %>% filter(ExAC_AF_NFE == "." | as.numeric(ExAC_AF_NFE) < 0.01)
  
  # Filtro 4: Hugo_Symbol no empieza por "IG"
  df <- df %>% filter(!startsWith(Hugo_Symbol, "IG"))
  
  # Filtro 5: Quitar clasificaciones de Variant_Classification no deseadas
  undesired_classifications <- c(
    "intron_variant",
    "3_prime_UTR_variant",
    "upstream_gene_variant",
    "non_coding_transcript_exon_variant",
    "5_prime_UTR_variant",
    ".",
    "downstream_gene_variant"
  )
  df <- df %>% filter(!Variant_Classification %in% undesired_classifications)
  
  # Estandarizar
  df <- df %>% 
    mutate (
      Variant_Classification = case_when(
        Variant_Classification == "missense_variant" ~ "Missense_Mutation",
        Variant_Classification == "stop_gained" ~ "Nonsense_Mutation",
        Variant_Classification %in% c("splice_acceptor_variant", "splice_donor_variant", "splice_region_variant") ~ "Splice_Site",
        Variant_Classification == "inframe_deletion" ~ "In_Frame_Del",
        Variant_Classification == "inframe_insertion" ~ "In_Frame_Ins",
        Variant_Classification == "stop_lost" ~ "Nonstop_Mutation",   # mutacion afecta a el codon de stop
        Variant_Classification %in% c("start_lost", "start_retained_variant") ~ "Translation_Start_Site",  # mutacion afecta a el codon de inicio
        Variant_Classification == "frameshift_variant" & Variant_Type == "insertion" ~ "Frame_Shift_Ins",
        Variant_Classification == "frameshift_variant" & Variant_Type == "deletion" ~ "Frame_Shift_Del",
        TRUE ~ Variant_Classification
      ),
      Variant_Type = case_when(
        Variant_Type == "SNV" ~ "SNP",
        Variant_Type == "deletion" ~ "DEL",
        Variant_Type == "insertion" ~ "INS",
        TRUE ~ Variant_Type
      )
    )

  
  return(df)
}


# Ruta a tus archivos .maf
carpeta_mafs <- "" # Añadir el directorio donde se encuentran todos los archivos MAF
archivos <- list.files(path = carpeta_mafs, pattern = "\\.maf$", full.names = TRUE)

# Filtrar cada archivo .maf
maf_dfs <- lapply(archivos, leer_filtrar_maf)

# Combinar todos en un solo data.frame 
maf_df_filtrado <- bind_rows(maf_dfs) %>%
  # # Corrección manual para marcar como canónica una mutación concreta de CTNND2
  mutate(
    CANONICAL1 = ifelse(Hugo_Symbol == "CTNND2" & Variant_Classification == "In_Frame_Del" & CANONICAL == ".",
                        "YES", CANONICAL)
  ) %>%
  
  # Filtrar para quedarse con transcripciones codificantes (mRNA)
  filter(BIOTYPE == "mRNA") %>%
  
  # Seleccionar solo aquellas anotadas como transcripciones canónicas
  filter(CANONICAL1 == "YES")


# Agrupar por mutación (HGVSc) y contar cuántas veces aparece cada una
maf_df_mut <- maf_df_filtrado %>%
  group_by(HGVSc) %>%
  summarise(count = n()) %>%
  ungroup()


# Unir la información de recuento al data frame original y eliminar las mutaciones que aparecen 3 o más veces
maf_df_filtrado <- maf_df_filtrado %>%
  left_join(maf_df_mut) %>%
  filter(count < 3)

# Quitar los genes que empiecen por ENSG
maf_df_filtrado <- maf_df_filtrado %>%
  filter(!str_starts(Hugo_Symbol, "ENSG"))

# Filtar por el número de lecturas
maf_df_filtrado <- maf_df_filtrado %>% 
  filter(Total_Depth >= 10)


# Crear objeto MAF final
maf <- read.maf(
  maf = maf_df_filtrado
)




###########################################
############## GRAFICAR ###################
###########################################

# Resumen númerico y gráfico de la cohorte
plotmafSummary(maf = maf, rmOutlier = TRUE, addStat = 'median', dashboard = TRUE, titvRaw = FALSE)
par(mfrow = c(1,1))

#----------------------------------------------------

# Oncoplot
# Calcular altura dinámica en función del número de genes
num_genes <- nrow(getGeneSummary(maf))
altura <- max(7, num_genes * 0.25)  # por ejemplo: 0.25 pulgadas por gen

oncoplot(maf = maf, top = num_genes)

#----------------------------------------------------

# Posición de las mutaciones en el gen más mutado
lollipopPlot(maf = maf, gene = 'CREBBP')

#----------------------------------------------------

# VAF
plotVaf(maf = maf, vafCol = 'Variant_Frequencies')
par(mfrow = c(1,1))

#----------------------------------------------------

# Interacciones significativas entre mutaciones 
somaticInteractions(maf = maf,
                    top = 20,
                    pvalue = c(0.05, 0.1))







