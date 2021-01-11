#/bin/bash

bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9200)" != "200" ]] ;do sleep 5 ; echo "waiting for es server to come up ....."; done'

curl -X DELETE http://localhost:9200/scg_es_product_th
curl -X DELETE http://localhost:9200/scg_es_product_en
curl -X DELETE http://localhost:9200/address_en
curl -X DELETE http://localhost:9200/address_th

curl -X PUT \
  http://localhost:9200/scg_es_product_th \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 2fe4f2a3-a921-4278-9e4f-625561123f66' \
  -H 'cache-control: no-cache' \
  -d '{
            "index.mapping.total_fields.limit": 2000
          }'

curl -X PUT \
  http://localhost:9200/scg_es_product_en \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 2fe4f2a3-a921-4278-9e4f-625561123f66' \
  -H 'cache-control: no-cache' \
  -d '{
            "index.mapping.total_fields.limit": 2000
          }'

curl -X PUT \
  http://localhost:9200/address_en \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 2fe4f2a3-a921-4278-9e4f-625561123f66' \
  -H 'cache-control: no-cache' \
  -d '{
            "index.mapping.total_fields.limit": 2000
          }'

curl -X PUT \
  http://localhost:9200/address_th \
  -H 'Content-Type: application/json' \
  -H 'Postman-Token: 2fe4f2a3-a921-4278-9e4f-625561123f66' \
  -H 'cache-control: no-cache' \
  -d '{
            "index.mapping.total_fields.limit": 2000
          }'

# Import ES Dumps
# MAPPING PUSH TO ES
elasticdump --input=$WORKSPACE/address_en_mapping.json --output=http://localhost:9200/address_en --type=mapping
sleep 2
elasticdump --input=$WORKSPACE/address_th_mapping.json --output=http://localhost:9200/address_th --type=mapping
sleep 2
tput setaf 14
echo "address_en data import in process ...."
elasticdump --quiet --input=$WORKSPACE/address_en_data.json --output=http://localhost:9200/address_en --type=data
sleep 2
echo "address_th data import in process ...."
elasticdump --quiet --input=$WORKSPACE/address_th_data.json --output=http://localhost:9200/address_th --type=data

echo ""
tput sgr0
# DATA PUSH TO ES

sleep 2
elasticdump --input=$WORKSPACE/scg_es_product_en_mapping.json --output=http://localhost:9200/scg_es_product_en --type=mapping
sleep 2
elasticdump --input=$WORKSPACE/scg_es_product_th_mapping.json --output=http://localhost:9200/scg_es_product_th --type=mapping
sleep 2
tput setaf 14
echo "scg_es_product_en data import in process ...."
elasticdump --quiet --input=$WORKSPACE/scg_es_product_en_data.json --output=http://localhost:9200/scg_es_product_en --type=data
sleep 2
echo "scg_es_product_th data import in process ...."
elasticdump --quiet --input=$WORKSPACE/scg_es_product_th_data.json --output=http://localhost:9200/scg_es_product_th --type=data
echo ""
tput sgr0

zip -r $WORKSPACE/estransdata.zip /tmp/esdata/*

aws s3 cp $WORKSPACE/estransdata.zip s3://development-import-export/setup-data/
