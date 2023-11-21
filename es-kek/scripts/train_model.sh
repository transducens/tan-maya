#!/bin/bash


function train_model() {
	lang=$1
	trainArgs="--arch transformer --share-all-embeddings  --label-smoothing 0.1 --criterion label_smoothed_cross_entropy --weight-decay 0  --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0 --lr-scheduler inverse_sqrt --warmup-updates 8000 --warmup-init-lr 1e-7 --lr 0.0007 --stop-min-lr 1e-9  --save-interval-updates 5000  --patience 10 --max-tokens 4000 --eval-bleu --eval-tokenized-bleu --eval-bleu-args '{\"beam\":5,\"max_len_a\":1.2,\"max_len_b\":10}' --best-checkpoint-metric bleu --maximize-best-checkpoint-metric --keep-best-checkpoints 1 --restore-file $lang/model/checkpoints/checkpoint_best.pt --keep-interval-updates 1 --no-epoch-checkpoints"

	if [ ! -e $lang/model ]; then
		mkdir -p $lang/model
	fi

	if [ ! -e $lang/model/checkpoints ]; then
		mkdir -p $lang/model/checkpoints
	fi


	fairseq-preprocess -s es -t  $lang \
	--trainpref $lang/train/data.bpe \
	--validpref $lang/dev/data.bpe \
	--destdir $lang/model \
	--workers 1 \
	--joined-dictionary

	echo "Training args: $trainArgs"
	echo "See $lang/model/train.log for details"
	eval "CUDA_VISIBLE_DEVICES=0 fairseq-train $trainArgs --seed $RANDOM --save-dir $lang/model/checkpoints $lang/model &> $lang/model/train.log"
}
