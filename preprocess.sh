#!/usr/bin/env bash

set -euo pipefail

readonly INPUT=data/spa_clean.tsv
readonly TRAIN=tmp/spa_train.tsv
readonly DEV=tmp/spa_dev.tsv
readonly TEST=tmp/spa_test.tsv

echo "Splitting train + dev + test samples..."
mkdir tmp
./scripts/split.py \
    --seed 42 \
    --input_path "${INPUT}" \
    --train_path "${TRAIN}" \
    --dev_path "${DEV}" \
    --test_path "${TEST}"

echo "Reformatting samples for fairseq..."
./scripts/format_for_preprocessing.py "${TRAIN}" "${DEV}" "${TEST}"

echo "Preprocessing..."
fairseq-preprocess \
    --source-lang spa.inf \
    --target-lang spa.pres \
    --trainpref train \
    --validpref dev \
    --testpref test \
    --tokenizer space \
    --thresholdsrc 2 \
    --thresholdtgt 2 \

echo "Cleaning up..."
rm -rf tmp \
    train.spa.inf train.spa.pres \
    dev.spa.inf dev.spa.pres \
    test.spa.inf test.spa.pres
