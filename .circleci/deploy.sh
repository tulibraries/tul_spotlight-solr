#!/usr/bin/env bash
set -e
validate_status() {
  echo "response: $RESP"
  STATUS=$(echo "$RESP" | grep HTTP | awk '{print $2}')
  if [[  "$STATUS" != "200" ]]; then
    echo "Failing because status was not 200"
    echo "status: $STATUS"
    exit 1
  fi
}
validate_create() {
  echo "response: $RESP"
  STATUS=$(echo "$RESP")
  if [[  "$STATUS" != "201" ]]; then
    echo "Failing because status was not 201"
    echo "status: $STATUS"
    exit 1
  fi
}
echo
echo "***"
echo "* Sending tul_spotlight-$CIRCLE_TAG configs to SolrCloud."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" --data-binary @/home/circleci/solrconfig.zip "https://solrcloud.tul-infra.page/solr/admin/configs?action=UPLOAD&name=tul_spotlight-$CIRCLE_TAG")
validate_status
echo
echo "***"
echo "* Creating new tul_spotlight-$CIRCLE_TAG collection"
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X GET --header 'Accept: application/json' "https://solrcloud.tul-infra.page/solr/admin/collections?action=CREATE&name=tul_spotlight-$CIRCLE_TAG&numShards=1&replicationFactor=2&maxShardsPerNode=1&collection.configName=tul_spotlight-$CIRCLE_TAG")
validate_status
echo
echo "***"
echo "* Creating qa alias based on configset name."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" "https://solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_spotlight-$CIRCLE_TAG-qa&collections=tul_spotlight-$CIRCLE_TAG")
validate_status
echo "***"
echo "* Creating prod alias based on configset name."
echo "***"
RESP=$(curl -u $SOLR_USER:$SOLR_PASSWORD -i -o - --silent -X POST --header "Content-Type:application/octet-stream" "https://solrcloud.tul-infra.page/solr/admin/collections?action=CREATEALIAS&name=tul_spotlight-$CIRCLE_TAG-prod&collections=tul_spotlight-$CIRCLE_TAG")
validate_status
echo "***"
echo "* Pushing zip file asset to GitHub release."
echo "***"
RELEASE_ID=$(curl "https://api.github.com/repos/tulibraries/tul_spotlight-solr/releases/latest" | jq .id)
RESP=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: token $GITHUB_TOKEN" --data-binary @/home/circleci/solrconfig.zip -H "Content-Type: application/octet-stream" "https://uploads.github.com/repos/tulibraries/tul_spotlight-solr/releases/$RELEASE_ID/assets?name=tul_spotlight-$CIRCLE_TAG.zip")
validate_create
