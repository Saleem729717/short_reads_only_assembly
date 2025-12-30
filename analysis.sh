#!/bin/bash
# initialize conda for this script
eval "$(conda shell.bash hook)"

# Script to set up directory structure for short reads only assembly
# Author: Bioinformatics Pipeline
# Date: 2025-12-26

set -e  # Exit on any error

# Define base directory
BASE_DIR="/home/saleem/03_wgs_assembly/short_reads_only_assembly"
SOURCE_DIR="/home/saleem/03_wgs_assembly/hybrid_genome_assembly_guide/01_raw_reads/short_reads"

echo "============================================"
echo "Setting up Short Reads Assembly Directories"
echo "============================================"

# Navigate to base directory
cd "$BASE_DIR"

# Step 1: Create 00_raw_reads directory and copy short reads
echo ""
echo "[Step 1] Creating 00_raw_reads directory and copying short reads..."
mkdir -p 00_raw_reads

if [ -d "$SOURCE_DIR" ]; then
    cp -r "$SOURCE_DIR"/* 00_raw_reads/
    echo "  ✓ Short reads copied successfully from: $SOURCE_DIR"
else
    echo "  ⚠ Warning: Source directory not found: $SOURCE_DIR"
    echo "    Please verify the path and copy files manually."
fi

# Step 2: Create additional workflow directories
echo ""
echo "[Step 2] Creating workflow directories..."

mkdir -p 01_qc_before_processing
echo "  ✓ Created: 01_qc_before_processing"

mkdir -p 02_process_reads
echo "  ✓ Created: 02_process_reads"

echo "  ✓ Created: 03_qc_after_processing"
mkdir -p 03_qc_after_processing

# Summary
echo ""
echo "============================================"
echo "Directory structure created successfully!"
echo "============================================"
echo ""
echo "Created directories:"
ls -la "$BASE_DIR" | grep "^d"
echo ""
echo "Contents of 00_raw_reads:"
ls -lh 00_raw_reads/ 2>/dev/null || echo "  (empty or no files copied)"
echo ""

#using fastqc 
# Change to qc before processing directory
cd "${BASE_DIR}/01_qc_before_processing"
#run fastqc 
conda activate 01_short_read_qc 
mkdir reports
fastqc -o reports --extract --svg -t 20 "${BASE_DIR}/00_raw_reads/"*.fastq.gz 
#run multiqc on fastqc files #expert level 
conda activate 02_multiqc
multiqc -p -o "${BASE_DIR}/01_qc_before_processing/multiqc/fastqc_multiqc" ./ 

# run fastp for read trimming and filtering
cd  "${BASE_DIR}/02_process_reads"
conda activate 01_short_read_qc
fastp \
    -i "${BASE_DIR}/00_raw_reads/SRR8893090_1.fastq.gz" -I "${BASE_DIR}/00_raw_reads/SRR8893090_2.fastq.gz" \
    -o SRR8893090_1.processed.fastq.gz -O SRR8893090_2.processed.fastq.gz \
    -q 25 \
    -h "${BASE_DIR}/03_qc_after_processing/fastp_report.html" \
    -j "${BASE_DIR}/03_qc_after_processing/fastp_report.json" \
    -w 16

# fastqc and multiqc on processed reads
cd "${BASE_DIR}/03_qc_after_processing"
conda activate 01_short_read_qc
mkdir reports_fastqc_processed
fastqc -o reports_fastqc_processed --extract --svg -t 20 "${BASE_DIR}/02_process_reads/"*.processed.fastq.gz
#run multiqc on fastqc files of processed reads
conda activate 02_multiqc
multiqc -p -o "${BASE_DIR}/03_qc_after_processing/multiqc/fastqc_multiqc_processsed" ./
echo ""
echo "quality control and read processing completed"
