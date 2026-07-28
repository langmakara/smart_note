# API Integration Documentation - VET Car Rental App

This document provides a comprehensive guide to the API architecture, HTTP client setup, domain repositories, authentication mechanism, header token extraction, and proxy forwarding implemented in the **VET Car Rental Customer App** (Nuxt 4 / Vue 3 / Ionic).

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

---

## 🔑 3. Header Token Extraction on Mobile App Launch

When a user opens the web application inside a native mobile container (such as an Android WebView or Flutter WebView), the mobile app injects the authentication token inside the initial HTTP request headers.

### Mobile App Launch & Token Flow:

```
 ┌─────────────────────────────────────────────────────────────┐
 │       Mobile App (Flutter / Android WebView)                │
 │       Loads URL with HTTP Request Header:                   │
 │       `Authorization: Bearer <token>`                       │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Initial HTTP Request
 ┌──────────────────────────────▼──────────────────────────────┐
 │     Server Middleware (`server/middleware/auth.ts`)         │
 │  1. Intercepts header: `getRequestHeader(event, "auth")`   │
 │  2. Extracts token: `authHeader.substring(7).trim()`        │
 │  3. Sets cookie: `setCookie(event, "access_token", token)`  │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Cookie set for session
 ┌──────────────────────────────▼──────────────────────────────┐
 │      Client Composable (`app/composables/useAuthToken.ts`)  │
 │  - Reads reactive `useCookie("access_token")`               │
 │  - Syncs to `localStorage` on client side                   │
 └──────────────────────────────┬──────────────────────────────┘
                                │ Token ready
 ┌──────────────────────────────▼──────────────────────────────┐
 │      Base API Client (`app/apis/index.ts`)                  │
 │  - Automatically attaches token to all backend API calls    │
 └─────────────────────────────────────────────────────────────┘
```

### Key Implementation Files:

1. **Server Middleware Interception** ([`server/middleware/auth.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/server/middleware/auth.ts)):
   - Executes on every incoming HTTP request on the server side.
   - Reads the `authorization` header using `getRequestHeader(event, "authorization")`.
   - Checks if the header starts with `"Bearer "`.
   - Extracts the clean token string.
   - Saves it to Nuxt's `access_token` cookie (path `/`, maxAge 7 days).

```typescript
export default defineEventHandler((event) => {
  const authHeader = getRequestHeader(event, "authorization");

  if (authHeader && authHeader.toLowerCase().startsWith("bearer ")) {
    const token = authHeader.substring(7).trim();

    if (token) {
      setCookie(event, "access_token", token, {
        path: "/",
        maxAge: 60 * 60 * 24 * 7,
        httpOnly: false,
        sameSite: "lax",
      });
    }
  }
});
```

2. **Frontend Token Hydration** ([`app/composables/useAuthToken.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useAuthToken.ts)):
   - Reads `useCookie("access_token")`, which immediately contains the token set by the server middleware during the initial page load.
   - Synchronizes `localStorage.setItem("access_token", token)` on the client.

```typescript
export const useAuthToken = () => {
  const cookieToken = useCookie<string | null>("access_token", {
    path: "/",
    maxAge: 60 * 60 * 24 * 7,
  });

  const getToken = (): string | null => {
    if (cookieToken.value) return cookieToken.value;
    if (import.meta.client) {
      const localToken = localStorage.getItem("access_token");
      if (localToken) {
        cookieToken.value = localToken;
        return localToken;
      }
    }
    return null;
  };
  // ...
};
```

3. **Client JavaScript Bridge Fallback** ([`nuxt.config.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/nuxt.config.ts)):
   - Inject global fallback function `window.setMobileToken(token)` for WebViews that inject tokens via JavaScript execution instead of HTTP headers.

---

## 🌐 4. Environment Configuration & URL Resolution

**Configuration File:** [`nuxt.config.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/nuxt.config.ts)

- **Client Side**: [`app/composables/useApiUrl.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useApiUrl.ts) evaluates `VITE_NODE_ENV` to select the API base URL.
- **Server Side (Nitro)**: [`server/utils/resolveApiBaseUrl.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/server/utils/resolveApiBaseUrl.ts) resolves the target URL server-side from `useRuntimeConfig()`.

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

---

## 📚 6. Domain Repositories & Endpoints

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

## 📱 7. Native Mobile App Integration (Bridge)

- [`app/composables/useNativeBridge.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useNativeBridge.ts)
- [`app/plugins/flutter-title.client.ts`](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/plugins/flutter-title.client.ts)

Provides communication handlers:
- `sendTitleToFlutter(title)`: Notifies Flutter WebView container to update app bar header titles.
- `showToast(message)`: Calls native `Android.showToast()` bridge.
- `closeApp()`: Calls native `Android.closeApp()` bridge.
