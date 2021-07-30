#!/usr/bin/env bash
STATUS=$(docker exec solr1 curl http://solr1:8983/solr/tul_spotlight/admin/ping?wt=json | jq .status)
if [ "$STATUS" != '"OK"' ]; then
  echo "Failing because status is not OK"
  echo "status: $STATUS"
  exit -1
fi
