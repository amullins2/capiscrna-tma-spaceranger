# Receive FTP details, use wget directly on Rocket
wget -r -nH --cut-dirs=2 --no-parent \
     --ftp-user=YOUR_USERNAME \
     --ftp-password=YOUR_PASSWORD \
     ftp://ftp.server.address/path/to/YOUR_SLX_ID/ \
     -P /nobackup/c2056696/rockhpc_capiscrna/temp_download/
