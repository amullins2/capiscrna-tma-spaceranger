# Navigate to a working directory
cd /nobackup/c2056696/rockhpc_capiscrna/

# Download using your actual credentials
wget -r -nH --cut-dirs=2 --no-parent \
     --ftp-user=YOUR_ACTUAL_USERNAME \
     --ftp-password=YOUR_ACTUAL_PASSWORD \
     ftp://actual.ftp.server.address/path/to/YOUR_ACTUAL_SLX_ID/ \
     -P /nobackup/c2056696/rockhpc_capiscrna/temp_download/

# Check download directory
ls -la /nobackup/c2056696/rockhpc_capiscrna/temp_download/

# See total size
du -sh /nobackup/c2056696/rockhpc_capiscrna/temp_download/

# Count total files
find /nobackup/c2056696/rockhpc_capiscrna/temp_download/ -type f | wc -l

# Make script executable and run
chmod +x organize_downloaded_data.sh
./organize_downloaded_data.sh

# Explore the downloaded structure
ls -la /nobackup/c2056696/rockhpc_capiscrna/temp_download/
find /nobackup/c2056696/rockhpc_capiscrna/temp_download/ -type d
find /nobackup/c2056696/rockhpc_capiscrna/temp_download/ -name "*.fastq*" | head -10
find /nobackup/c2056696/rockhpc_capiscrna/temp_download/ -name "*.tif" | head -10

# Example if files are in subdirectories
cp -r /nobackup/c2056696/rockhpc_capiscrna/temp_download/TMA1/* /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA1/
cp -r /nobackup/c2056696/rockhpc_capiscrna/temp_download/TMA2/* /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA2/
cp -r /nobackup/c2056696/rockhpc_capiscrna/temp_download/TMA3/* /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA3/
cp -r /nobackup/c2056696/rockhpc_capiscrna/temp_download/TMA4/* /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA4/

# Example if files have naming patterns
find /nobackup/c2056696/rockhpc_capiscrna/temp_download/ -name "*TMA1*" -exec cp {} /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA1/ \;
find /nobackup/c2056696/rockhpc_capiscrna/temp_download/ -name "*TMA2*" -exec cp {} /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA2/ \;
find /nobackup/c2056696/rockhpc_capiscrna/temp_download/ -name "*TMA3*" -exec cp {} /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA3/ \;
find /nobackup/c2056696/rockhpc_capiscrna/temp_download/ -name "*TMA4*" -exec cp {} /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA4/ \;

# Check data organization
source variables.sh
check_data

# Or run verification manually
for i in {1..4}; do
    echo "=== TMA${i} ==="
    ls -la /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA${i}/
    echo "File count: $(ls -1 /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA${i}/ | wc -l)"
    echo "Size: $(du -sh /nobackup/c2056696/rockhpc_capiscrna/spatial_analysis/data/TMA${i}/ | cut -f1)"
    echo ""
done

# Clean up temporary download directory (after verifying data is organized)
rm -rf /nobackup/c2056696/rockhpc_capiscrna/temp_download/

# Final verification that everything is ready
source variables.sh
verify_setup
check_data

# If everything looks good, launch analysis
./launch_tma.sh

# 1. Download (when you get FTP details)
wget -r -nH --cut-dirs=2 --no-parent --ftp-user=USER --ftp-password=PASS ftp://server/path/SLX_ID/ -P /nobackup/c2056696/rockhpc_capiscrna/temp_download/

# 2. Organize
./organize_downloaded_data.sh

# 3. Verify
source variables.sh && check_data

# 4. Clean up
rm -rf /nobackup/c2056696/rockhpc_capiscrna/temp_download/

# 5. Launch analysis
./launch_tma.sh
