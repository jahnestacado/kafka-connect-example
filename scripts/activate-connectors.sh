#!/bin/bash

set -e

KAFKA_CONNECT_ENDPOINT=http://localhost:$CONNECT_REST_PORT/connectors
CONNECTORS_FOLDER="/connector-config"
MAX_RETRIES=10
declare -a CONNECTORS=(
# In order to activate more connectors just add their name in a new line
# NOTE that a naming convention is used for config filenames e.g name-of-connector.json
"s3-avro-connector"
"s3-json-connector"
)

function printMessage {
  message=$1
  echo -e "\n\n\n\n>>> ----------------------------------------------------------------------------------------------------------------------------------------------------\n"
  echo -e "$message \n"
  echo -e "____________________________________________________________________________________________________________________________________________________ <<<\n\n\n\n"
}

function checkAvailabilityOfConnectEndpoint {
  local retryCounter=0
  while [ $(curl -s -o /dev/null -w %{http_code} $KAFKA_CONNECT_ENDPOINT ) -ne 200 ] ; do
    retryCounter=$((retryCounter+1))
    printMessage "[⏳] Waiting for Kafka Connect endpoint ($KAFKA_CONNECT_ENDPOINT) to be available... [⏳]"

    if [ $retryCounter -gt $MAX_RETRIES ]; then
      echo "[☠] Max retries limit reached for Kafka Connect endpoint $KAFKA_CONNECT_ENDPOINT. Exiting... [☠]"
      exit 1
    fi
    sleep 10
  done
  printMessage "[✓] Kafka Connect endpoint is available [✓]"
}

function updateConnectorConfig {
  local connector=$1
  local status=$(curl -X PUT -H "Content-Type: application/json" -s -o /dev/null -w %{http_code} -d @${CONNECTORS_FOLDER}/${connector}.json "${KAFKA_CONNECT_ENDPOINT}/${connector}/config" )
  echo $status
}

function activateConnector {
  local connector=$1
  local retryCounter=0
  printMessage "[⏳] Activating Connector: $connector [⏳]"
  local status=$(updateConnectorConfig $connector)
  while [[ $status -ne 200 && $status -ne 201 ]] ; do
    status=$(updateConnectorConfig $connector)
    retryCounter=$((retryCounter+1))
    printMessage "[⏳] Failed to activate ${KAFKA_CONNECT_ENDPOINT}/${connector}/config. Status $status. $retryCounter attempts. Retrying.... [⏳]"

    if [ $retryCounter -gt $MAX_RETRIES ]; then
      printMessage "[☠] Max retries limit reached for connector $connector. Exiting... [☠]"
      exit 1
    fi
    sleep 5
  done
  printMessage "[✓] Activated Connector $connector [✓] \n\n $(curl -s ${KAFKA_CONNECT_ENDPOINT}/${connector})"
}

function setup {
  checkAvailabilityOfConnectEndpoint

  for connector in "${CONNECTORS[@]}"; do
    if [ ! -f "$CONNECTORS_FOLDER/${connector}.json" ]; then
      printMessage "[☠] Connector config file $CONNECTORS_FOLDER/${connector}.json doesn't exists! Exiting... [☠]"
      exit 1
    fi
     activateConnector $connector
  done

  printMessage "Success! Connectors activation is completed. ${CONNECTORS[*]}"

  sleep infinity
}

/etc/confluent/docker/run & setup
