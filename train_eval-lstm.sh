#!/usr/bin/env bash

set -euo pipefail

readonly TEST_WER=results/lstm_wer_test.txt
touch "${TEST_WER}"

echo "Training LSTM model..."
fairseq-train \
    data-bin \
    --source-lang spa.inf --target-lang spa.pres \
    --seed 42 --arch lstm --max-epoch 100 \
    --dropout .2 --clip-norm 1 --batch-size 256 --optimizer adam \
    --encoder-embed-dim 256 --decoder-embed-dim 256 \
    --encoder-hidden-size=512 --decoder-hidden-size=512 \
    --encoder-bidirectional --decoder-out-embed-dim 256 --lr .001 \
    --criterion label_smoothed_cross_entropy --label-smoothing .1

readonly TEST_PRED=tmp/test-predictions.txt

mv checkpoints/checkpoint_last.pt checkpoints/_checkpoint_last.pt

for FILE in checkpoints/checkpoint*.pt;
do
    echo "Computing WER on Test set predictions..."
    fairseq-generate \
        data-bin \
        --source-lang spa.inf --target-lang spa.pres \
        --path "${FILE}" --gen-subset test --beam 8 \
        > "${TEST_PRED}"
    ./scripts/compute_wer.py "${TEST_PRED}" \
        results/lstm_correct_test.tsv \
        results/lstm_incorrect_test.tsv \
        >> "${TEST_WER}";
done

rm -rf checkpoints
