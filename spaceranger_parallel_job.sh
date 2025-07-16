#!/bin/bash
#SBATCH --account=rockhpc_capiscrna
#SBATCH --job-name=spaceranger_tma
#SBATCH --output=logs/spaceranger_%A_%a.out
#SBATCH --error=logs/spaceranger_%A_%a.err
#SBATCH --array=1-4
#SBATCH --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=1-12:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=a.mullins2@newcastle.ac.uk

# Set up environment - SpaceRanger 4.0.1 in HOME
export PATH="/mnt/nfs/home/c2056696/software/spaceranger-4.0.1:$PATH"

# Define paths
REFERENCE_DIR="/nobackup/c2056696/rockhpc_capiscrna/reference/refdata-gex-GRCm39-2024-A"
DATA_DIR="/nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data"
OUTPUT_DIR="/nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/output"
IMAGE_DIR="/nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data"

# Define samples
SAMPLES=( "TMA1" "TMA2" "TMA3" "TMA4" )
sample=${SAMPLES[$SLURM_ARRAY_TASK_ID - 1]}

echo "Starting SpaceRanger count for $sample at $(date)"
echo "Running on node: $(hostname)"
echo "Job ID: $SLURM_JOB_ID, Array Task: $SLURM_ARRAY_TASK_ID"

# Change to output directory
cd $OUTPUT_DIR

# Run SpaceRanger count for Visium HD
spaceranger count \
  --id=${sample}_count \
  --transcriptome=$REFERENCE_DIR \
  --fastqs=$DATA_DIR/${sample} \
  --slide=V19L01-041 \
  --image=$IMAGE_DIR/${sample}/${sample}_HE_image.tif \
  --slide-file=$IMAGE_DIR/${sample}/${sample}_alignment.json \
  --localcores=$SLURM_CPUS_PER_TASK \
  --localmem=120 \
  --cytassist

echo "Completed SpaceRanger count for $sample at $(date)"
