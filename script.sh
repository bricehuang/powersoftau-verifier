#!/bin/bash

challenges=(
    challenge_initial
    challenge_0002_kobi
    challenge_0003
    challenge_0004
    challenge_0005
    challenge_0006
    challenge_0007
    challenge_0008
    challenge_0009
    challenge_0010
    challenge_0011
    challenge_0012
    challenge_0013
    challenge_0014
    challenge_0015
)
responses=(
    response_0001_weijie
    response_0002_kobi
    response_0003_poma
    response_0004_pepesha
    response_0005_amrullah
    response_0006_zac
    response_0007_youssef
    response_0008_mike
    response_0009_brecht
    response_0010_vano
    response_0011_zhiniang
    response_0012_daniel
    response_0013_kevin
    response_0014_weijie
)

function download () {
    # downloads challenge or response file from cloud and assigns it local name
    # params:
    # 1: remote name of file, i.e. part of url of file after https://ppot.blob.core.windows.net/public/
    # 2: local name to save file as
    # TODO: make download safe
    # TODO: log something on successful download
    curl https://ppot.blob.core.windows.net/public/$1 --output $2
}

function check () {
    # checks that nth response is consistent with nth challenge, and that
    # n+1th challenge is consistent with nth challenge+response
    # params:
    # 1: round number n
    # 2: remote name of nth response file
    # 3: remote name of n+1th challenge file

    echo Verifying round $1

    # note that when n>1, nth challenge file was downloaded in the previous round, as new_challenge_purported
    # for n=1, we download the 1st challenge file as new_challenge_purported before calling this function
    mv new_challenge_purported challenge
    download $2 response

    # check that nth response is consistent with nth challenge,
    # and produce new_challenge, which should be n+1th challenge
    ../phase2-bn254/powersoftau/target/release/verify_transform_constrained output_round_$1.txt
    download $3 new_challenge_purported

    # TODO: check hashes of new_challenge, new_challenge_purported equal

    # clean up
    rm challenge
    rm response
}

function main () {
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
