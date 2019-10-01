#!/bin/bash

# s01_merge_1kg_and_ampliseq_for_PCA.sh
# Started: Alexey Larionov, 26Apr2019
# Last updated: Alexey Larionov, 30Sep2019

# Use:
# ./s01_merge_1kgp_and_ampliseq_genotypes.sh > s01_merge_1kgp_and_ampliseq_genotypes.sh

# Merge 2,504 1kgp and 515 ampliseq-nfe genotypes for PCA

# Stop at runtime errors
set -e

# Start message
echo "Merge 2,504 1kgp and 515 ampliseq-nfe genotypes for PCA"
date
echo ""

# --- Files and folders --- #

base_folder="/Users/alexey/Documents/wecare/ampliseq/v05_ampliseq_only/s12_joined_ampliseq_1kgp_PCA"
data_folder="${base_folder}/s04_merge_1kgp_and_wecare_genotypes/data"
rm -fr "${data_folder}"
mkdir -p "${data_folder}"

kgp_2086_2504_vcf="${base_folder}/s02_prepare_1kgp_genotypes/data/s03_1kgp_2086_2504.vcf.gz"
ampliseq_2086_515_vcf="${base_folder}/s03_prepare_wecare_genotypes/data/s02_ampliseq_2086_515.vcf.gz"

raw_joined_1kgp_wecare_vcf="${data_folder}/raw_joined_1kgp_ampliseq.vcf.gz"
joined_1kgp_wecare_biallelic_snps_vcf="${data_folder}/s01_joined_1kgp_ampliseq_biallelic_snps_2009_3019.vcf.gz"
# 2,009 variants in the output were found in the preliminary runs

# --- Progress report --- #

echo "--- Files and folders ---"
echo ""
echo "kgp_2086_2504_vcf: ${kgp_2086_2504_vcf}"
echo "ampliseq_2086_515_vcf: ${ampliseq_2086_515_vcf}"
echo "joined_1kgp_wecare_biallelic_snps_vcf: ${joined_1kgp_wecare_biallelic_snps_vcf}"
echo ""
echo "--- Tools ---"
echo ""
bcftools --version
echo ""
echo "--- Progress ---"
echo ""

# --- Merge VCFs --- #

echo "Merging VCFs ..."

bcftools merge \
  -m all \
  --force-samples \
  --output-type z \
  --output "${raw_joined_1kgp_wecare_vcf}" \
  "${kgp_2086_2504_vcf}" \
  "${ampliseq_2086_515_vcf}"

bcftools index -f "${raw_joined_1kgp_wecare_vcf}"

echo ""

# Count variants
echo "Number of variants in the raw output:" 
num_variants=$(bcftools view -H "${raw_joined_1kgp_wecare_vcf}" | wc -l)
printf "%'d\n" "${num_variants}"
echo ""

# Count samples
echo "Number of samples in the raw output:" 
num_fields=$(bcftools view -h "${raw_joined_1kgp_wecare_vcf}" | tail -n 1 | wc -w)
num_samples=$(( ${num_fields} - 9 ))
printf "%'d\n" "${num_samples}"
echo "" 

# --- Keep only biallelic SNPs --- #

echo "Keeping only biallelic SNPs ..."

bcftools view \
  --output-type z \
  --output-file "${joined_1kgp_wecare_biallelic_snps_vcf}" \
  --min-alleles 2 \
  --max-alleles 2 \
  --types "snps" \
  "${raw_joined_1kgp_wecare_vcf}" 

bcftools index -f "${joined_1kgp_wecare_biallelic_snps_vcf}"

echo ""

# Count variants
echo "Number of variants in the final output:" 
num_variants=$(bcftools view -H "${joined_1kgp_wecare_biallelic_snps_vcf}" | wc -l)
printf "%'d\n" "${num_variants}"
echo ""

# Count samples
echo "Number of samples in the final output:" 
num_fields=$(bcftools view -h "${joined_1kgp_wecare_biallelic_snps_vcf}" | tail -n 1 | wc -w)
num_samples=$(( ${num_fields} - 9 ))
printf "%'d\n" "${num_samples}"
echo ""

# --- Remove intermediate files --- #

rm -f "${raw_joined_1kgp_wecare_vcf}" "${raw_joined_1kgp_wecare_vcf}.csi"

# Progress report
echo "Done"
date
echo ""
