#!/bin/bash

maskfile="/Users/fadhlilrizki/Documents/PhD/thesis/data/landsea_precres_aus_mask.nc"
diri="/Users/fadhlilrizki/Documents/PhD/thesis/dataout/precip/"

file=$(ls ${diri}*.nc)

# diro="/Users/fadhlilrizki/Documents/PhD/thesis/dataout/precip/masked/"
# echo ${file}

for i in ${file}
do
  cdo -mul ${maskfile} ${i} ${i}.masked.nc
done
