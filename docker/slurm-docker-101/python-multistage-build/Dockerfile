FROM python:3.8.20-bookworm AS builder

WORKDIR /app

# Create virtual environment and install dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.8.20-slim

WORKDIR /app

RUN apt-get update && apt-get install -y libpq5 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r app && \
    useradd -r -g app app && \
    chown -R app:app /app

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY . .

ENV FLASK_APP=src/app.py

EXPOSE 8000
USER app
CMD ["sh", "-c", "python /app/setup.py && flask run --host=0.0.0.0 --port=8000"]
