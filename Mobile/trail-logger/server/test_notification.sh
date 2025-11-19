#!/bin/bash

# Read config
CONFIG_FILE="../app/config.json"
SERVER_IP=$(grep -o '"serverIp": *"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
API_URL="http://$SERVER_IP:8080"

echo "Server: $API_URL"
echo ""

# Get credentials
read -p "Email: " EMAIL
read -s -p "Password: " PASSWORD
echo ""

# Login
echo "Logging in..."
RESPONSE=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

TOKEN=$(echo "$RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Login failed: $RESPONSE"
  exit 1
fi

echo "Login successful!"
echo ""

# Get trails
echo "Fetching trails..."
TRAILS=$(curl -s -X GET "$API_URL/api/trails" \
  -H "Authorization: Bearer $TOKEN")

echo "$TRAILS" | grep -o '"id":[0-9]*,"name":"[^"]*"' | head -5
echo ""

# Get trail ID to update
read -p "Enter trail ID to update: " TRAIL_ID

# Update trail
echo "Updating trail $TRAIL_ID..."
UPDATE_RESPONSE=$(curl -s -X PUT "$API_URL/api/trail?id=$TRAIL_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test Update $(date +%H:%M:%S)\",\"distance\":10.0,\"difficulty\":\"hard\",\"status\":\"completed\"}")

echo "Response: $UPDATE_RESPONSE"
echo ""
echo "Check your app for the notification!"
