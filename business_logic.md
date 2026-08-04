# Per-Trip Destination Province Fetching & Multi-Trip Pricing

When "Add another destination" is clicked, each trip (2, 3, ...) needs its own `destination-provinces` API call using the trip's `destinationFrom` province ID as `fromProvinceId`. The prices from each trip's destination selection should be summed for the subtotal, with pricing formulas varying by journey type.

## Proposed Changes

### Per-Trip Destination Province Options (GoingTo dropdown)

---

#### [MODIFY] [index.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/pages/vehicle-rental/tripInformation/index.vue)

1. **Fetch per-trip destination provinces**: Add a reactive map `tripDestinationOptionsMap` keyed by `fromProvinceId`. For trip 0, use the existing `journeyToOptions`. For trip 1+, fetch `destination-provinces` with `fromProvinceId` derived from the trip's `destinationFrom` (which came from previous trip's `goingTo`).

2. **Template**: Change `<AppSelect v-model="trip.goingTo" :options="journeyToOptions">` → `:options="getGoingToOptions(tripIndex)"` where `getGoingToOptions` returns the correct per-trip options.

3. **totalAmount**: Update to use `resolveDestinationPrice` to sum prices across all trips, then apply pricing formula (price × cars, or price × cars × days for Price/Day).

---

#### [MODIFY] [booking.service.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/services/booking.service.ts)

1. **`resolveDestinationPrice`**: Already sums prices across trips from `journeyToOptions`. Will update to also accept a `tripDestinationOptionsMap` parameter so it can find prices from per-trip destination option lists.

2. **`calculatePricing`**: Already handles Price/Day (type 5) vs others. The formula is already:
   - Price/Day: `basePrice × cars × days` 
   - Others: `basePrice × cars`
   - Total = subtotal + serviceFee (sublocation amounts)
   
   This is correct per your requirements. No change needed here.

---

#### [MODIFY] [useBookingState.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useBookingState.ts)

Add `tripDestinationOptionsMap` ref to persist per-trip destination options across pages.

---

#### [MODIFY] [customerDetails/index.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/pages/vehicle-rental/customerDetails/index.vue)

Update `vehicleBasePrice` to use `tripDestinationOptionsMap` so it can resolve prices for all trips (not just trip 0's options).

---

#### [MODIFY] [payment/index.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/pages/vehicle-rental/payment/index.vue)

Same as customerDetails — update `vehicleBasePrice` to use `tripDestinationOptionsMap`.

---

## Pricing Summary

| Journey Type | Subtotal Formula | Total Formula |
|---|---|---|
| One Way (1) | Σ(trip price) × Number of cars | Subtotal + Sublocation total |
| One Day Tour (2) | Σ(trip price) × Number of cars | Subtotal + Sublocation total |
| Round Trip (3) | Σ(trip price) × Number of cars | Subtotal + Sublocation total |
| Multi City (4) | Σ(trip price) × Number of cars | Subtotal + Sublocation total |
| Price/Day (5) | Σ(trip price) × Number of cars × Number of days | Subtotal + Sublocation total |

Where `Σ(trip price)` = sum of destination province prices from all trips.

## Verification Plan

### Manual Verification
- Select Destination From → Going To for trip 1, verify price loads from API
- Click "Add another destination", verify trip 2's Going To dropdown fetches from `destination-provinces?fromProvinceId=<trip2.destinationFrom's ID>`
- Verify total = (trip1 price + trip2 price) × cars + sublocation amounts
- Verify Price/Day type multiplies by days as well
