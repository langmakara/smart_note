# Summary of API Integration & Component Updates

This document summarizes all updates applied to align the Vehicle Rental feature with the latest backend API specifications.

---

## 1. Type Contract Updates (`app/types/api.d.ts`)

[api.d.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/api.d.ts)

### Added / Updated Interfaces:
- **`RawVehicleItem`**: Updated with backend fields: `brandId`, `brandName`, `modelId`, `modelName`, `quantity`, `isPublic`, `categories`, `rentalTypes`, and creation timestamps.
- **`VehicleListParams`**: Updated POST request body contract:
  ```json
  {
    "page": 1,
    "size": 10,
    "keyword": "string",
    "sortBy": "string",
    "brandId": 0,
    "modelId": 0,
    "categoryId": 0,
    "rentalTypeId": 0,
    "guests": 0,
    "rating": 0
  }
  ```
- **`PaginatedVehicleData`**: Added `{ data: RawVehicleItem[], total: number }` wrapper.
- **`RawVehicleDetailData`**: Updated for `GET /mobile/catalog/vehicles/{id}` with:
  - `averageRating`, `totalReviews`, `passengers`, `ratingBreakdown` (`Record<string, number>`)
  - `slides` (`RawVehicleSlideItem[]`), `facilities` (`RawVehicleFacilityItem[]`), `items` (`RawVehicleItemUnit[]`), `recentReviews`
- **`VehicleReviewsParams`**: Updated POST request body for `POST /mobile/catalog/vehicles/{id}/reviews`:
  ```json
  {
    "page": 1,
    "size": 10,
    "keyword": "string",
    "sortBy": "string",
    "dateFrom": "string",
    "dateTo": "string",
    "customerId": 0,
    "vehicleId": 0,
    "salesOrderId": 0
  }
  ```

---

## 2. Repository Layer Updates (`app/apis/vehicleRental.repository.ts`)

[vehicleRental.repository.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/vehicleRental.repository.ts)

- **`getVehicles`**: Changed method to send request options via `body: params` instead of query params. Used `toValue(params)` to safely unwrap Vue refs before computing unique cache keys, fixing circular reference errors (`JSON.stringify`).
- **`getVehicleReviews`**: Updated `POST /mobile/catalog/vehicles/{id}/reviews` to send payload via `body: params` and safely unwrap reactive refs.

---

## 3. Vehicle List Page (`app/components/vehicle-rental/VehicleListPage.vue`)

[VehicleListPage.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/components/vehicle-rental/VehicleListPage.vue)

- **Reactive Request Body**: Built a reactive `requestPayload` computed property containing `page`, `size`, `keyword`, `sortBy`, `brandId`, `modelId`, `categoryId`, `rentalTypeId`, `guests`, and `rating`.
- **Response Parsing**: Handled both paginated `{ data: { data: [...], total: n } }` and direct array response shapes.
- **Image URL Resolution**: Automated prepending of `baseUrl` to relative `fileUrl` values (e.g., `/uploads/...`).

---

## 4. Vehicle Detail Page (`app/pages/vehicle-rental/bookDetail/index.vue`)

[index.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/pages/vehicle-rental/bookDetail/index.vue)

- **Slide Image Swiper**: Extracted slide images directly from `data.slides` sorted by `sortOrder` ascending.
- **Asset Helper (`formatImageUrl`)**: Fixed URL resolver to prepend `baseUrl` to relative `/uploads/...` image paths.
- **Detail Fields Mapping**:
  - `name`: Maps `nameEn || nameKh || modelName || brandName`.
  - `rating`: Uses `averageRating`.
  - `reviewsCount`: Uses `totalReviews`.
  - `passengers`: Uses `passengers` or `quantity`.
  - `facilities`: Resolves `facilityNameEn` / `facilityNameKh`.
- **Reviews Payload**: Added reactive payload matching the requested POST body schema for vehicle reviews.

---

## Verification
- Clean compilation and TypeScript type generation executed via `pnpm postinstall` (`nuxt prepare`).
