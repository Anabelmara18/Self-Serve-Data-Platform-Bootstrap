import json
import random
import time
from datetime import datetime, timezone
from kafka import KafkaProducer

# --- Config ---
KAFKA_BROKER = "13.222.103.18:9092"
TOPIC = "sensor-readings"
RUN_SECONDS = 60

SENSOR_TYPES = {
    "temperature": {"unit": "celsius", "range": (-10, 40)},
    "humidity": {"unit": "percent", "range": (0, 100)},
    "vibration": {"unit": "hz", "range": (0, 10)},
}

LOCATIONS = ["warehouse_a_zone_1", "warehouse_a_zone_2", "warehouse_a_zone_3", "cold_storage_1"]

NUM_SENSORS = 10
sensors = [
    {
        "sensor_id": f"sensor_{i:03d}",
        "sensor_type": random.choice(list(SENSOR_TYPES.keys())),
        "location": random.choice(LOCATIONS),
        "battery_level": 100,
    }
    for i in range(NUM_SENSORS)
]

def generate_reading(sensor, inject_messiness=True):
    sensor_type = sensor["sensor_type"]
    low, high = SENSOR_TYPES[sensor_type]["range"]
    unit = SENSOR_TYPES[sensor_type]["unit"]

    reading = {
        "sensor_id": sensor["sensor_id"],
        "sensor_type": sensor_type,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "value": round(random.uniform(low, high), 2),
        "unit": unit,
        "location": sensor["location"],
        "battery_level": sensor["battery_level"],
    }

    # Deliberate messiness, ~10% of readings
    if inject_messiness and random.random() < 0.10:
        glitch = random.choice(["out_of_range", "missing_field", "null_value", "duplicate_ts"])
        if glitch == "out_of_range":
            reading["value"] = round(random.uniform(500, 999), 2)
        elif glitch == "missing_field":
            del reading["location"]
        elif glitch == "null_value":
            reading["value"] = None
        elif glitch == "duplicate_ts":
            reading["timestamp"] = sensor.get("_last_ts", reading["timestamp"])

    sensor["_last_ts"] = reading["timestamp"]
    sensor["battery_level"] = max(0, sensor["battery_level"] - random.uniform(0, 0.05))

    return reading

def main():
    producer = KafkaProducer(
        bootstrap_servers=KAFKA_BROKER,
        value_serializer=lambda v: json.dumps(v).encode("utf-8"),
        max_block_ms=10000,
        request_timeout_ms=10000,
    )

    print(f"Producing sensor readings to '{TOPIC}' for {RUN_SECONDS} seconds...", flush=True)
    start_time = time.time()
    sent = 0
    try:
        while time.time() - start_time < RUN_SECONDS:
            for sensor in sensors:
                producer.send(TOPIC, value=generate_reading(sensor))
                sent += 1
            producer.flush(timeout=10)
            time.sleep(2)
    finally:
        producer.close(timeout=10)
        print(f"Producer finished. Sent {sent} readings.", flush=True)

if __name__ == "__main__":
    main()