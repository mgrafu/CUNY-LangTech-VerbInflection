#!/usr/bin/env bash

set -euo pipefail

readonly TEST_WER=results/lc_wer_test.txt

touch "${TEST_WER}"

echo "Training LightConv model..."
fairseq-train \
    data-bin \
    --source-lang spa.inf --target-lang spa.pres \
    --seed 42 -a lightconv --max-epoch 100 \
    --clip-norm 0 --dropout 0.3 --attention-dropout 0.1 --weight-dropout 0.1 \
    --weight-decay 0.0001 --optimizer adam --adam-betas '(0.9,0.98)' \
    --lr 0.0005 --lr-scheduler inverse_sqrt --warmup-init-lr '1e-07' \
    --warmup-updates 100 --ddp-backend 'no_c10d' --batch-size 256 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --encoder-glu 0 --decoder-glu 0 \

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
        results/lc_correct_test.tsv \
        results/lc_incorrect_test.tsv \
        >> "${TEST_WER}";
done

rm -rf checkpoints
