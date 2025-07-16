#!/bin/bash
# Organize Downloaded TMA Data Script

# Directories
TEMP_DIR="/nobackup/c2056696/rockhpc_capiscrna/temp_download"
DATA_DIR="/nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data"

echo "=== ORGANIZING DOWNLOADED TMA DATA ==="
echo "Date: $(date)"
echo ""

# Check what was downloaded
echo "Downloaded files and directories:"
ls -la $TEMP_DIR
echo ""

# Find all files in download directory
echo "Total files downloaded:"
find $TEMP_DIR -type f | wc -l
echo ""

# Organize files into TMA directories
echo "Organizing files by TMA..."

for i in {1..4}; do
    echo "Processing TMA${i}..."
    
    # Create TMA directory if it doesn't exist
    mkdir -p $DATA_DIR/TMA${i}
    
    # Look for files with TMA patterns (adjust patterns based on actual naming)
    # Common patterns might be:
    # - Files containing "TMA1", "TMA_1", "tma1", etc.
    # - Files in subdirectories named TMA1, etc.
    # - Files with position identifiers A1, B1, C1, D1 for each TMA
    
    # Try different naming patterns
    find $TEMP_DIR -name "*TMA${i}*" -type f -exec cp {} $DATA_DIR/TMA${i}/ \; 2>/dev/null
    find $TEMP_DIR -name "*TMA_${i}*" -type f -exec cp {} $DATA_DIR/TMA${i}/ \; 2>/dev/null
    find $TEMP_DIR -name "*tma${i}*" -type f -exec cp {} $DATA_DIR/TMA${i}/ \; 2>/dev/null
    find $TEMP_DIR -name "*tma_${i}*" -type f -exec cp {} $DATA_DIR/TMA${i}/ \; 2>/dev/null
    
    # Check if subdirectory exists
    if [ -d "$TEMP_DIR/TMA${i}" ]; then
        cp -r $TEMP_DIR/TMA${i}/* $DATA_DIR/TMA${i}/ 2>/dev/null
    fi
    
    # Count files moved
    file_count=$(ls -1 $DATA_DIR/TMA${i} 2>/dev/null | wc -l)
    echo "  Files organized for TMA${i}: $file_count"
done

echo ""
echo "=== DATA ORGANIZATION SUMMARY ==="
for i in {1..4}; do
    echo "TMA${i}: $(ls -1 $DATA_DIR/TMA${i} 2>/dev/null | wc -l) files"
done

echo ""
echo "If files weren't organized automatically, check the download structure:"
echo "ls -la $TEMP_DIR"
echo "Then manually organize files as needed."
