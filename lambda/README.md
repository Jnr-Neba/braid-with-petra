# AWS Lambda Functions

Serverless backend functions for the booking system.

## Functions

### booking-handler
Processes customer bookings from the website form.
- Saves to DynamoDB
- Sends WhatsApp notification
- Returns confirmation

### admin-handler
Manages booking data for the admin dashboard.
- Lists all bookings
- Updates booking status
- Password protected

## Deployment

See individual function directories for deployment instructions.
