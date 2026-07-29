# Project Structure: VET Car Rental (Nuxt 3)

This document provides an overview of the directory tree and key modules in the `vet-car-rental` project.

## Directory Tree

```text
vet-car-rental/
├── .env
├── .gitignore
├── .nuxtignore
├── app/
│   ├── apis/
│   │   ├── booking.repository.ts
│   │   ├── dropDown.repository.ts
│   │   ├── index.ts
│   │   ├── user.repository.ts
│   │   └── vehicleRental.repository.ts
│   ├── app.config.ts
│   ├── app.vue
│   ├── assets/
│   │   └── css/
│   │       ├── bookDetail.css
│   │       ├── customerDetails.css
│   │       ├── main.css
│   │       ├── ModalMap.css
│   │       ├── payment.css
│   │       ├── paymentGateway.css
│   │       ├── schedule.css
│   │       ├── theme/
│   │       │   ├── advanced.css
│   │       │   ├── colors.css
│   │       │   ├── spacing.css
│   │       │   ├── typography.css
│   │       │   └── variables.css
│   │       └── tripInformation.css
│   ├── components/
│   │   ├── Button/
│   │   │   └── AppButton.vue
│   │   ├── Controls/
│   │   │   ├── AppCheckbox.vue
│   │   │   ├── AppInputField.vue
│   │   │   ├── AppSelect.vue
│   │   │   └── AppTextarea.vue
│   │   ├── map/
│   │   │   ├── ModalMap.vue
│   │   │   └── SearchMap.vue
│   │   ├── modal/
│   │   │   └── ModalFilter.vue
│   │   ├── StarRating.vue
│   │   └── vehicle-rental/
│   │       ├── RentalTypeCard.vue
│   │       ├── VehicleCard.vue
│   │       └── VehicleListPage.vue
│   ├── composables/
│   │   ├── useApiUrl.ts
│   │   ├── useAssetResolver.ts
│   │   ├── useAuthToken.ts
│   │   ├── useBookingState.ts
│   │   ├── useDropdown.ts
│   │   ├── useNativeBridge.ts
│   │   └── useVehicleRental.ts
│   ├── error.vue
│   ├── middleware/
│   │   └── auth.global.ts
│   ├── pages/
│   │   ├── index.vue
│   │   ├── unauthorized.vue
│   │   └── vehicle-rental/
│   │       ├── bookDetail/
│   │       │   └── index.vue
│   │       ├── customerDetails/
│   │       │   └── index.vue
│   │       ├── payment/
│   │       │   └── index.vue
│   │       ├── paymentGateway/
│   │       │   └── index.vue
│   │       ├── schedule/
│   │       │   └── index.vue
│   │       ├── tripInformation/
│   │       │   └── index.vue
│   │       └── [rentalTypeId]/
│   │           └── index.vue
│   ├── plugins/
│   │   ├── 00.ionic-nav.client.ts
│   │   └── flutter-title.client.ts
│   ├── types/
│   │   ├── api.d.ts
│   │   ├── booking.ts
│   │   ├── drop-down.ts
│   │   ├── index.ts
│   │   └── vehicle-rental.ts
│   └── utils/
│       └── formatters.ts
├── capacitor.config.ts
├── ionic.config.json
├── nuxt.config.ts
├── package.json
├── pom.xml
├── public/
│   ├── favicon.ico
│   ├── icons/
│   ├── images/
│   └── robots.txt
├── README.md
├── scripts/
│   ├── build-prod.cjs
│   └── build-qa.cjs
├── server/
│   ├── api/
│   │   └── proxy/
│   │       └── [...].ts
│   ├── middleware/
│   │   └── auth.ts
│   └── utils/
│       └── resolveApiBaseUrl.ts
├── tsconfig.json
└── web.xml
```

## Core Modules Overview

### 1. `app/pages/`
Contains the application's page routes built with Nuxt 3:
- **`vehicle-rental/schedule`**: Date/time selection step for vehicle rental.
- **`vehicle-rental/tripInformation`**: Pickup/drop-off location and rental preferences.
- **`vehicle-rental/customerDetails`**: Renter details and contact information.
- **`vehicle-rental/payment`**: Payment options and summary.
- **`vehicle-rental/paymentGateway`**: Payment gateway integration screen.
- **`vehicle-rental/bookDetail`**: Confirmation and rental summary details.

### 2. `app/apis/`
Repositories for handling API calls:
- `vehicleRental.repository.ts`: API endpoints for rental listings and details.
- `dropDown.repository.ts`: API endpoints for dropdown options (locations, driver types, etc.).
- `booking.repository.ts`: API endpoints for processing booking requests.
- `user.repository.ts`: API endpoints for user profile/auth data.

### 3. `app/composables/`
Reusable Vue composables:
- `useDropdown.ts`: State management and fetching logic for form dropdowns.
- `useBookingState.ts`: Reactive state management across the rental booking steps.
- `useVehicleRental.ts`: Search, filter, and selection logic for vehicles.
- `useNativeBridge.ts` & `useAssetResolver.ts`: Mobile native interactions and asset resolution.

### 4. `app/components/`
Reusable Vue components grouped by domain:
- **`Controls/`**: Custom input fields, checkboxes, selects, and textareas.
- **`map/`**: Google Maps integration (`SearchMap`, `ModalMap`).
- **`vehicle-rental/`**: Cards and listing views (`VehicleCard`, `RentalTypeCard`, `VehicleListPage`).

### 5. `server/`
Nuxt server routes and middleware:
- **`api/proxy/[...].ts`**: Proxy handler forwarding requests to the backend server.
- **`middleware/auth.ts`**: Server-side authentication check.
