#!/bin/bash

source scripts/evaluation.sh

dir=$1
source=$2
target=$3

data=$dir/test/data.bpe.$source
model_dir=$dir/model_$source-$target
checkpoint=checkpoint_best.pt
target_dir=$dir/model_$source-$target/evaluation

mkdir -p $target_dir

echo "########## Translating $source ##########"
translate $data $model_dir $checkpoint $target_dir

echo "########## Rebuilding output ##########"
rebuild_output $target_dir/data.output-train $target_dir

echo "########## Creating report ##########"
create_report $target_dir/data.output-train.detokenized $dir/test/data.$target $target_dir
