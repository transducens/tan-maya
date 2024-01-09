#!/bin/bash

function train_model() {
	dir=$HOME/tan-maya/bilingual_agu
	source=es
	target=agu
	train_pref=$dir/train/data.bpe
	dev_pref=$dir/dev/data.bpe

	trainArgs="--arch transformer --share-all-embeddings  --label-smoothing 0.1 --criterion label_smoothed_cross_entropy --weight-decay 0  --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0 --lr-scheduler inverse_sqrt --warmup-updates 8000 --warmup-init-lr 1e-7 --lr 0.0007 --stop-min-lr 1e-9 --max-tokens 4000 --eval-bleu --eval-tokenized-bleu --eval-bleu-args '{\"beam\":5,\"max_len_a\":1.2,\"max_len_b\":10}' --best-checkpoint-metric bleu --maximize-best-checkpoint-metric --keep-best-checkpoints 1 --save-interval-updates 5000 --keep-interval-updates 20 --restore-file $dir/model_$source-$target/checkpoints/checkpoint_best.pt --ddp-backend=no_c10d --no-epoch-checkpoints --patience 20"

	if [ ! -e $dir/model_$source-$target ]; then
		mkdir -p $dir/model_$source-$target
	fi

	if [ ! -e $dir/model_$source-$target/checkpoints ]; then
		mkdir -p $dir/model_$source-$target/checkpoints
	fi


	fairseq-preprocess -s $source -t $target \
	--trainpref $train_pref \
	--validpref $dev_pref \
	--destdir $dir/model_$source-$target \
	--workers 1 \
	--joined-dictionary

	echo "Training args: $trainArgs"
	echo "See $dir/model_$source-$target/train.log for details"
	eval "CUDA_VISIBLE_DEVICES=0 fairseq-train $trainArgs --seed $RANDOM --save-dir $dir/model_$source-$target/checkpoints $dir/model_$source-$target &> $dir/model_$source-$target/train.log"
}

train_model
