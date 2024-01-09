#!/bin/bash
source scripts/evaluation.sh

source=$1
target=$2
checkpoints=$(ls multilingual/model_$source-$target/checkpoints)
if [ $source == es ]
then
    id=.id
fi

for lang in multilingual/dev/*
do
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
        
	mkdir -p $lang/checkpoint_reports
        for checkpoint in $checkpoints
        do
            checkpoint_name=${checkpoint%.*}
            checkpoint_dir=$lang/checkpoint_reports/$source-$target/$checkpoint_name
            mkdir -p $checkpoint_dir
            
	    echo "##### Translating $lang at checkpoint $checkpoint_name #####"
	    echo "##### using data.bpe$id.$source_suffix as source"
            translate $lang/data.bpe$id.$source_suffix multilingual/model_$source-$target $checkpoint $checkpoint_dir
	    
	    echo "##### Rebuilding output at checkpoint $checkpoint_name #####"
            rebuild_output $checkpoint_dir/data.output-train $checkpoint_dir
	    
	    echo "##### Creating report for $lang at checkpoint $checkpoint_name #####"
	    echo "##### using $lang/data.$target_suffix as target"
            create_report $checkpoint_dir/data.output-train.detokenized $lang/data.$target_suffix $checkpoint_dir 
        done
    fi
done
