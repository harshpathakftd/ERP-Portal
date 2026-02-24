# Base image

FROM python:3.11-slim

# Environment settings

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DJANGO_SETTINGS_MODULE=erp_project.settings

# Set working directory

WORKDIR /app

# Install system dependencies

RUN apt-get update && apt-get install -y 
build-essential 
gcc 
netcat-openbsd 
&& apt-get clean 
&& rm -rf /var/lib/apt/lists/*

# Upgrade pip

RUN pip install --upgrade pip

# Copy dependency file

COPY erp.txt .

# Install Python dependencies

RUN pip install --no-cache-dir -r erp.txt && 
pip install --no-cache-dir gunicorn

# Copy project files

COPY . .

# Expose port (must match Kubernetes and Terraform)

EXPOSE 8000

# Start Django production server

CMD sh -c "python manage.py migrate --noinput && python manage.py collectstatic --noinput && gunicorn erp_project.wsgi:application --bind 0.0.0.0:8000 --workers 3"
