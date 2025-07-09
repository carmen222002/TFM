#!/bin/bash

# DRAGEN Enrichment 4.3.13
####################################################################################
## SCRIPT DEFINITIVO CON FLAGS DE BASESPACE CLI PARA CTDNA ##
####################################################################################

# Lista de SAMPLE_IDs
SAMPLE_IDS=() # Añadir una lista de los IDs de tus BioSamples

for SAMPLE_ID in "${SAMPLE_IDS[@]}"
do
  echo "Procesando muestra: ID: $SAMPLE_ID"

  bs launch application \
    -n "DRAGEN Enrichment" \
    --app-version "4.3.13" \
    -o project-id:38532494 \
    -l "${SAMPLE_ID}_DRAGEN-Enrichment-4.3_TFM-Carmen_ctDNA" \
    -o vc-type:1 \
    -o input_list.sample-id:$SAMPLE_ID \
    -o ht-ref:hg38-alt_masked.graph.cnv.hla.rna_v4 \
    -o fixed-bed:custom \
    -o target_bed_id:"2098588187" \
    -o systematic-noise-filter:0 \
    -o dupmark_checkbox:0 \
    -o bin-memory:40 \
    -o umi_checkbox:1 \
    -o umi_vc:ctdna \
    -o umi_library_type:nonrandom-duplex \
    -o umi_nonrandom_whitelist:2099203839 \
    -o umi_min_supporting_reads:2 \
    -o cnv-as-calling-checkbox:none \
    -o cnv_gcbias_checkbox:0 \
    -o vcf_or_gvcf:VCF \
    -o vc-target-bed-padding:10 \
    -o high-coverage:1 \
    -o vc-hotspot:builtin \
    -o vc-systematic-noise-method:mean \
    -o multiallelic-filter:1 \
    -o qc_somatic_contam_checkbox:1 \
    -o af-filtering:1 \
    -o vc-af-call-threshold:0.05 \
    -o vc-af-filter-threshold:0.1 \
    -o sq-filtering:1 \
    -o vc-sq-call-threshold:0.1 \
    -o vc-sq-filter-threshold:3 \
    -o phased-variants:1 \
    -o phased-variants-n:15 \
    -o nirvana:1 \
    -o maf:ensembl \
    -o enable-germline-tagging:1 \
    -o tmb:1 \
    -o input_list.sex:unknown

  echo "Lanzamiento completado para muestra: $SAMPLE_ID"
done
