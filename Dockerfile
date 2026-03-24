FROM python:3.12-slim AS builder

WORKDIR /app

# Install Python dependencies in a dedicated virtual environment.
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY erp.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r erp.txt


FROM python:3.12-slim AS runtime

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

# Copy virtual environment from builder and then project code.
COPY --from=builder /opt/venv /opt/venv
COPY . .

EXPOSE 8000

CMD ["sh", "-c", "python manage.py migrate && gunicorn erp_project.wsgi:application --bind 0.0.0.0:8000"]
