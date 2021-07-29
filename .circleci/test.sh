#!/usr/bin/env bash

RESP=$(docker exec solr1 curl http://solr1:8983/solr/tul_spotlight/admin/ping?wt=json)

STATUS=$(docker exec solr1 curl http://solr1:8983/solr/tul_spotlight/admin/ping?wt=json | jq .status)
if [ "$STATUS" != 0 ]; then
  echo "Faling because status is not OK or 0"
  echo "status: $STATUS"
  echo "response: $RESP"
  exit -1
fi
