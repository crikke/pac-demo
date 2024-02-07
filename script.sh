#!/bin/bash
# start by getting every file that has changed checking if the uppermost directory contains a helmchart
GIT_REVISION=$(git rev-parse HEAD)
git diff --name-only GIT_REVISION GIT_REVISION~1 | while read line 
do
# check if file is Chart.Yaml

if [ test -f basename $line == "Chart.yaml" ]; do
    echo $line >> updated-helmcharts.txt

    CHART_NAME=$(cat $line | awk -F "name: " 'NF>1{print $2 }')
    CHART_VERSION=$(cat $line | awk -F "version: " 'NF>1{print $2 }')

    CHART_TAG=$CHART_NAME-$CHART_VERSION

    # check if git tag exists for chart. Should be {Chart.name-chart.version}
    if [ git rev-parse ${TAG} >/dev/null 2>&1 ]; then
    echo "tag $TAG already exist"
    else
    updated-helmcharts.txt << $line
    fi

fi 

done

# remove duplicate entries
sort updated-helmcharts.txt | uniq > updated-helmcharts.txt 