#!/bin/bash

curl https://ppot.blob.core.windows.net/public/challenge_initial --output challenge
curl https://ppot.blob.core.windows.net/public/response_0001_weijie --output response
../phase2-bn254/powersoftau/target/release/verify_transform_constrained > output.txt
