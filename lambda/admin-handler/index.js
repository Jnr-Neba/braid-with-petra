const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand, UpdateCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: 'ca-central-1' });
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = 'braidwithpetra-bookings';

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    // CORS headers
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Admin-Password',
        'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
        'Content-Type': 'application/json'
    };
    
    // Get HTTP method (works for both API Gateway v1 and v2)
    const httpMethod = event.requestContext?.http?.method || event.httpMethod || event.requestContext?.httpMethod;
    
    console.log('HTTP Method:', httpMethod);
    
    // Handle preflight
    if (httpMethod === 'OPTIONS') {
        return {
            statusCode: 200,
            headers,
            body: ''
        };
    }
    
    try {
        // Simple password check (X-Admin-Password header)
        const adminPassword = event.headers['X-Admin-Password'] || event.headers['x-admin-password'];
        const ADMIN_PASSWORD = 'petra2026valentine'; // Change this!
        
        if (adminPassword !== ADMIN_PASSWORD) {
            return {
                statusCode: 401,
                headers,
                body: JSON.stringify({ error: 'Unauthorized - Invalid password' })
            };
        }
        
        // GET: List all bookings
        if (httpMethod === 'GET') {
            const params = {
                TableName: TABLE_NAME
            };
            
            const result = await docClient.send(new ScanCommand(params));
            
            // Sort by timestamp (newest first)
            const bookings = result.Items.sort((a, b) => {
                return new Date(b.timestamp) - new Date(a.timestamp);
            });
            
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    bookings: bookings,
                    count: bookings.length
                })
            };
        }
        
        // POST: Update booking status
        if (httpMethod === 'POST') {
            const body = JSON.parse(event.body);
            const { bookingId, status } = body;
            
            if (!bookingId || !status) {
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({ error: 'Missing bookingId or status' })
                };
            }
            
            // Validate status
            const validStatuses = ['pending', 'confirmed', 'cancelled'];
            if (!validStatuses.includes(status)) {
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({ error: 'Invalid status. Must be: pending, confirmed, or cancelled' })
                };
            }
            
            // Update booking status
            const params = {
                TableName: TABLE_NAME,
                Key: {
                    bookingId: bookingId
                },
                UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt',
                ExpressionAttributeNames: {
                    '#status': 'status'
                },
                ExpressionAttributeValues: {
                    ':status': status,
                    ':updatedAt': new Date().toISOString()
                },
                ReturnValues: 'ALL_NEW'
            };
            
            const result = await docClient.send(new UpdateCommand(params));
            
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    message: 'Booking status updated successfully',
                    booking: result.Attributes
                })
            };
        }
        
        // Method not allowed
        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ 
                error: 'Method not allowed',
                method: httpMethod 
            })
        };
        
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({ 
                error: 'Internal server error',
                message: error.message 
            })
        };
    }
};
