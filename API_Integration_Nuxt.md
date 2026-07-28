# API Integration Documentation - VET Car Rental App

This document provides a comprehensive guide to the API architecture, HTTP client setup, domain repositories, authentication mechanism, and proxy forwarding implemented in the **VET Car Rental Customer App** (Nuxt 4 / Vue 3 / Ionic).

---

## 📐 1. Architecture Overview

The API integration follows a clean **Repository & Proxy Architecture**:

```
 ┌─────────────────────────────────────────────────────────────┐
 │                       Vue / Nuxt Page                       │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Calls Domain Repository Methods
 ┌──────────────────────────────▼──────────────────────────────┐
 │                      Domain Repositories                    │
 │  (vehicleRental.repository, booking.repository, etc.)        │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Uses `useApiClient`
 ┌──────────────────────────────▼──────────────────────────────┐
 │                    `useApiClient` Composable                │
 │    - Wraps Nuxt `useFetch`                                  │
 │    - Auto-injects Authorization Bearer token                │
 │    - Intercepts errors (e.g. 401 handling)                  │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Hits local proxy path `/api/proxy/...`
 ┌──────────────────────────────▼──────────────────────────────┐
 │             Nitro Server Proxy (`server/api/proxy/[...].ts`) │
 │    - Resolves backend URL via `resolveApiBaseUrl()`         │
 │    - Forwards requests to remote backend                    │
 │    - Prevents CORS issues & conceals API server endpoints   │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Forwarded HTTP Request
 ┌──────────────────────────────▼──────────────────────────────┐
 │                       Backend REST API                      │
 └─────────────────────────────────────────────────────────────┘
```

### Key Architectural Benefits:
- **No CORS Issues**: Client requests hit local `/api/proxy/...` routes, which Nitro forwards server-to-server to the target API.
- **Environment Agnostic**: Server and Client dynamically select environment base URLs (`dev`, `qa`, `local`, `production`).
- **Centralized Authorization**: Bearer tokens are attached automatically in `useApiClient` without redundant boilerplates in pages.
- **Strict Type Safety**: All requests, responses, and query payloads use centralized TypeScript interfaces defined in `app/types/`.

---

## 🛠️ 2. Core HTTP Client (`useApiClient`)

**Location:** [`app/apis/index.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/index.ts)

The base HTTP client is a custom composable wrapping Nuxt's `useFetch`.

```typescript
export const useApiClient = <T = any>(
  request: Parameters<typeof useFetch<T>>[0],
  opts?: ApiClientOptions<T>
) => {
  const { getToken } = useAuthToken()
  // Attaches Bearer Authorization token to headers
  // Handles 401 Unauthorized response logs
  // Returns Nuxt useFetch composable result ({ data, pending, error, refresh })
}
```

### Features:
1. **Token Injection**: Calls `useAuthToken().getToken()` on every request and sets `Authorization: Bearer <token>`.
2. **Error Interception**: Checks response status; logs warnings when receiving `401 Unauthorized` for token refresh or re-authentication handling.
3. **Response Structure Support**: Returns reactive `{ data, pending, error, refresh }` variables standard in Nuxt applications.

---

## 🛡️ 3. Authentication & Token Management

**Location:** [`app/composables/useAuthToken.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useAuthToken.ts)

- **Single Source of Truth**: Uses Nuxt `useCookie("access_token")` (valid for 7 days, path `/`) for universal SSR/CSR support.
- **LocalStorage Sync**: On client-side navigation, fallback tokens are synchronized with `localStorage.getItem("access_token")`.
- **Mobile WebView Bridge Integration**: [`nuxt.config.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/nuxt.config.ts) injects a global JS handler `window.setMobileToken(token)` to support token passing from Flutter or native Android WebViews.

---

## 🌐 4. Environment Configuration & URL Resolution

**Configuration File:** [`nuxt.config.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/nuxt.config.ts)

### Environment Variables (`.env`)
```env
VITE_NODE_ENV=dev
VITE_APP_NAME=VET Car Rental
VITE_API_URL=              # (Optional direct override URL)
VITE_API_URL_DEV=http://...
VITE_API_URL_QA=http://...
VITE_API_URL_LOCAL=http://...
VITE_API_URL_PROD=https://...
VITE_GOOGLE_MAP_API_KEY=AIzaSy...
```

### Resolution Utilities:
- **Client Side**: [`app/composables/useApiUrl.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useApiUrl.ts) evaluates `VITE_NODE_ENV` to pick the correct API base URL.
- **Server Side (Nitro)**: [`server/utils/resolveApiBaseUrl.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/server/utils/resolveApiBaseUrl.ts) resolves the target URL server-side from `useRuntimeConfig()`, adhering to Nuxt boundary rules.

---

## 🔀 5. Nitro Reverse Proxy

