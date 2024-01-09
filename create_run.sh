source scripts/upsample_training_corpora.sh
source scripts/preprocess.sh

len=("$@")
len="${#len[@]}"

if (($len > 1))
then
    if [ -d ../multilingual ]
    then
        echo "Cannot create root folder for run: Folder already exists"
        exit
    fi
    echo Preparing multilingual training run including the following languages: $@
    mkdir -p multilingual/train
    mkdir -p multilingual/dev
    mkdir -p multilingual/test
    for lang in $@
    do
        if [ -e $lang/train/data.$lang ]
        then
            cat $lang/train/data.$lang >> multilingual/train/data.cmb
            cat $lang/train/data.es >> multilingual/train/data.es
        fi

        if [ -e $lang/dev/data.$lang ]
        then
            mkdir -p multilingual/dev/$lang
            cp $lang/dev/data.$lang multilingual/dev/$lang/
            cp $lang/dev/data.es multilingual/dev/$lang/
        fi

        if [ -e $lang/test/data.$lang ]
        then
            mkdir -p multilingual/test/$lang
            cp $lang/test/data.$lang multilingual/test/$lang/
            cp $lang/test/data.es multilingual/test/$lang/
        fi
    done

    echo "##### Upsampling train dataset to address corpus imbalance"

    paste multilingual/train/data.es multilingual/train/data.cmb > multilingual/train/data.escmb

    declare -A q=$(get_q 0.7 multilingual/train/data.escmb)

    for lang in ${!q[@]}
    do
        get_q_sentences_by_lang $lang ${q[$lang]} "multilingual/train/data.escmb" >> multilingual/train/data.escmb.augmented
    done

    cut multilingual/train/data.escmb.augmented -f1 > data.es
    cut multilingual/train/data.escmb.augmented -f2 > data.cmb
    rm multilingual/train/data.escmb
    rm multilingual/train/data.escmb.augmented

    echo "##### Tokenising"

    # Extract lang id token
    cut multilingual/train/data.es -f1 -d " " > multilingual/train/lang_tokens
    sed -i "s/#.*# //g" multilingual/train/data.es
    tokenize multilingual/train/data.es
    tokenize multilingual/train/data.cmb

    echo "##### Learning Truecaser"
    learn_truecaser multilingual/train/data.tok.es
    learn_truecaser multilingual/train/data.tok.cmb

    echo "##### Applying Truecaser"
    apply_truecaser multilingual/train/data.tok.es
    apply_truecaser multilingual/train/data.tok.cmb

    echo "##### Learning joint BPE"
    learn_joint_bpe multilingual/train/data.truecase.es multilingual/train/data.truecase.cmb

    echo "##### Applying BPE"
    apply_bpe multilingual/train/data.truecase.es multilingual/train/data.truecase.cmb

    echo "##### Tokenizing and applying Truecaser and BPE to dev and test sets"

    for dir in dev test
    do
        for lang in $@
        do
            if [ -e multilingual/$dir/$lang/data.es ]
            then
                cut multilingual/$dir/$lang/data.es -f1 -d " " > multilingual/$dir/$lang/lang_tokens
                sed -i "s/#.*# //g" multilingual/$dir/$lang/data.es
                
                tokenize multilingual/$dir/$lang/data.es
                tokenize multilingual/$dir/$lang/data.$lang

                apply_truecaser multilingual/$dir/$lang/data.tok.es multilingual/train/truecaser/truecase-model.es
                apply_truecaser multilingual/$dir/$lang/data.tok.$lang multilingual/train/truecaser/truecase-model.cmb

                apply_bpe multilingual/$dir/$lang/data.truecase.es multilingual/$dir/$lang/data.truecase.$lang es cmb multilingual/train
            fi
        done
    done

    echo "##### Concat dev set for train run"
    
    for lang in $@
    do
        if [ -e multilingual/dev/$lang/data.es ]
        then
            cat multilingual/dev/$lang/data.bpe.es >> multilingual/dev/data.bpe.es
            cat multilingual/dev/$lang/data.bpe.$lang >> multilingual/dev/data.bpe.cmb
            cat multilingual/dev/$lang/lang_tokens >> multilingual/dev/lang_tokens
        fi
    done

    echo "##### Creating dataset with attached lang id token"
   
    paste -d " " multilingual/train/lang_tokens multilingual/train/data.bpe.es > multilingual/train/data.bpe.id.es
    paste -d " " multilingual/dev/lang_tokens multilingual/dev/data.bpe.es > multilingual/dev/data.bpe.id.es
    cp multilingual/train/data.bpe.cmb multilingual/train/data.bpe.id.cmb
    cp multilingual/dev/data.bpe.cmb multilingual/dev/data.bpe.id.cmb
    
    for lang in $@
    do
        if [ -d multilingual/dev/$lang ]
        then
            paste -d " " multilingual/dev/$lang/lang_tokens multilingual/dev/$lang/data.bpe.es > multilingual/dev/$lang/data.bpe.id.es
	    cp multilingual/dev/$lang/data.bpe.cmb multilingual/dev/$lang/data.bpe.id.cmb
        fi

        if [ -d multilingual/test/$lang ]
        then
            paste -d " " multilingual/test/$lang/lang_tokens multilingual/test/$lang/data.bpe.es > multilingual/test/$lang/data.bpe.id.es
	    cp multilingual/test/$lang/data.bpe.cmb multilingual/test/$lang/data.bpe.id.cmb
        fi
    done
    
