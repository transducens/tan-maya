#!/bin/bash

function train_model() {
	dir=$HOME/tan-maya/multilingual
	source=$1
	target=$2
	baseline=$3

	if [ -z $3 ]
	then
	    baseline=""
    else
	    baseline=".baseline"
	fi

	if [ $source == es ]
	then
		train_pref=$dir/train/data$baseline.bpe.id
		dev_pref=$dir/dev/data$baseline.bpe.id
	else
		train_pref=$dir/train/data$baseline.bpe
		dev_pref=$dir/dev/data$baseline.bpe
	fi


        n=1
	while [ -e $dir/model$baseline\_$source-$target\_$n ]
	do
	    n=$((n+1))
        done
	
	numbered_dir=$dir/model$baseline\_$source-$target\_$n
	mkdir -p $numbered_dir/checkpoints

	trainArgs="--arch transformer --share-all-embeddings  --label-smoothing 0.1 --criterion label_smoothed_cross_entropy --weight-decay 0  --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0 --lr-scheduler inverse_sqrt --warmup-updates 8000 --warmup-init-lr 1e-7 --lr 0.0007 --stop-min-lr 1e-9 --max-tokens 4000 --eval-bleu --eval-tokenized-bleu --eval-bleu-args '{\"beam\":5,\"max_len_a\":1.2,\"max_len_b\":10}' --best-checkpoint-metric bleu --maximize-best-checkpoint-metric --keep-best-checkpoints 1 --save-interval-updates 5000 --keep-interval-updates 20 --restore-file $numbered_dir/checkpoints/checkpoint_best.pt --ddp-backend=no_c10d --no-epoch-checkpoints --patience 20"

	fairseq-preprocess -s $source -t $target \
	--trainpref $train_pref \
	--validpref $dev_pref \
	--destdir $numbered_dir \
	--workers 1 \
	--joined-dictionary

	echo "Training args: $trainArgs"
	echo "See $numbered_dir/train.log for details"
	eval "CUDA_VISIBLE_DEVICES=0,1,2,3 fairseq-train $trainArgs --seed $RANDOM --save-dir $numbered_dir/checkpoints $numbered_dir &> $numbered_dir/train.log"
}

train_model $1 $2 $3
