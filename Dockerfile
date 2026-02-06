# Use the required base image
FROM python:3.9-slim

# Create working directory
WORKDIR /app

# Install system dependencies (optional but often needed for builds)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
 && rm -rf /var/lib/apt/lists/*

# Copy dependency list first (better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code (THIS is what you were missing)
COPY . .

# Create a non-root user and give ownership of the app directory
RUN useradd -m -u 1000 theia \
 && chown -R theia:theia /app

# Switch to non-root user (THIS is what you were missing)
USER theia

# Expose the service port
EXPOSE 8080

# Run the service (THIS is what you were missing)
# If your app entrypoint differs, adjust "service:app" to match your project.
CMD ["gunicorn", "--bind=0.0.0.0:8080", "--log-level=info", "service:app"]
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY service/ ./service/

RUN useradd --uid 1000 theia && chown -R theia /app
USER theia

EXPOSE 8080
CMD ["gunicorn", "--bind=0.0.0.0:8080", "--log-level=info", "service:app"]
