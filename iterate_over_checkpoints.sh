#!/bin/bash
source scripts/evaluation.sh

source=$1
target=$2
n_run=$3
lang=multilingual/dev/$4

if [ -z $5 ]
then
    baseline=""
else
    baseline=".baseline"
fi

checkpoints=$(ls multilingual/model$baseline\_$source-$target\_$n_run/checkpoints)
if [ $source == es ]
then
    id=.id
fi

if [ -d $lang ]
then
    echo "########## Evaluating $lang ##########"
    
    if [ $source == es ]
    then
        source_suffix=es
        target_suffix=$(basename -- $lang)
        id=.id
    else
        source_suffix=$(basename -- $lang)
        target_suffix=es
    fi

    # echo $source
    # echo $target
    # echo $n_run
    # echo $lang
    # echo $source_suffix
    # echo $target_suffix
    # echo multilingual/model$baseline\_$source-$target\_$n_run/checkpoints
    
    mkdir -p $lang/checkpoint_reports
    for checkpoint in $checkpoints
    do
        checkpoint_name=${checkpoint%.*}
        checkpoint_dir=$lang/checkpoint_reports/$source-$target$baseline\_$n_run/$checkpoint_name
        mkdir -p $checkpoint_dir

        # echo $checkpoint
        # echo $checkpoint_name
        # echo $checkpoint_dir
        
        echo "##### Translating $lang at checkpoint $checkpoint_name #####"
        echo "##### using data$baseline.bpe$id.$source_suffix as source"
        translate $lang/data$baseline.bpe$id.$source_suffix multilingual/model$baseline\_$source-$target\_$n_run $checkpoint $checkpoint_dir
        
        echo "##### Rebuilding output at checkpoint $checkpoint_name #####"
        rebuild_output $checkpoint_dir/data.output-train $checkpoint_dir
        
        echo "##### Creating report for $lang at checkpoint $checkpoint_name #####"
        echo "##### using $lang/data.$target_suffix as target"
        create_report $checkpoint_dir/data.output-train.detokenized $lang/data.$target_suffix $checkpoint_dir 
    done
fi
