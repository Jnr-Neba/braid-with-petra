// Mock AWS SDK BEFORE requiring handler
const mockSend = jest.fn();
jest.mock('@aws-sdk/client-dynamodb', () => ({
  DynamoDBClient: jest.fn()
}));

jest.mock('@aws-sdk/lib-dynamodb', () => ({
  DynamoDBDocumentClient: {
    from: jest.fn(() => ({
      send: mockSend
    }))
  },
  PutCommand: jest.fn((params) => params)
}));

const { handler } = require('./index');

describe('Lambda Booking Handler', () => {
  
  beforeEach(() => {
    mockSend.mockClear();
  });

  test('should handle OPTIONS request (CORS preflight)', async () => {
    const event = {
      httpMethod: 'OPTIONS'
    };

    const result = await handler(event);

    expect(result.statusCode).toBe(200);
    expect(result.headers['Access-Control-Allow-Origin']).toBe('*');
  });

  test('should return 400 when required fields are missing', async () => {
    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'John Doe'
        // Missing phone, service, preferredDate
      })
    };

    const result = await handler(event);

    expect(result.statusCode).toBe(400);
    expect(JSON.parse(result.body).success).toBe(false);
    expect(JSON.parse(result.body).message).toBe('Missing fields');
  });

  test('should successfully create booking with all required fields', async () => {
    mockSend.mockResolvedValue({});

    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Jane Smith',
        phone: '555-1234',
        service: 'Box Braids',
        preferredDate: '2026-03-15'
      })
    };

    const result = await handler(event);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body).success).toBe(true);
    expect(JSON.parse(result.body).bookingId).toBeDefined();
    expect(mockSend).toHaveBeenCalled();
  });

  test('should handle optional fields (preferredTime, notes)', async () => {
    mockSend.mockResolvedValue({});

    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Alice Johnson',
        phone: '555-5678',
        service: 'Cornrows',
        preferredDate: '2026-03-20',
        preferredTime: '2:00 PM',
        notes: 'Please call before appointment'
      })
    };

    const result = await handler(event);

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body).success).toBe(true);
  });

  test('should return 500 on database error', async () => {
    mockSend.mockRejectedValue(new Error('Database error'));

    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Bob Wilson',
        phone: '555-9999',
        service: 'Locs',
        preferredDate: '2026-03-25'
      })
    };

    const result = await handler(event);

    expect(result.statusCode).toBe(500);
    expect(JSON.parse(result.body).success).toBe(false);
    expect(JSON.parse(result.body).error).toBe('Database error');
  });

  test('should trim whitespace from name and phone', async () => {
    mockSend.mockResolvedValue({});

    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: '  Trimmed Name  ',
        phone: '  555-1111  ',
        service: 'Braids',
        preferredDate: '2026-04-01'
      })
    };

    const result = await handler(event);

    expect(result.statusCode).toBe(200);
    
    // Verify the data sent to DynamoDB
    const callArgs = mockSend.mock.calls[0][0];
    expect(callArgs.Item.name).toBe('Trimmed Name');
    expect(callArgs.Item.phone).toBe('555-1111');
  });

  test('should set status to pending and include createdAt timestamp', async () => {
    mockSend.mockResolvedValue({});

    const event = {
      httpMethod: 'POST',
      body: JSON.stringify({
        name: 'Test User',
        phone: '555-0000',
        service: 'Test Service',
        preferredDate: '2026-04-15'
      })
    };

    const result = await handler(event);

    expect(result.statusCode).toBe(200);
    
    const callArgs = mockSend.mock.calls[0][0];
    expect(callArgs.Item.status).toBe('pending');
    expect(callArgs.Item.createdAt).toBeDefined();
    expect(callArgs.Item.bookingId).toBeDefined();
  });
});
