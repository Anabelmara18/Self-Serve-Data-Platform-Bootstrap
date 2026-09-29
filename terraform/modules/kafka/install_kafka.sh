#!/bin/bash
set -e

# Install Java
dnf install -y java-17-amazon-corretto

# Download Kafka
cd /opt
curl -O https://archive.apache.org/dist/kafka/3.8.0/kafka_2.13-3.8.0.tgz
tar -xzf kafka_2.13-3.8.0.tgz
mv kafka_2.13-3.8.0 kafka
cd kafka

# Limit JVM heap to fit t3.micro's 1GB RAM
export KAFKA_HEAP_OPTS="-Xmx400m -Xms400m"

# Get this instance's public IP dynamically (works for whatever IP AWS assigns)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Generate a cluster UUID for KRaft
KAFKA_CLUSTER_ID=$(bin/kafka-storage.sh random-uuid)

# Configure KRaft
sed -i "s|log.dirs=/tmp/kraft-combined-logs|log.dirs=/opt/kafka/data|" config/kraft/server.properties
sed -i "s|advertised.listeners=PLAINTEXT://localhost:9092|advertised.listeners=PLAINTEXT://${PUBLIC_IP}:9092|" config/kraft/server.properties

# Format storage
bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/kraft/server.properties

# Start Kafka
bin/kafka-server-start.sh -daemon config/kraft/server.properties

echo "Kafka install complete" > /var/log/kafka-install.log