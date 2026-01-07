# 1 Manual tests for developed methods

## Order service

### POST: Create order
```
{
  "user_id": "user_123",
  "amount": 99.99,
  "items": [
    {"offer_id": 1, "quantity": 2}
  ]
}
```

### GET: Get all orders
`http://localhost:8002/orders/`

## Payment service
### GET: Get all payments
`http://localhost:8003/payments/`

### POST: Confirm payment
`http://localhost:8003/payments/{order_id}/confirm`


# 2 GraphQL manual testing
## Order service
### Create order
```
mutation CreateNewOrder {
  createOrder(input: {
    userId: "user_789",
    amount: "150.00",
    items: [
      { offerId: 50, quantity: 1 }
    ]
  }) {
    id
    orderStatus
    paymentStatus
  }
}
```
### Get all orders
```
query GetAllOrders {
  getOrders {
    id
    userId
    paymentId  # This should return null safely now
    items {
      offerId
    }
  }
}
```

## Payment service
```
query GetAllPayments {
  getPayments {
    id
    orderId
    userId
    amount
    paymentStatus
    transactionId
    createdAt
  }
}
```

```
mutation ConfirmMyPayment {
  confirmPayment(paymentId: 1) {
    id
    paymentStatus
    transactionId
    updatedAt
  }
}
```

## Partner service
### Get all partners
query {
  allPartners {
    id
    name
  }
}

### Create partner
mutation CreateNewPartner($input: CreatePartnerInput!) {
  createPartner(input: $input) {
    name
    active
    latitude
    longitude
    address
  }
}

{
  "input": {
    "name": "Burek Olimpija",
    "active": true,
    "latitude": 46.0569,
    "longitude": 14.5058,
    "address": "neka ulica"
  }
}

### Get nearby partners
query TestNearbyPartners($lat: Float!, $lng: Float!, $radius: Float) {
  nearbyPartners(lat: $lat, lng: $lng, radiusKm: $radius) {
    id
    name
    latitude
    longitude
  }
}

{
  "lat": 46.0569,
  "lng": 14.5058,
  "radius": 1.0
}

### Delete partner
mutation DeletePartner($id: String!) {
  deletePartner(partnerId: $id)
}

{
  "id": "0eb93319-05dc-4a46-9b49-70e6a89ec81f"
}

### Edit partner
mutation UpdateExistingPartner($id: String!, $data: PartnerUpdateInput!) {
  updatePartner(partnerId: $id, input: $data) {
    id
    name
  }
}

{
  "id": "11111111-1111-1111-1111-111111111111",
  "data": {
    "name": "Gostilnaa As"
  }
}

## Offer service
### Get all offers
query {
  getOffers {
    id
    title
    description
  }
}

### Get offer by id
query {
  offerById(offerId: 2) {
    title
    priceOriginal
    priceDiscounted
  }
}

### Create new offer
mutation CreateNewOffer($input: CreateOfferInput!) {
  createOffer(input: $input) {
    id
		title
  }
}

{
  "input": {
    "partnerId": "645de0c7-7c1e-4e61-8e51-4439ba72670a",
    "title": "Winter Special Deal",
    "priceOriginal": 50.0,
    "priceDiscounted": 35.5,
    "quantityTotal": 100,
    "quantityAvailable": 10,
    "pickupFrom": "2024-12-01T10:00:00Z",
    "pickupUntil": "2024-12-01T20:00:00Z",
    "description": "A great discount for the winter season.",
    "tenantId": "optional-override-tenant"
  }
}

### Delete offer
mutation DeleteOffer($id: Int!) {
  deleteOffer(offerId: $id)
}

{
  "id": 7
}

### Edit offer
mutation UpdateExistingOffer($id: Int!, $data: OfferUpdateInput!) {
  updateOffer(offerId: $id, input: $data) {
    id
    title
  }
}

{
  "id": 6,
  "data": {
    "title": "spremenjeno ime"
  }
}

## Notification service
### Get notifications by user
query {
  allNotifications(userId: "user_789") {
    id
    title
    message
  }
}

### Mark as read
mutation MarkNotificationAsRead {
  markRead(notificationId: 6) {
    id
		title
    message
    isRead
  }
}

# 3 Handling multi-tenancy
If nothing is provided, scheme will default to **public**.

## Postman/Thunderclient
In Header tab, add: 
- key: X-Tenant-ID
- value: tenant_1 (you can test values 1-10)

## GraphQL
In Header tab, add:
```
{"X-Tenant-ID": "tenant_1"}
```