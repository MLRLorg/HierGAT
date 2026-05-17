#!/bin/bash

TASKS=(
"Amazon-Google"
"Abt-Buy"
"Beer"
"Itunes-Amazon"
"Walmart-Amazon"
"Fodors-Zagats"
"DBLP-ACM"
"DBLP-Scholar"
"Company"
"Dirty/DBLP-ACM"
"Dirty/DBLP-Scholar"
"Dirty/Walmart-Amazon"
"Dirty/Itunes-Amazon"
"N/Amazon-Google"
"N/DBLP-ACM"
"N/Abt-Buy"
"N/Walmart-Amazon"
"N/Itunes-Amazon"
)

mkdir -p logs
mkdir -p results
mkdir -p checkpoints

RESULTS_FILE="results/results.csv"

# cabeçalho CSV
echo "task,f1,precision,recall,time_seconds,time_human" > $RESULTS_FILE

for TASK in "${TASKS[@]}"
do
    echo "===================================="
    echo "Running task: $TASK"
    echo "===================================="

    BATCH=16

    # datasets problemáticos
    if [[ "$TASK" == *"Itunes-Amazon"* ]]; then
        BATCH=4
    fi

    SAFE_TASK=$(echo "$TASK" | tr '/' '_')

    START=$(date +%s)

    python train.py \
        --task "$TASK" \
        --batch_size $BATCH \
        --max_len 512 \
        --lr 1e-5 \
        --n_epochs 10 \
        --finetuning \
        --split \
        --lm roberta \
        > logs/${SAFE_TASK}.log 2>&1

    END=$(date +%s)

    ELAPSED=$((END - START))

    HUMAN_TIME=$(printf '%02dh:%02dm:%02ds\n' \
        $((ELAPSED/3600)) \
        $((ELAPSED%3600/60)) \
        $((ELAPSED%60)))

    echo "Finished: $TASK"
    echo "Elapsed: $HUMAN_TIME"

    # Extrai métricas do log
    F1=$(grep -i "f1" logs/${SAFE_TASK}.log | tail -1 | grep -oE '[0-9]+\.[0-9]+' | tail -1)
    PREC=$(grep -i "precision" logs/${SAFE_TASK}.log | tail -1 | grep -oE '[0-9]+\.[0-9]+' | tail -1)
    REC=$(grep -i "recall" logs/${SAFE_TASK}.log | tail -1 | grep -oE '[0-9]+\.[0-9]+' | tail -1)

    # fallback caso parsing falhe
    F1=${F1:-NA}
    PREC=${PREC:-NA}
    REC=${REC:-NA}

    echo "$TASK,$F1,$PREC,$REC,$ELAPSED,$HUMAN_TIME" >> $RESULTS_FILE

done

echo "===================================="
echo "ALL TASKS FINISHED"
echo "Results saved to: $RESULTS_FILE"
echo "===================================="
