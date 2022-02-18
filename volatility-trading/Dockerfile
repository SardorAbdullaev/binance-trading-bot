# It must use alpine3.12; otherwise, it won't work in Raspberry Pi 32bit.
FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY . .

CMD [ "python", "main.py"]

