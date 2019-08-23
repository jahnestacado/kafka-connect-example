import io
import random
import time
from confluent_kafka import Producer
import json

# Kafka topic
TOPIC = "json-topic"

producer = Producer({
    'bootstrap.servers': 'localhost:19092',
    })


while True:
    value=json.dumps({"key": "key-" + str(random.randint(0, 10)), "value": random.randint(0, 1000)})
    print(value)
    producer.produce(TOPIC, value.encode('utf-8'))
    time.sleep(random.randint(0, 5))
