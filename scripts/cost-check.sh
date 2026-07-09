#!/bin/bash
# Quick cost check script

echo "💰 AWS Cost Check"
echo "================="

# Current month estimate
aws ce get-cost-and-usage     --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d)     --granularity MONTHLY     --metrics BlendedCost     --query 'ResultsByTime[0].Total.BlendedCost.[Amount,Unit]'     --output table

echo ""
echo "Top services by cost:"
aws ce get-cost-and-usage     --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d)     --granularity MONTHLY     --metrics BlendedCost     --group-by Type=DIMENSION,Key=SERVICE     --query 'ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount!=`0`].[Keys[0],Metrics.BlendedCost.Amount]'     --output table | head -20
