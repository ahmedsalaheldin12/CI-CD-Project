FROM python:3
WORKDIR /opt
COPY . .
RUN pip install -r requirements.txt
EXPOSE 8000
CMD ["python3","hello.py"]