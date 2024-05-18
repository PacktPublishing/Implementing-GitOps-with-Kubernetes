# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

RUN ls -la

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 80 available to the world outside this container
# EXPOSE 5000
EXPOSE 80

# Define environment variable to store the API key
ENV WEATHER_API_KEY=NOT_VALID_KEY

# Run app.py when the container launches
CMD ["python", "backend-api.py"]
