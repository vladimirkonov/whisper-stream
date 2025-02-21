#!/bin/bash

# Интервал между замерами (секунды) и общая длительность мониторинга (секунды)
INTERVAL=2
DURATION=180

# Инициализация счётчиков и сумм
count=0
sum_cpu=0
sum_gpu=0
sum_gpu_mem=0

END=$((SECONDS + DURATION))

while [ $SECONDS -lt $END ]; do
    # CPU usage
    cpu_line=$(top -bn1 | grep "Cpu(s)")
    cpu_usage=$(echo $cpu_line | awk -F',' '{print $1}' | awk '{print $2}' | sed 's/%us//')
    
    # GPU data: usage GPU & memory usage GPU.
    gpu_line=$(nvidia-smi --query-gpu=utilization.gpu,utilization.memory --format=csv,noheader,nounits)
    gpu_util=$(echo $gpu_line | awk -F',' '{print $1}' | xargs)
    gpu_mem=$(echo $gpu_line | awk -F',' '{print $2}' | xargs)
    
    # Aggregate values
    sum_cpu=$(echo "$sum_cpu + $cpu_usage" | bc)
    sum_gpu=$(echo "$sum_gpu + $gpu_util" | bc)
    sum_gpu_mem=$(echo "$sum_gpu_mem + $gpu_mem" | bc)
    
    count=$((count + 1))
    sleep $INTERVAL
done

# AVG values
avg_cpu=$(echo "scale=2; $sum_cpu / $count" | bc)
avg_gpu=$(echo "scale=2; $sum_gpu / $count" | bc)
avg_gpu_mem=$(echo "scale=2; $sum_gpu_mem / $count" | bc)

echo "-------------------------------------"
echo "Average load for $DURATION seconds (with $count measures):"
printf "%-25s %s\n" "User" "avg value"
printf "%-25s %s\n" "CPU (user)" "$avg_cpu %"
printf "%-25s %s\n" "GPU (load)" "$avg_gpu %"
printf "%-25s %s\n" "GPU (memory)" "$avg_gpu_mem %"
