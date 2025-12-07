# Use a slim version of Python 3.10
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
# gcc and build-essential are often required for compiling some ML libraries (like numpy/pandas extensions)
RUN apt-get update && apt-get install -y \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application
# Assumes FastAPI structure: 'app' folder -> 'main.py' file -> 'app' instance
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]