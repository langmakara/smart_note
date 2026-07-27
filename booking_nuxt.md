# Walkthrough - Place Ticket Order API Integration (`POST /mobile/bookings`) & User Profile Prefill (`GET /users/me`)

Complete summary of all file updates, data type conversions, and proxy bug fixes for integrating the **Place a New Ticket Order** feature.

---

## 1. Summary of Changes

| Action | File | Description |
| :--- | :--- | :--- |
| **[NEW]** | [user.repository.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/user.repository.ts) | Created `userRepository.getUserProfile()` targeting `GET /users/me`. |
| **[NEW]** | [booking.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/booking.ts) | Created `CreateBookingPayload` and `BookingTripPayload` TypeScript interfaces. |
| **[NEW]** | [booking.repository.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/booking.repository.ts) | Created `bookingRepository.placeBooking()` calling `/api/proxy/mobile/bookings`. |
| **[MODIFY]** | [schedule/index.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/pages/vehicle-rental/schedule/index.vue) | Prefilled **Username** and **Phone number** from `GET /users/me`. |
| **[MODIFY]** | [customerDetails/index.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/pages/vehicle-rental/customerDetails/index.vue) | Wired up the **"Pay Now"** button (`goToPayment`) to build payload from reactive state and submit to API. |
| **[MODIFY]** | [server/api/proxy/[...].ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/server/api/proxy/%5B...%5D.ts) | Fixed wildcard route stripping to handle Nuxt `app.baseURL` prefix (`/vet-car-rental/`). |

---

## 2. Key Data Mappings & Fixes

### A. User Profile & Customer ID (`GET /users/me`)
- **Username & Phone**: Automatically prefilled in `schedule/index.vue` from `userResponse.value?.data`.
- **`customerId`**: Extracted directly from `userResponse.value?.data?.id` as a numeric ID.

---

### B. Java Byte Deserialization Fixes
To resolve backend `java.lang.Byte` deserialization errors:
- **`rentalServiceType`**: Converted from `"Vehicle Rental"` string $\rightarrow$ numeric Byte `1`.
- **`journeyType`**: Converted from `"One Way"` string $\rightarrow$ numeric Byte `1` (`2` for Round Trip, `3` for Multi City).
- **`passengerNationalityId`**: Guaranteed numeric `number` (e.g. `3`).
- **`amountOfPeople` & `amountOfVehicles`**: Explicitly cast with `Number(...)` (e.g. `1`).

---

### C. Date and Time Formats
- **`startDate` & `endDate`**: Format `YYYY-MM-DD` (e.g. `"2026-07-27"`).
- **`pickupTime` & `dropoffTime`**: Format `YYYY-MM-DD HH:mm:ss` (e.g. `"2026-07-28 15:13:00"`), including seconds `:00` at index 16 to satisfy Java `LocalDateTime` parsing.

---

### D. Location Resolution
- **`pickupLocationId`**: Resolved to numeric ID from `trips[0].destinationFrom` (fallback to `pickupLocation`).
- **`dropoffLocationId`**: Resolved to numeric ID from `trips[last].goingTo` (fallback to `dropoffLocation`).

---

## 3. Full Final JSON Payload Example

```json
{
  "customerId": 1,
  "vehicleId": 1,
  "passengerName": "super_admin",
  "passengerPhone": "012345678",
  "passengerNationalityId": 3,
  "amountOfPeople": 1,
  "amountOfVehicles": 1,
  "remark": "",
  "rentalServiceType": 1,
  "vehicleRentalTypeId": 1,
  "journeyType": 1,
  "startDate": "2026-07-27",
  "endDate": "2026-07-27",
  "pickupLocationId": 12,
  "pickupTime": "2026-07-28 15:13:00",
  "dropoffLocationId": 45,
  "dropoffTime": "2026-07-28 15:13:00",
  "subtotalAmount": 150,
  "serviceFee": 0,
  "taxAmount": 0,
  "totalAmount": 150,
  "paymentType": "PENDING",
  "paymentStatus": "UNPAID",
  "currency": "USD",
  "receiptFileName": "",
  "receiptFileUrl": "",
  "receiptDescription": "",
  "trips": [
    {
      "fromLocationId": 12,
      "toLocationId": 45,
      "price": 150,
      "sortOrder": 1,
      "status": 1
    }
  ]
}
```
