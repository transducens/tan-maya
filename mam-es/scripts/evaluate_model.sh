#!/usr/bin/bash

moses_scripts=submodules/moses-scripts/scripts/
detruecaser=$moses_scripts/recaser/detruecase.perl
detokenizer=$moses_scripts/tokenizer/detokenizer.perl

function translate_test() {
	lang=$1
	set=$2
	test_dir=cmb/test/$lang
	
	if [ -e $test_dir ]
	
	then
		target_dir=cmb/evaluation/$lang
		mkdir -p cmb/evaluation/$lang

		CUDA_VISIBLE_DEVICES=0 fairseq-interactive --input $test_dir/data.bpe.$lang --path cmb/model/checkpoints/checkpoint_best.pt cmb/model | grep '^H-' | cut -f 3 > $target_dir/data.output-train
	fi
}

function rebuild_output () {
	lang=$1
	set=$2
	test_dir=cmb/test/$lang
	
	if [ -e $test_dir ]

	then
		target_dir=cmb/evaluation/$lang
		
		cat $target_dir/data.output-train | \
		sed -r 's/(@@ )|(@@ ?$)//g' > $target_dir/data.output-train.debpe

		cat $target_dir/data.output-train.debpe | \
		$detruecaser > $target_dir/data.output-train.detruecased

		cat $target_dir/data.output-train.detruecased | \
		$detokenizer -l es > $target_dir/data.output-train.detokenized
	fi
}

function report () {
	lang=$1
	set=$2
	test_dir=cmb/test/$lang

	if [ -e $test_dir ]
	then
		target_dir=cmb/evaluation/$lang

		cat $target_dir/data.output-train.detokenized | \
		sacrebleu $test_dir/data.es \
		--width 3 -l $lang-es --metrics bleu chrf  > $target_dir/report
	fi
}