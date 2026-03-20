#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo "Welcome to Salon Appointment Scheduler"

# Function to display services and get a valid selection
get_service() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read ID NAME
  do
    echo "$ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    echo "Please select a valid service."
    get_service   # call itself again until valid
  fi
}

# Call function to get service
get_service

# Ask for customer phone
echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If new customer, ask for name and insert
if [[ -z $CUSTOMER_NAME ]]; then
  echo "I don't have a record for that phone. What's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
fi

# Ask for appointment time
echo "What time would you like your appointment?"
read SERVICE_TIME

# Insert appointment
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Confirm
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
