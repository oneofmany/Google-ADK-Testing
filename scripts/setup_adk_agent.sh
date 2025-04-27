#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Prompt the user for Google Cloud project info
read -p "Enter your Google Cloud Project ID: " PROJECT_ID
read -p "Enter your Google Cloud Location (e.g., us-central1): " LOCATION

# Create the folder structure
echo "Creating folder structure..."
mkdir -p parent_folder/multi_tool_agent

# Create the files
echo "Creating files..."
touch parent_folder/multi_tool_agent/__init__.py
touch parent_folder/multi_tool_agent/agent.py
touch parent_folder/multi_tool_agent/.env

# Write into __init__.py
echo "Writing __init__.py..."
echo "from . import agent" > parent_folder/multi_tool_agent/__init__.py

# Write into .env using the entered values
echo "Writing .env..."
cat << EOF > parent_folder/multi_tool_agent/.env
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=${PROJECT_ID}
GOOGLE_CLOUD_LOCATION=${LOCATION}
EOF

# Write the Python code into agent.py
echo "Writing agent.py..."
cat << EOF > parent_folder/multi_tool_agent/agent.py
import datetime
from zoneinfo import ZoneInfo
from google.adk.agents import Agent

def get_weather(city: str) -> dict:
    """Retrieves the current weather report for a specified city.

    Args:
        city (str): The name of the city for which to retrieve the weather report.

    Returns:
        dict: status and result or error msg.
    """
    if city.lower() == "new york":
        return {
            "status": "success",
            "report": (
                "The weather in New York is sunny with a temperature of 25 degrees"
                " Celsius (41 degrees Fahrenheit)."
            ),
        }
    else:
        return {
            "status": "error",
            "error_message": f"Weather information for '\${city}' is not available.",
        }

def get_current_time(city: str) -> dict:
    """Returns the current time in a specified city.

    Args:
        city (str): The name of the city for which to retrieve the current time.

    Returns:
        dict: status and result or error msg.
    """

    if city.lower() == "new york":
        tz_identifier = "America/New_York"
    else:
        return {
            "status": "error",
            "error_message": (
                f"Sorry, I don't have timezone information for \${city}."
            ),
        }

    tz = ZoneInfo(tz_identifier)
    now = datetime.datetime.now(tz)
    report = (
        f'The current time in \${city} is \${now.strftime("%Y-%m-%d %H:%M:%S %Z%z")}'
    )
    return {"status": "success", "report": report}

root_agent = Agent(
    name="weather_time_agent",
    model="gemini-2.0-flash",
    description=(
        "Agent to answer questions about the time and weather in a city."
    ),
    instruction=(
        "You are a helpful agent who can answer user questions about the time and weather in a city."
    ),
    tools=[get_weather, get_current_time],
)
EOF

echo "Setup complete! ✅"
