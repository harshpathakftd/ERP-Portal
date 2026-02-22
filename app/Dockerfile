# Base image
FROM python:3.11-slim

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy erp.txt and install dependencies
COPY erp.txt /app/
RUN pip install --upgrade pip
RUN pip install -r erp.txt

# Install Gunicorn separately (not in erp.txt)
RUN pip install gunicorn

# Copy project files
COPY . /app/

# Expose port
EXPOSE 8000

# Run Django with Gunicorn
CMD ["sh", "-c", "python manage.py migrate && gunicorn erp_project.wsgi:application --bind 0.0.0.0:8000"]