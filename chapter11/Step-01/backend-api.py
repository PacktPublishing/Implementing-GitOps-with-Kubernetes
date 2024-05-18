from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)

@app.route('/weather', methods=['GET'])
def get_weather():
    city = request.args.get('city', 'Zurich')   # Default to Zurich if no city parameter is provided
    api_key = os.getenv('WEATHER_API_KEY')      # Get the API key from the environment variables
    if not api_key:
        return jsonify({'error': 'API key is not configured'}), 500

    url = f"http://api.weatherapi.com/v1/current.json"
    params = {
        'key': api_key,
        'q': city,
        'aqi': 'no'                             # Air quality data is not needed for this basic example
    }
    response = requests.get(url, params=params)
    if response.status_code != 200:
        return jsonify({'error': 'Failed to fetch weather data'}), response.status_code

    return jsonify(response.json())

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
