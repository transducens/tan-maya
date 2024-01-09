# Intended to be run only once, this script will create the train-dev-test
# partitions for all languages in the corpora_mayas folder using the 
# vocabularies as test-dev fractions

home=/neural/alou
langs=$(ls $home/corpora_mayas)

echo "Creating corpora for…"
for lang in $langs
do
    if [ -d $lang ]
    then
        echo "'$lang' folder already exists! Skipping."
    else
        echo "$lang"
        mkdir -p $lang/train
        mkdir -p $lang/dev
        mkdir -p $lang/test
        
        if [ -e $home/corpora_mayas/$lang/dataframes/vocabulario.csv ]
        then
            shuf $home/corpora_mayas/$lang/dataframes/vocabulario.csv > $lang/test/vocabulario.shuf
            
            vocab="$lang/test/vocabulario.shuf"
            
            head -1000 $vocab | cut -f4 > $lang/test/data.$lang
            head -1000 $vocab | cut -f5 | sed -e 's/^/#'$lang'# /' > $lang/test/data.es

            # if nb of lines in vocab > 2000, take the next 1000 lines, put them in dev, and then put the remainder in train
            if [ $(wc -l < $vocab) -ge 2000 ]
            then
                    tail +1001 $vocab | head -1000 | cut -f4 >> $lang/dev/data.$lang
                    tail +1001 $vocab | head -1000 | cut -f5 | sed -e 's/^/#'$lang'# /' >> $lang/dev/data.es

                    tail +2001 $vocab | cut -f4 >> $lang/train/data.$lang
                    tail +2001 $vocab | cut -f5 | sed -e 's/^/#'$lang'# /' >> $lang/train/data.es

                # else, take the remaining lines and put them all in dev
            else
                    tail +1000 $vocab | cut -f4 >> $lang/dev/data.$lang
                    tail +1000 $vocab | cut -f5 | sed -e 's/^/#'$lang'# /' >> $lang/dev/data.es
            fi
        fi
        
        for corpus in jw mozilla bible tatoeba
        do
            if [ -d $home/corpora_mayas/$lang/$corpus ]
            then
                echo "Found $corpus for $lang"
                cat $home/corpora_mayas/$lang/$corpus/data.$lang >> $lang/train/data.$lang
                cat $home/corpora_mayas/$lang/$corpus/data.es | sed -e 's/^/#'$lang'# /' >> $lang/train/data.es
            fi
        done
        rm -f $lang/test/vocabulario.shuf
    fi
done

for lang in $langs
do
    for dir in train dev test
    do
        if [ -e $lang/$dir/data.es ]
        then
            sed -i "s/\.//g" $lang/$dir/data.es
            sed -i "s/\.//g" $lang/$dir/data.$lang
        fi
    done
done