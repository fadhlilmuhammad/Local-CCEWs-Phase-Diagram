#!/bin/bash

#PBS -l ncpus=8
#PBS -l walltime=120:00
#PBS -l mem=40gb
#PBS -q normalbw
#PBS -lstorage=gdata/v46+gdata/w40+gdata/rt52

module load cdo
start=$(date +%s)
echo "Getting data..."

c=1980

while [ $c -le 2019 ]
do
  for i in $(ls /g/data/rt52/pressure-levels/reanalysis/v/${c}/)
  do
    cdo -b F32 -f nc4 remapcon2,r144x73 -daymean -sellevel,100,200,250,300,400,500,600,700,850,925,1000 ${i} /g/data/w40/fm6730/${i}.daily.nc
  done
done

end=$(date +%s)


echo "Elapsed Time: $(($end-$start)) seconds"
