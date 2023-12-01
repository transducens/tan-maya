#!/bin/bash

moses_scripts=submodules/moses-scripts/scripts

normalizer=$moses_scripts/tokenizer/normalize-punctuation.perl
tokenizer=$moses_scripts/tokenizer/tokenizer.perl
detokenizer=$moses_scripts/tokenizer/detokenizer.perl
clean_corpus=$moses_scripts/training/clean-corpus-n.perl
train_truecaser=$moses_scripts/recaser/train-truecaser.perl
truecaser=$moses_scripts/recaser/truecase.perl
detruecaser=$moses_scripts/recaser/detruecase.perl

function tokenize () {
	echo "##################### tokenize"
	echo $lang
	echo $1
	lang=$1
	frac=$2
	dir=$3
	cat $dir/data.$lang | \
	$normalizer -l es | \
	$tokenizer -a -no-escape -l $lang > \
	$dir/data.tok.$lang
	
	cat $dir/data.es | \
	$normalizer -l es | \
	$tokenizer -a -no-escape -l es > \
	$dir/data.tok.es

	# tokenise upsampled corpus for BPE
	cat $dir/data.es.upsampled | \
	$normalizer -l es | \
	$tokenizer -a -no-escape -l $lang > \
	$dir/data.tok.es.upsampled

	cat $dir/data.cmb.upsampled | \
	$normalizer -l es | \
	$tokenizer -a -no-escape -l $lang > \
	$dir/data.tok.cmb.upsampled
}

function tokenize_test () {
	echo "##################### tokenize_test"
	lang=$1
	set=$2
	cat cmb/test/$lang/data.$lang | \
	$normalizer -l es | \
	$tokenizer -a -no-escape -l $lang > \
	cmb/test/$lang/data.tok.$lang
	
	cat cmb/test/$lang/data.es | \
	$normalizer -l es | \
	$tokenizer -a -no-escape -l es > \
	cmb/test/$lang/data.tok.es	
}

function learn_truecaser() {
	echo "##################### learn_truecaser"
	lang=$1
	mkdir -p $lang/truecaser
	$train_truecaser -corpus $lang/train/data.tok.$lang -model $lang/truecaser/truecase-model.$lang 
	$train_truecaser -corpus $lang/train/data.tok.es -model $lang/truecaser/truecase-model.es 
}

function apply_truecaser() {
	echo "##################### apply_truecaser"
	lang=$1
	frac=$2
	dir=$3
	cat $dir/data.tok.$lang | \
	$truecaser -model $lang/truecaser/truecase-model.$lang > \
	$dir/data.truecase.$lang
	
	cat $dir/data.tok.es | \
	$truecaser -model $lang/truecaser/truecase-model.es > \
	$dir/data.truecase.es

	# apply truecaser to upsampled data for BPE
	cat $dir/data.tok.es.upsampled | \
	$truecaser -model $lang/truecaser/truecase-model.es > \
	$dir/data.truecase.es.upsampled	

	cat $dir/data.tok.cmb.upsampled | \
	$truecaser -model $lang/truecaser/truecase-model.es > \
	$dir/data.truecase.cmb.upsampled
}

function apply_truecaser_test () {
	echo "##################### apply_truecaser_test"
	lang=$1
	set=$2
	cat cmb/test/$lang/data.tok.$lang | \
	$truecaser -model cmb/truecaser/truecase-model.cmb > \
	cmb/test/$lang/data.truecase.$lang
	
	cat cmb/test/$lang/data.tok.es | \
	$truecaser -model cmb/truecaser/truecase-model.es > \
	cmb/test/$lang/data.truecase.es	
}

function learn_joint_bpe() {
	# learn BPE exclusively from upsampled corpora
	echo "##################### learn_joint_bpe"
	echo "Learning BPE from upsampled corpus"
	lang=$1
	operations=$2
	mkdir $lang/bpe
	subword-nmt learn-joint-bpe-and-vocab \
	--input $lang/train/data.truecase.cmb.upsampled $lang/train/data.truecase.es.upsampled \
	-s $operations \
	-o $lang/bpe/vocab.$lang-es.bpe \
	--write-vocabulary $lang/bpe/vocab.$lang-es.bpe.vocab.$lang $lang/bpe/vocab.$lang-es.bpe.vocab.es
	
}

function apply_bpe() {
	echo "##################### apply_bpe"
	lang=$1
	frac=$2
	dir=$3
	cat $dir/data.truecase.$lang | \
	subword-nmt apply-bpe --vocabulary $lang/bpe/vocab.$lang-es.bpe.vocab.$lang \
	--vocabulary-threshold 1 \
	-c $lang/bpe/vocab.$lang-es.bpe > $dir/data.bpe.$lang	

	cat $dir/data.truecase.es | \
	subword-nmt apply-bpe --vocabulary $lang/bpe/vocab.$lang-es.bpe.vocab.es \
	--vocabulary-threshold 1 \
	-c $lang/bpe/vocab.$lang-es.bpe > $dir/data.bpe.es
}

function apply_bpe_test() {
	echo "##################### apply_bpe_test"
	lang=$1
	set=$2
	cat cmb/test/$lang/data.truecase.$lang | \
	subword-nmt apply-bpe --vocabulary cmb/bpe/vocab.cmb-es.bpe.vocab.cmb \
	--vocabulary-threshold 1 \
	-c cmb/bpe/vocab.cmb-es.bpe > cmb/test/$lang/data.bpe.$lang	

	cat cmb/test/$lang/data.truecase.es | \
	subword-nmt apply-bpe --vocabulary cmb/bpe/vocab.cmb-es.bpe.vocab.es \
	--vocabulary-threshold 1 \
	-c cmb/bpe/vocab.cmb-es.bpe > cmb/test/$lang/data.bpe.es
}