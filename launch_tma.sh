#!/bin/bash
# TMA Analysis Launcher Script
# This script submits the TMA analysis jobs

# Source variables
source variables.sh

# Function to check prerequisites
check_prerequisites() {
    echo "=== CHECKING PREREQUISITES ==="
    
    # Verify setup
    verify_setup
    
    # Check data availability
    check_data
    
    # Check if previous analysis exists
    echo ""
    echo "=== CHECKING FOR PREVIOUS ANALYSIS ==="
    for sample in "${SAMPLES[@]}"; do
        output_dir="$OUTPUT_DIR/${sample}_count"
        if [ -d "$output_dir" ]; then
            echo "   Previous analysis found for $sample: $output_dir"
            echo "   Consider backing up or removing before rerunning"
        else
            echo "✅ No previous analysis for $sample"
        fi
    done
    
    # Check disk space
    echo ""
    echo "=== CHECKING DISK SPACE ==="
    df -h $OUTPUT_DIR
    
    available_space=$(df $OUTPUT_DIR | tail -1 | awk '{print $4}')
    if [ $available_space -lt 1000000 ]; then  # Less than ~1GB
        echo "Warning: Low disk space available"
    else
        echo "✅ Sufficient disk space available"
    fi
}

# Function to submit analysis
submit_analysis() {
    echo ""
    echo "=== SUBMITTING TMA ANALYSIS ==="
    
    # Submit the array job
    job_id=$(sbatch spaceranger_parallel_job.sh | awk '{print $4}')
    
    if [ $? -eq 0 ]; then
        echo "✅ Jobs submitted successfully"
        echo "Job ID: $job_id"
        echo "Array jobs: ${job_id}_1, ${job_id}_2, ${job_id}_3, ${job_id}_4"
        echo ""
        
        # Create monitoring script
        create_monitoring_script $job_id
        
        echo "Monitoring commands:"
        echo "  Check status: squeue -u $(whoami)"
        echo "  Watch jobs: watch -n 30 'squeue -u $(whoami)'"
        echo "  Check logs: tail -f logs/spaceranger_${job_id}_*.out"
        echo "  Run monitor: ./monitor_tma.sh $job_id"
        
    else
        echo "❌ Job submission failed"
        exit 1
    fi
}

# Function to create monitoring script
create_monitoring_script() {
    local job_id=$1
    
    cat > monitor_tma.sh << EOF
#!/bin/bash
# TMA Analysis Monitoring Script
# Usage: ./monitor_tma.sh [job_id]

JOB_ID=\${1:-$job_id}

echo "=== TMA ANALYSIS MONITORING ==="
echo "Job ID: \$JOB_ID"
echo "Date: \$(date)"
echo ""

# Show job status
echo "Job status:"
squeue -u \$(whoami) -o "%.10i %.20j %.8t %.10M %.10l %.6D %R"
echo ""

# Check logs
echo "Latest log entries:"
for i in {1..4}; do
    log_file="logs/spaceranger_\${JOB_ID}_\$i.out"
    if [ -f "\$log_file" ]; then
        echo "=== TMA\$i Log ==="
        tail -5 "\$log_file"
        echo ""
    fi
done

# Check outputs
echo "Output directories:"
ls -la $OUTPUT_DIR/
echo ""

# Check disk usage
echo "Disk usage:"
du -sh $OUTPUT_DIR/*/
EOF

    chmod +x monitor_tma.sh
    echo "Created monitoring script: monitor_tma.sh"
}

# Main execution
main() {
    echo "=== TMA ANALYSIS LAUNCHER ==="
    echo "Date: $(date)"
    echo "User: $(whoami)"
    echo "Working directory: $(pwd)"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Ask for confirmation
    echo ""
    read -p "Do you want to submit the TMA analysis jobs? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        submit_analysis
    else
        echo "Analysis submission cancelled"
        exit 0
    fi
}

# Run main function
main
