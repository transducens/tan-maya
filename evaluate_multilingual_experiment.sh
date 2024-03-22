#!/bin/bash

source scripts/evaluation.sh

source=$1
target=$2
n_run=$3
baseline=$4

if [ -z $4 ]
then
    baseline=""
else
    baseline=".baseline"
fi

langs=$(ls multilingual/dev/ | grep -P "^[a-z]{3}$")

for lang in $langs
do
    best_bleu=0
    for checkpoint_dir in multilingual/dev/$lang/checkpoint_reports/$source-$target$baseline\_$n_run/*
    do
        # echo $checkpoint_dir
        bleu=$(cat $checkpoint_dir/report | python -c "import sys, json; print(json.load(sys.stdin)[0]['score'])")
	if (( $(echo "$bleu > $best_bleu" | bc -l) )) 
	then
	    best_checkpoint=$checkpoint_dir
	    best_bleu=$bleu
	fi
    done

    if [ $source == es ]
    then
    	source_suffix=es
    	target_suffix=$lang
    	id=.id
    else
    	source_suffix=$lang
    	target_suffix=es
    fi
    data=multilingual/test/$lang/data$baseline.bpe$id.$source_suffix
    model_dir=multilingual/model$baseline\_$source-$target\_$n_run
    checkpoint=$(basename -- $best_checkpoint).pt
    target_dir=multilingual/model$baseline\_$source-$target\_$n_run/evaluation/$lang

    echo $data
    echo $model_dir
    echo $checkpoint
    echo $target_dir

    mkdir -p $target_dir

    echo "########## Translating $lang ##########"
    translate $data $model_dir $checkpoint $target_dir

    echo "########## Rebuilding output for $lang ##########"
    rebuild_output $target_dir/data.output-train $target_dir
    
    echo "########## Creating report for $lang ##########"
    create_report $target_dir/data.output-train.detokenized multilingual/test/$lang/data.$target_suffix $target_dir
done
