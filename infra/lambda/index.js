/**
 * Lambda function to process room messages from EventBridge
 * This is a POC - just logs the received data
 */
exports.handler = async (event) => {
  console.log('=== Room Message Lambda Handler Started ===');
  console.log('Event received:', JSON.stringify(event, null, 2));

  try {
    // Extract the message from EventBridge event
    const detail = event.detail;
    
    console.log('=== Room Message Details ===');
    console.log('Email 1:', detail.email1);
    console.log('Email 2:', detail.email2);
    console.log('Room ID:', detail.roomId);
    console.log('Timestamp:', detail.timestamp);
    console.log('===========================');

    // For POC purposes, we just log the data
    // In production, this would trigger actual business logic
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Room message processed successfully',
        data: detail,
      }),
    };
  } catch (error) {
    console.error('Error processing room message:', error);
    
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Error processing room message',
        error: error.message,
      }),
    };
  }
};

