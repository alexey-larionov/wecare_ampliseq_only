#!/bin/bash

# s01_select_variants.sh
# Started: Alexey Larionov, 26Apr2019
# Last updated: Alexey Larionov, 16Sep2019

# Use:
# ./s01_select_variants.sh > s01_select_variants.log

# Note:
# PCA uses non-filtered variants and genotypes, 
# however, it still works well  

# Select 2,086 variants from ampliseq VCF for joined PCA

# Stop at runtime errors
set -e

# Start message
echo "Select 2,086 variants from ampliseq VCF for PCA plots"
date
echo ""

# --- Files and folders --- #

base_folder="/Users/alexey/Documents/wecare/ampliseq/v05_ampliseq_only"

data_folder="${base_folder}/s12_joined_ampliseq_1kgp_PCA/s03_prepare_wecare_genotypes/data/"
rm -fr "${data_folder}"
mkdir "${data_folder}"

source_ampliseq_nfe_13046_739_vcf="${base_folder}/s04_annotated_vcf/ampliseq_nfe.vcf.gz"
selected_1kgp_2086_2504_vcf="${base_folder}/s12_joined_ampliseq_1kgp_PCA/s02_prepare_1kgp_genotypes/data/s03_1kgp_2086_2504.vcf.gz"
selected_ampliseq_nfe_2086_739_vcf="${data_folder}/s01_ampliseq_nfe_2086_739.vcf.gz"

# Progress report
echo "--- Files and folders ---"
echo ""
echo "source_ampliseq_nfe_13046_739_vcf: ${source_ampliseq_nfe_13046_739_vcf}"
echo "selected_1kgp_2086_2504_vcf: ${selected_1kgp_2086_2504_vcf}"
echo "selected_ampliseq_nfe_2086_739_vcf: ${selected_ampliseq_nfe_2086_739_vcf}"
echo ""
echo "--- Tools ---"
echo ""
bcftools --version
echo ""
echo "--- Progress ---"
echo ""

# --- Count variants in source ampliseq nfe --- #

echo "Number of variants in the input ampliseq-nfe vcf:" 
num_variants=$(bcftools view -H "${source_ampliseq_nfe_13046_739_vcf}" | wc -l)
printf "%'d\n" "${num_variants}"
echo ""

# --- Count samples in source ampliseq nfe --- #
#CHROM POS ID REF ALT QUAL FILTER INFO FORMAT ...

echo "Number of samples in the input ampliseq-nfe vcf:" 
num_fields=$(bcftools view -h "${source_ampliseq_nfe_13046_739_vcf}" | tail -n 1 | wc -w)
num_samples=$(( ${num_fields} - 9 ))
printf "%'d\n" "${num_samples}"
echo ""

# --- Select variants --- #
echo "Selecting variants ..."

bcftools isec \
  --output "${selected_ampliseq_nfe_2086_739_vcf}" \
  --output-type z \
  --nfiles=2 \
  --write 1 \
  "${source_ampliseq_nfe_13046_739_vcf}" \
  "${selected_1kgp_2086_2504_vcf}"

bcftools index -f "${selected_ampliseq_nfe_2086_739_vcf}"

echo ""

# --- Count variants in output --- #
echo "Number of variants in the output:" 
num_variants=$(bcftools view -H "${selected_ampliseq_nfe_2086_739_vcf}" | wc -l)
printf "%'d\n" "${num_variants}"
echo ""

# --- Count samples in output --- #
#CHROM POS ID REF ALT QUAL FILTER INFO FORMAT ...
echo "Number of samples in the output:" 
num_fields=$(bcftools view -h "${selected_ampliseq_nfe_2086_739_vcf}" | tail -n 1 | wc -w)
num_samples=$(( ${num_fields} - 9 ))
printf "%'d\n" "${num_samples}"
echo ""

# Progress report
echo "Done"
date
echo ""
