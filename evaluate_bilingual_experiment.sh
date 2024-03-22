#!/bin/bash

source scripts/evaluation.sh

dir=$1
source=$2
target=$3
n_run=$4

if [ -z $5 ]
then
    baseline=""
else
    baseline=".baseline"
fi

data=$dir/test/data$baseline.bpe.$source
model_dir=$dir/model$baseline\_$source-$target\_$n_run
checkpoint=checkpoint_best.pt
target_dir=$dir/model$baseline\_$source-$target\_$n_run/evaluation

mkdir -p $target_dir

echo $data
echo $model_dir
echo $checkpoint
echo $target_dir

echo "########## Translating $source ##########"
translate $data $model_dir $checkpoint $target_dir

echo "########## Rebuilding output ##########"
rebuild_output $target_dir/data.output-train $target_dir

echo "########## Creating report ##########"
create_report $target_dir/data.output-train.detokenized $dir/test/data.$target $target_dir
