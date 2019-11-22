#!/bin/bash

# TODOs:
# make script actually abort on download fail
# log axel output. Currently run into "Can't setup alternate output. Deactivating."
# compute blake2 hash of n+1th challenge
# script to remount 512G disk on vm after reboot

set -e

challenges=(
    challenge_initial
    challenge_0002_kobi
    # challenge_0003
    # challenge_0004
    # challenge_0005
    # challenge_0006
    # challenge_0007
    # challenge_0008
    # challenge_0009
    # challenge_0010
    # challenge_0011
    # challenge_0012
    # challenge_0013
    # challenge_0014
    # challenge_0015
)
responses=(
    response_0001_weijie
    # response_0002_kobi
    # response_0003_poma
    # response_0004_pepesha
    # response_0005_amrullah
    # response_0006_zac
    # response_0007_youssef
    # response_0008_mike
    # response_0009_brecht
    # response_0010_vano
    # response_0011_zhiniang
    # response_0012_daniel
    # response_0013_kevin
    # response_0014_weijie
)

function download_attempt () {
    # downloads challenge or response file from cloud and assigns it local name.
    # params:
    # 1: remote name of file, i.e. part of url of file after https://ppot.blob.core.windows.net/public/
    # 2: local name to save file as
    echo "Attempting to download $1" >> log.txt
    axel -a https://ppot.blob.core.windows.net/public/$1 -o $2 # TODO log this
}

function download () {
    # downloads challenge or response file from cloud and assigns it local name
    # attempts 3 times. If fail all 3 times, abort with error message.
    # params:
    # 1: remote name of file, i.e. part of url of file after https://ppot.blob.core.windows.net/public/
    # 2: local name to save file as
    # TODO: make sure this does what it's supposed to
    download_attempt $1 $2 || download_attempt $1 $2 || download_attempt $1 $2 || ( echo "Failed to download $1, quitting..." >> log.txt ; exit 1 )
    echo "Successfully downloaded $1" >> log.txt
}

function check () {
    # checks that nth response is consistent with nth challenge, and that
    # n+1th challenge is consistent with nth challenge+response
    # params:
    # 1: round number n
    # 2: remote name of nth response file
    # 3: remote name of n+1th challenge file

    echo "" >> log.txt
    echo "--------------------------------------------------" >> log.txt
    echo "BEGINNING VERIFICATION FOR ROUND $1" >> log.txt

    # note that when n>1, nth challenge file was downloaded in the previous round, as new_challenge_purported
    # for n=1, we download the 1st challenge file as new_challenge_purported before calling this function
    mv new_challenge_purported challenge

    # download response n
    download $2 response

    # check that nth response is consistent with nth challenge,
    # and produce new_challenge, which should be n+1th challenge
    ../phase2-bn254/powersoftau/target/release/verify_transform_constrained > round_outputs/output_round_$1.txt
    cat round_outputs/output_round_$1.txt >> log.txt
    echo "Verified response $1 is consistent" >> log.txt

    # download challenge n+1
    download $3 new_challenge_purported

    # extract expected hash of challenge n+1
    n_plus_one=`expr $1 + 1`
    cat round_outputs/output_round_$1.txt | sed -n -e '/`new_challenge`/,$p' | tail -n +2 | sed -n "/Done/q;p" | tr -d "\t" | tr -d "\n" | tr -d " " >> challenge_hashes/expected_$n_plus_one.txt
    echo "" >> challenge_hashes/expected_$n_plus_one.txt
    echo "Extracted expected hash of challenge $n_plus_one" >> log.txt

    # TODO: produce hash of new_challenge_purported, this next line is placeholder
    python3 blake2.py new_challenge >> challenge_hashes/actual_$n_plus_one.txt
    echo "Computed actual hash of challenge $n_plus_one" >> log.txt

    # verify computed and expected hashes are equal, and abort otherwise
    if cmp -s challenge_hashes/actual_$n_plus_one.txt challenge_hashes/expected_$n_plus_one.txt ; then
       echo "Verified challenge $n_plus_one is consistent" >> log.txt
    else
       echo "Challenge $n_plus_one is not consistent, quitting..." >> log.txt
       exit 1
    fi

    # clean up
    rm challenge
    rm response
}

function main () {
    rm log.txt
    # set up main loop by downloading first challenge file as new_challenge_purported
    download ${challenges[0]} new_challenge_purported
    for idx in "${!responses[@]}"; do
        # main loop
        response=${responses[$idx]} # remote name of nth response
        idx_plus_one=`expr $idx + 1`
        next_challenge=${challenges[$idx_plus_one]} # remote name of n+1th challenge

        check $idx_plus_one $response $next_challenge
    done
}

main
