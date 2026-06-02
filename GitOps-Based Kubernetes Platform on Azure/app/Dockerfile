# Base python image
FROM python:3.14.3

# Set working dir
WORKDIR /app

# Copy and install all dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app code
COPY app.py .

# Copy fake inserts
COPY fake_products_insert.sql /app/
COPY fake_users_insert.sql /app/

# Expose 5000 port
EXPOSE 5000

# Run the app
CMD [ "python", "app.py" ]