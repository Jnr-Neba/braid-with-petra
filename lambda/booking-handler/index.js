const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');
const crypto = require('crypto');

const client = new DynamoDBClient({ region: 'ca-central-1' });
const docClient = DynamoDBDocumentClient.from(client);

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers: corsHeaders, body: '{}' };
    }
    
    try {
        const booking = JSON.parse(event.body);
        
        if (!booking.name || !booking.phone || !booking.service || !booking.preferredDate) {
            return {
                statusCode: 400,
                headers: corsHeaders,
                body: JSON.stringify({ success: false, message: 'Missing fields' })
            };
        }
        
        const bookingId = crypto.randomUUID();
        
        await docClient.send(new PutCommand({
            TableName: 'braidwithpetra-bookings',
            Item: {
                bookingId,
                name: booking.name.trim(),
                phone: booking.phone.trim(),
                service: booking.service,
                preferredDate: booking.preferredDate,
                preferredTime: booking.preferredTime || 'Not specified',
                notes: booking.notes || '',
                status: 'pending',
                createdAt: new Date().toISOString()
            }
        }));
        
        return {
            statusCode: 200,
            headers: corsHeaders,
            body: JSON.stringify({ success: true, bookingId, message: 'Booking created!' })
        };
        
    } catch (error) {
        return {
            statusCode: 500,
            headers: corsHeaders,
            body: JSON.stringify({ success: false, error: error.message })
        };
    }
};
