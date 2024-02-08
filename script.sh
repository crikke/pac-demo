#!/bin/bash

# start by getting every file that has changed checking if the uppermost directory contains a helmchart
GIT_REVISION=$(git rev-parse HEAD)
git diff --name-only $GIT_REVISION $GIT_REVISION~1 | while read CHART
do
    # check if file is Chart.Yaml
    if [ $(basename $CHART) == "Chart.yaml" ]; then

        CHART_NAME=$(cat $CHART | awk -F "name: " 'NF>1{print $2 }')
        CHART_VERSION=$(cat $CHART | awk -F "version: " 'NF>1{print $2 }')

        CHART_TAG=$CHART_NAME-$CHART_VERSION
        CHART_DIR=$(dirname $CHART)
        echo $CHART_TAG;
        echo $CHART_DIR;


        # check if git tag exists for chart. Should be {Chart.name-chart.version}
        if [ git rev-parse ${TAG} >/dev/null 2>&1 ]; then
            echo "chart version $TAG already exist, wont push helmchart ";
            continue
        fi

        CHART_PACKAGE=$(helm package --version $CHART_VERSION -u $CHART_DIR | cut -d":" -f2 | tr -d '[:space:]')
        echo $CHART_PACKAGE

         if [ $(params.CUSTOM_CA_PATH) != "" ]; then
            curl -u "${REG_USER}":"${REG_PASSWORD}" $(params.REGISTRY) --upload-file "$CHART_PACKAGE" --cacert $(params.CUSTOM_CA_PATH)
        else
            curl -u "${REG_USER}":"${REG_PASSWORD}" $(params.REGISTRY) --upload-file "$CHART_PACKAGE" 
        fi

        git tag -am "Bump version to $(CHART_TAG)" $(CHART_TAG)

    fi

done

git push --tags
