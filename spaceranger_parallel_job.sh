#!/bin/bash
#SBATCH --partition=bigmem
#SBATCH --job-name=spaceranger_tma
#SBATCH --output=logs/spaceranger_%A_%a.out
#SBATCH --error=logs/spaceranger_%A_%a.err
#SBATCH --array=1-4
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=1-12:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=a.mullins2@newcastle.ac.uk

# Set up environment - SpaceRanger 4.0.1 in HOME (confirmed working from test)
export PATH="/mnt/nfs/home/c2056696/software/spaceranger-4.0.1:$PATH"

# Define paths (confirmed working from test)
REFERENCE_DIR="/nobackup/c2056696/rockhpc_capiscrna/reference/refdata-gex-GRCm39-2024-A"
DATA_DIR="/nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data"
OUTPUT_DIR="/nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/output"
IMAGE_DIR="/nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data"

# Define samples
SAMPLES=( "TMA1" "TMA2" "TMA3" "TMA4" )
sample=${SAMPLES[$SLURM_ARRAY_TASK_ID - 1]}

# Logging and diagnostics
echo "=== SPACERANGER TMA ANALYSIS ==="
echo "Starting SpaceRanger count for $sample at $(date)"
echo "Running on node: $(hostname)"
echo "Job ID: $SLURM_JOB_ID, Array Task: $SLURM_ARRAY_TASK_ID"
echo "Using $SLURM_CPUS_PER_TASK CPUs and 128GB memory"
echo "Partition: $SLURM_JOB_PARTITION"
echo ""

# Verify SpaceRanger is available
echo "SpaceRanger version:"
spaceranger --version
echo ""

# Verify reference genome exists
echo "Reference genome:"
ls -la $REFERENCE_DIR/
echo ""

# Verify input data exists
echo "Input data for $sample:"
ls -la $DATA_DIR/${sample}/
echo ""

# Check available disk space
echo "Available disk space:"
df -h $OUTPUT_DIR
echo ""

# Change to output directory
cd $OUTPUT_DIR

# Run SpaceRanger count for Visium HD with jobmode=slurm
echo "Starting SpaceRanger count at $(date)"
spaceranger count \
  --id=${sample}_count \
  --transcriptome=$REFERENCE_DIR \
  --fastqs=$DATA_DIR/${sample} \
  --slide=V19L01-041 \
  --image=$IMAGE_DIR/${sample}/${sample}_HE_image.tif \
  --slide-file=$IMAGE_DIR/${sample}/${sample}_alignment.json \
  --localcores=$SLURM_CPUS_PER_TASK \
  --localmem=120 \
  --jobmode=slurm \
  --cytassist

# Check if SpaceRanger completed successfully
if [ $? -eq 0 ]; then
    echo "SpaceRanger completed successfully for $sample at $(date)"
    echo "Output directory: $OUTPUT_DIR/${sample}_count"
    
    # Check output directory size
    echo "Output directory size:"
    du -sh $OUTPUT_DIR/${sample}_count
    
    # Verify key output files
    echo "Key output files:"
    ls -la $OUTPUT_DIR/${sample}_count/outs/
    
    # Check if web summary exists
    if [ -f "$OUTPUT_DIR/${sample}_count/outs/web_summary.html" ]; then
        echo "Web summary created successfully"
    else
        echo "Web summary not found"
    fi
    
else
    echo "SpaceRanger failed for $sample at $(date)"
    echo "Check error logs for details"
    exit 1
fi

echo ""
echo "=== ANALYSIS COMPLETE FOR $sample ==="
echo "Completed at $(date)"
