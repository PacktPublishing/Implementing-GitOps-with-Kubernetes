#!/bin/bash

# Base URL of your weather service
baseUrl="http://[PUBLIC_IP]/weather"

# Array of cities
cities=("New York" "London" "Paris" "Berlin" "Tokyo" "Sydney" "Moscow" "Cairo" "Rio de Janeiro" "Johannesburg")

# Function to get a random city from the list
function get_random_city {
  echo ${cities[$RANDOM % ${#cities[@]}]}
}

# Infinite loop to continuously send requests
while true; do
  # Select a random city from the list
  randomCity=$(get_random_city)

  # Generate a random number for the cache buster
  cacheBuster=$((RANDOM % 10000))

  # Construct the full URL with the city and cache buster
  url="${baseUrl}?city=${randomCity}&cb=${cacheBuster}"

  # Send the HTTP GET request
  response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET $url)

  # Extract the body and the status
  httpBody=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
  httpStatus=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

  # Optional: Print the status code and response body
  echo "Status Code: $httpStatus"
  echo "Response Body: $httpBody"

  # Wait for 100  milliseconds before sending the next request.
  sleep 0.1
done
