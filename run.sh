#!/usr/bin/env bash

set -euo pipefail

# Clean up before starting
rm -rf checkpoints
rm -rf data-bin
rm -rf results
rm -rf tmp

# Preprocess data
./preprocess.sh

# Prepare folders
mkdir tmp
mkdir results

# Run models
./train_eval-lstm.sh
./train_eval-lightconv.sh

# Plot performance comparison
./scripts/plot_wer_progression.py \
    results/lstm_wer_test.txt \
    results/lc_wer_test.txt \
    --set test

echo "Cleaning up..."
rm -rf data-bin
rm -rf tmp
rm -rf checkpoints
echo "Complete."
