home=/neural/alou
langs="ixl kek kjb mam poc poh quc ttc tzh"

# for lang in $langs
# do
#     cat $home/corpora_mayas/$lang/dataframes/vocabulario.csv | cut -f4 > $lang-es/cmb/train/data.cmb
#     cat $home/corpora_mayas/$lang/dataframes/vocabulario.csv | cut -f5 > $lang-es/cmb/train/data.es


#     cp multilingue_maya_espanol/cmb/dev/$lang/data.es $lang-es/cmb/dev/data.es
#     cp multilingue_maya_espanol/cmb/dev/$lang/data.$lang $lang-es/cmb/dev/data.cmb
    
#     cp multilingue_maya_espanol/cmb/test/$lang/data.es $lang-es/cmb/test/$lang/data.es
#     cp multilingue_maya_espanol/cmb/test/$lang/data.$lang $lang-es/cmb/test/$lang/data.$lang

#     sed -i "s/^ *//" $lang-es/cmb/train/data.cmb
#     sed -i "s/^ *//" $lang-es/cmb/dev/data.cmb
#     sed -i "s/^ *//" $lang-es/cmb/test/$lang/data.$lang

#     sed -i "s/^ *//" $lang-es/cmb/train/data.es
#     sed -i "s/^ *//" $lang-es/cmb/dev/data.es
#     sed -i "s/^ *//" $lang-es/cmb/test/$lang/data.es

#     paste $lang-es/cmb/train/data.cmb $lang-es/cmb/train/data.es > $lang-es/cmb/train/data.cmbes

# done
    
# python remove_dev_test_lines_from_train.py

for lang in $langs
do
    for corpus in jw mozilla bible
    do
        if [ -d $home/corpora_mayas/$lang/$corpus ]
        then               
             cat $home/corpora_mayas/$lang/$corpus/data.$lang >> $lang-es/cmb/train/data.cmb
             cat $home/corpora_mayas/$lang/$corpus/data.es >> $lang-es/cmb/train/data.es
        fi
    done
done