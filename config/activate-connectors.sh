#/bin/bash

set +x

KAFKA_CONNECT_ENDPOINT=http://localhost:8083/connectors
/etc/confluent/docker/run &
while [ $(curl -s -o /dev/null -w %{http_code} $KAFKA_CONNECT_ENDPOINT ) -ne 200 ] ; do
    echo -e "[⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳] $(date) Kafka Connect listener HTTP state: $(curl -s -o /dev/null -w %{http_code} $KAFKA_CONNECT_ENDPOINT)"
    echo "[⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳⏳] Waiting for Kafka Connect endpoint ($KAFKA_CONNECT_ENDPOINT) to be available..."
    sleep 5
done
echo -e "\n[✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓] Kafka Connect endpoint is available"
echo -e "\n[✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓] Activating Kafka S3 AVRO connector"
 curl -s -X POST -H "Content-Type: application/json" -d @config/s3-avro-connector-config.json $KAFKA_CONNECT_ENDPOINT
echo -e "\n[✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓✓] Activating Kafka S3 JSON connector"
curl -s -X POST -H "Content-Type: application/json" -d @config/s3-json-connector-config.json $KAFKA_CONNECT_ENDPOINT
sleep infinity


# curl -X DELETE $KAFKA_CONNECT_ENDPOINT/s3-avro-connector