**Location:** [`server/api/proxy/[...].ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/server/api/proxy/%5B...%5D.ts)

A catch-all event handler intercepting requests to `/api/proxy/...`:

```typescript
export default defineEventHandler(async (event) => {
  const baseUrl = resolveApiBaseUrl();
  const targetPath = event.path.replace(/.*\/api\/proxy/, "");
  const targetUrl = `${baseUrl}${targetPath}`;
  return await proxyRequest(event, targetUrl);
});
```

Example mapping:
- Client call: `/vet-car-rental/api/proxy/mobile/catalog/vehicles`
- Target backend: `https://<backend-host>/mobile/catalog/vehicles`

---

## 📚 6. Domain Repositories & Endpoints

All domain endpoints are encapsulated in the `app/apis/` directory:

| Repository File | Domain | Method & Endpoint | Description |
|---|---|---|---|
| [`vehicleRental.repository.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/vehicleRental.repository.ts) | Catalog | `GET /mobile/catalog/rental-types` | Fetch rental type categories |
| | Catalog | `GET /mobile/catalog/filter-options` | Fetch vehicle filter categories, ratings & guest thresholds |
| | Catalog | `POST /mobile/catalog/vehicles` | Fetch filtered vehicle listings |
| | Catalog | `GET /mobile/catalog/vehicles/{id}` | Fetch full vehicle details, slides & facilities |
| | Catalog | `POST /mobile/catalog/vehicles/{id}/reviews` | Fetch vehicle reviews & rating breakdown |
| | Catalog | `GET /mobile/catalog/vehicles/{id}/schedule` | Fetch availability schedule & time slots |
| [`booking.repository.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/booking.repository.ts) | Bookings | `POST /mobile/bookings` | Create a vehicle rental booking |
| [`dropDown.repository.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/dropDown.repository.ts) | Dropdowns | `POST /dropdown/sub-locations` | Sub-locations dropdown with province filter |
| | Dropdowns | `POST /dropdown/provinces` | Provinces dropdown with search & pagination |
| | Dropdowns | `POST /dropdown/nationalities` | Nationalities dropdown list |
| [`user.repository.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/user.repository.ts) | Profile | `GET /mobile/users/me` | Fetch authenticated user profile |

---

## 📦 7. Data Contracts & Response Wrappers

**Location:** [`app/types/api.d.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/api.d.ts)

All backend endpoints respond with a unified envelope structure:

```typescript
export interface ApiResponseWrapper<T> {
  success: boolean;
  status: number;
  message: string;
  data: T;
  timestamp: string;
}
```

### Key Request Payload & Data Interfaces:
- **`CreateBookingPayload`** ([`app/types/booking.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/booking.ts)): Used in `bookingRepository.placeBooking()`. Includes rental type, dates, customer contact info, trip destinations, and luggage details.
- **`VehicleListParams`** ([`app/types/api.d.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/api.d.ts)): Filtering criteria for querying vehicles.
- **`DropdownItem`** ([`app/types/drop-down.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/drop-down.ts)): Standard shape `{ id, code, nameKh, nameEn, nameZh }` for location dropdowns.

---

## 📱 8. Native Mobile App Integration (Bridge)

**Composables & Plugins:**
- [`app/composables/useNativeBridge.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useNativeBridge.ts)
- [`app/plugins/flutter-title.client.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/plugins/flutter-title.client.ts)

Provides communication handlers between the Nuxt web application running inside mobile WebViews (Flutter or Native Android):
- `sendTitleToFlutter(title)`: Notifies Flutter WebView container to update app bar headers via `flutter_inappwebview` or `SetAppBarTitle.postMessage()`.
- `showToast(message)`: Calls native `Android.showToast()` bridge.
- `closeApp()`: Calls native `Android.closeApp()` bridge to close the WebView container.

---

## 💻 9. Example Code Usage

### Fetching Vehicles in a Page:
```typescript
import { vehicleRentalRepository } from '~/apis/vehicleRental.repository'

// Executes GET /api/proxy/mobile/catalog/vehicles/{id}
const vehicleId = 12
const { data: response, pending, error } = await vehicleRentalRepository.getVehicleDetail(vehicleId)

if (response.value?.success) {
  const vehicleDetail = response.value.data
  console.log('Vehicle loaded:', vehicleDetail.nameEn)
}
```

### Submitting a Booking Payload:
```typescript
import { bookingRepository } from '~/apis/booking.repository'
import type { CreateBookingPayload } from '~/types/booking'

const payload: CreateBookingPayload = {
  rentalTypeId: 1,
  rentalTypeName: 'Domestic Rental',
  pickupDate: '2026-08-01',
  pickupTime: '08:00',
  dropOffDate: '2026-08-05',
  dropOffTime: '17:00',
  customerName: 'John Doe',
  customerPhone: '+85512345678',
  trips: [...]
}

const { data: result } = await bookingRepository.placeBooking(payload)
```
