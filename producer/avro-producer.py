import io
import random
import avro.schema
import time
from avro.io import DatumWriter
from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer

# Kafka topic
TOPIC = "avro-topic"

# Path to user.avsc avro schema
SCHEMA_PATH = "avro-message.avsc"
SCHEMA = value_schema = avro.loads(open(SCHEMA_PATH).read())

avroProducer = AvroProducer({
    'bootstrap.servers': '192.168.1.104:19092',
    'schema.registry.url': 'http://192.168.1.104:8085'
    },  default_value_schema=SCHEMA)


while True:
    value={"key": "key-" + str(random.randint(0, 10)), "value": random.randint(0, 1000)}
    print(value)
    avroProducer.produce(topic=TOPIC, value=value)
    time.sleep(random.randint(0, 3))
