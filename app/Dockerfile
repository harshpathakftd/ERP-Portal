# Base image
FROM python:3.11-slim

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=erp_project.settings

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency file
COPY erp.txt /app/

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r erp.txt && \
    pip install gunicorn

# Copy project
COPY . /app/

# Expose port (must match Kubernetes and Terraform)
EXPOSE 8000

# Start command
CMD ["sh", "-c", "python manage.py migrate && python manage.py collectstatic --noinput && gunicorn erp_project.wsgi:application --bind 0.0.0.0:8000"]