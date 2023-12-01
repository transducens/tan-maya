#!/bin/bash

moses_scripts=submodules/moses-scripts/scripts/
nomalizer=$moses_scripts/tokenizer/normalize-punctuation.perl
tokenizer=$moses_scripts/tokenizer/tokenizer.perl
detokenizer=$moses_scripts/tokenizer/detokenizer.perl
clean_corpus=$moses_scripts/training/clean-corpus-n.perl
train_truecaser=$moses_scripts/recaser/train-truecaser.perl
truecaser=$moses_scripts/recaser/truecase.perl
detruecaser=$moses_scripts/recaser/detruecase.perl

lang=quc

function tokenize_test () {
	echo "##################### tokenize_test"
	lang=$1
	set=$2
	cat cmb/test/$lang/jw.$lang | \
	$nomalizer -l es | \
	$tokenizer -a -no-escape -l $lang > \
	cmb/test/$lang/jw.tok.$lang
	
	cat cmb/test/$lang/jw.es | \
	$nomalizer -l es | \
	$tokenizer -a -no-escape -l es > \
	cmb/test/$lang/jw.tok.es	
}

function apply_truecaser_test () {
	echo "##################### apply_truecaser_test"
	lang=$1
	set=$2
	cat cmb/test/$lang/jw.tok.$lang | \
	$truecaser -model cmb/truecaser/truecase-model.cmb > \
	cmb/test/$lang/jw.truecase.$lang
	
	cat cmb/test/$lang/jw.tok.es | \
	$truecaser -model cmb/truecaser/truecase-model.es > \
	cmb/test/$lang/jw.truecase.es	
}

function apply_bpe_test() {
	echo "##################### apply_bpe_test"
	lang=$1
	set=$2
	cat cmb/test/$lang/jw.truecase.$lang | \
	subword-nmt apply-bpe --vocabulary cmb/bpe/vocab.cmb-es.bpe.vocab.cmb \
	--vocabulary-threshold 1 \
	-c cmb/bpe/vocab.cmb-es.bpe > cmb/test/$lang/jw.bpe.$lang	

	cat cmb/test/$lang/jw.truecase.es | \
	subword-nmt apply-bpe --vocabulary cmb/bpe/vocab.cmb-es.bpe.vocab.es \
	--vocabulary-threshold 1 \
	-c cmb/bpe/vocab.cmb-es.bpe > cmb/test/$lang/jw.bpe.es
}

function translate_test() {
	lang=$1
	test_dir=cmb/test/$lang
	
	if [ -e $test_dir ]
	
	then
		target_dir=cmb/evaluation/$lang

		CUDA_VISIBLE_DEVICES=0 fairseq-interactive --input $test_dir/jw.bpe.es --path cmb/model/checkpoints/checkpoint_best.pt cmb/model | grep '^H-' | cut -f 3 > $target_dir/jw.output-train
	fi
}

function rebuild_output () {
	lang=$1
	test_dir=cmb/test/$lang
	
	if [ -e $test_dir ]

	then
		target_dir=cmb/evaluation/$lang
		
		cat $target_dir/jw.output-train | \
		sed -r 's/(@@ )|(@@ ?$)//g' > $target_dir/jw.output-train.debpe

		cat $target_dir/jw.output-train.debpe | \
		$detruecaser > $target_dir/jw.output-train.detruecased

		cat $target_dir/jw.output-train.detruecased | \
		$detokenizer -l es > $target_dir/jw.output-train.detokenized
	fi
}

function report () {
	lang=$1
	set=$2
	test_dir=cmb/test/$lang

	if [ -e $test_dir ]
	then
		target_dir=cmb/evaluation/$lang

		cat $target_dir/jw.output-train.detokenized | \
		sacrebleu $test_dir/jw.$lang \
		--width 3 -l $lang-es --metrics bleu chrf  > $target_dir/report_jw
	fi
}

tokenize_test $lang
apply_truecaser_test $lang
apply_bpe_test $lang 

translate_test $lang
rebuild_output $lang
report $lang

