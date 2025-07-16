#!/bin/bash
# TMA Analysis Variables
# Source this file to set up environment variables

# Project identification
PROJECT_NAME="rockhpc_capiscrna"
RUN_ID="TMA_mouse_pancreas_2025"

# SpaceRanger setup (confirmed working from test)
SPACERANGER_DIR="/mnt/nfs/home/c2056696/software/spaceranger-4.0.1"
export PATH=$SPACERANGER_DIR:$PATH

# Data directories (confirmed working from test)
BASE_DIR="/nobackup/c2056696/rockhpc_capiscrna"
REFERENCE_DIR="$BASE_DIR/reference/refdata-gex-GRCm39-2024-A"
DATA_DIR="$BASE_DIR/spatial_analysis/data"
OUTPUT_DIR="$BASE_DIR/spatial_analysis/output"
IMAGE_DIR="$BASE_DIR/spatial_analysis/data"
SCRIPT_DIR="$BASE_DIR/shared_scripts/capiscrna-tma-spaceranger"

# Slide information (update with your actual slide ID)
SLIDE="V19L01-041"

# Sample information
SAMPLES=("TMA1" "TMA2" "TMA3" "TMA4")

# Slurm job configuration (confirmed working from test)
PARTITION="bigmem"
CPUS_PER_TASK=16
MEMORY="128G"
TIME_LIMIT="1-12:00:00"

# Email for notifications
EMAIL="a.mullins2@newcastle.ac.uk"

# Function to verify setup
verify_setup() {
    echo "=== VERIFYING TMA ANALYSIS SETUP ==="
    echo "SpaceRanger: $(which spaceranger)"
    echo "Reference: $REFERENCE_DIR"
    echo "Data directory: $DATA_DIR"
    echo "Output directory: $OUTPUT_DIR"
    echo "Slide: $SLIDE"
    echo "Samples: ${SAMPLES[@]}"
    echo "Partition: $PARTITION"
    echo ""
    
    # Check if directories exist
    for dir in "$REFERENCE_DIR" "$DATA_DIR" "$OUTPUT_DIR"; do
        if [ -d "$dir" ]; then
            echo "✅ $dir exists"
        else
            echo "❌ $dir does not exist"
        fi
    done
    
    # Check if SpaceRanger is available
    if command -v spaceranger &> /dev/null; then
        echo "✅ SpaceRanger is available"
        spaceranger --version
    else
        echo "❌ SpaceRanger not found"
    fi
}

# Function to check data availability
check_data() {
    echo "=== CHECKING TMA DATA AVAILABILITY ==="
    for sample in "${SAMPLES[@]}"; do
        sample_dir="$DATA_DIR/$sample"
        if [ -d "$sample_dir" ]; then
            file_count=$(ls -1 "$sample_dir" | wc -l)
            echo "✅ $sample: $file_count files"
            
            # Check for expected files
            if [ -f "$sample_dir/${sample}_HE_image.tif" ]; then
                echo "  ✅ H&E image found"
            else
                echo "  ❌ H&E image not found"
            fi
            
            if [ -f "$sample_dir/${sample}_alignment.json" ]; then
                echo " Alignment file found"
            else
                echo " Alignment file not found"
            fi
        else
            echo "$sample: Directory not found"
        fi
    done
}

# Export all variables
export PROJECT_NAME RUN_ID SPACERANGER_DIR REFERENCE_DIR DATA_DIR OUTPUT_DIR IMAGE_DIR SCRIPT_DIR
export SLIDE SAMPLES PARTITION CPUS_PER_TASK MEMORY TIME_LIMIT EMAIL