else
    lang=$@
    
    if [ -e bilingual_$lang ]
    then
        echo "Cannot create root folder for run: Folder already exists"
        exit
    fi

    if [ -e $lang/train/data.$lang ] && [ -e $lang/dev/data.$lang ] && [ -e $lang/test/data.$lang ]
    then
        echo Preparing bilingual training run for $lang
        mkdir -p bilingual_$lang/train
        mkdir -p bilingual_$lang/dev
        mkdir -p bilingual_$lang/test
        
        cat $lang/train/data.$lang >> bilingual_$lang/train/data.$lang
        cat $lang/train/data.es >> bilingual_$lang/train/data.es
        
        cp $lang/dev/data.$lang bilingual_$lang/dev/
        cp $lang/dev/data.es bilingual_$lang/dev/
        
        cp $lang/test/data.$lang bilingual_$lang/test/
        cp $lang/test/data.es bilingual_$lang/test/

        for dir in train dev test
        do
            cut bilingual_$lang/$dir/data.es -f1 -d " " > bilingual_$lang/$dir/language_tokens
            sed -i "s/#.*# //g" bilingual_$lang/$dir/data.es
            
            echo "##### Tokenizing $dir set"
            tokenize bilingual_$lang/$dir/data.$lang
            tokenize bilingual_$lang/$dir/data.es
        done

        echo "##### Learning Truecaser"
        learn_truecaser bilingual_$lang/train/data.tok.es
        learn_truecaser bilingual_$lang/train/data.tok.$lang

        for dir in train dev test
        do
            echo "##### Applying Truecaser to $dir set"
            apply_truecaser bilingual_$lang/$dir/data.tok.es bilingual_$lang/train/truecaser/truecase-model.es
            apply_truecaser bilingual_$lang/$dir/data.tok.$lang bilingual_$lang/train/truecaser/truecase-model.$lang
        done

        echo "##### Learning BPE"
        learn_joint_bpe bilingual_$lang/train/data.truecase.es bilingual_$lang/train/data.truecase.$lang

        for dir in train dev test
        do
            echo "##### Applying BPE to $dir set"
            apply_bpe bilingual_$lang/$dir/data.truecase.es bilingual_$lang/$dir/data.truecase.$lang es $lang bilingual_$lang/train
        done

    else
        echo "Missing train-test-dev data for $lang!"
    fi
fi
