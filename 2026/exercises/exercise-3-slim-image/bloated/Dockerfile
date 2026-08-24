FROM python:3.12

RUN apt-get update
RUN apt-get install -y build-essential

WORKDIR /app
COPY . .

RUN pip install -r requirements.txt

CMD python main.py
