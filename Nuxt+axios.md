# Walkthrough – Axios Modular Repository Pattern

> Build result: **✅ `nuxt build` passed — 0 errors**

---

## Architecture Overview

```
plugins/axios.ts          ← Boot-time: Axios instance + JWT interceptor + 401 handler
        │ provides $axiosClient
        ▼
composables/useApi.ts     ← Thin accessor: returns $axiosClient from Nuxt context
        │
        ▼
utils/HttpFactory.ts      ← Abstract base: typed get/post/put/patch/delete
        │ extends
        ▼
apis/user.repository.ts   ← UserRepository class: getProfile only (read-only)
apis/booking.repository.ts← BookingRepository: createBooking, checkPaymentStatus, …
        │ useUserRepository() / useBookingRepository()
        ▼
composables/useUser.ts    ← Reactive state: loading, error, profile, fetchProfile
        │
        ▼
app.vue / any page        ← Zero network code in template
```

---

## All Changes Made

### 🔧 [`plugins/axios.ts`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/plugins/axios.ts)

Added full interceptor wiring executed **once at app boot**:

**Request interceptor** — JWT priority waterfall:
1. `auth_token` cookie (Nuxt `useCookie`, SSR + client)
2. `access_token` cookie (backward compat)
3. `localStorage.getItem('access_token')`
4. `window.pendingMobileToken` (Flutter bridge)
5. URL query params (`?token=`, `?auth_token=`, etc.)

**Response interceptor** — global error handler:
- **401**: clears cookies + localStorage, notifies Flutter bridge → `router.push('/login')`
- **All errors**: injects `error.displayMessage` from server response body

---

### 🆕 [`utils/HttpFactory.ts`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/utils/HttpFactory.ts)

Abstract base class all repositories extend. Provides fully-typed HTTP verbs:

| Method | Returns |
|---|---|
| `get<T>(url, config?)` | `Promise<T>` |
| `post<T>(url, body?, config?)` | `Promise<T>` |
| `put<T>(url, body?, config?)` | `Promise<T>` |
| `patch<T>(url, body?, config?)` | `Promise<T>` |
| `delete<T>(url, config?)` | `Promise<T>` |

All methods unwrap `AxiosResponse<T>` → `T` automatically.

---

### 🔧 [`composables/useApi.ts`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useApi.ts)

Stripped to a thin, single-responsibility accessor:

```ts
export const useApi = (): AxiosInstance => {
  return useNuxtApp().$axiosClient as AxiosInstance
}
```

Interceptors were moved into the plugin — registered once, not per composable call.

---

### 🔧 [`apis/user.repository.ts`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/user.repository.ts)

Refactored into a **class extending `HttpFactory`**. User domain is **read-only** — `updateProfile` removed per requirements.

```ts
class UserRepository extends HttpFactory {
  getProfile(params?)  → Promise<ApiResponseWrapper<UserProfile>>
}

export const useUserRepository = () => new UserRepository(useApi())
```

Backward-compat shims kept: `userRepository.getProfile()`, `fetchUserProfileData()`.

---

### 🆕 [`composables/useUser.ts`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/composables/useUser.ts)

Reactive state composable. State is SSR-safe via `useState` (shared across all components).

```ts
const { profile, loading, error, fetchProfile, clearUser } = useUser()
```

| Export | Type | Description |
|---|---|---|
| `profile` | `Ref<UserProfile \| null>` | Cached user data |
| `loading` | `Ref<boolean>` | `true` while request is in-flight |
| `error` | `Ref<string \| null>` | Last error message |
| `fetchProfile(params?, { force? })` | `Promise<UserProfile \| null>` | Cache-first fetch |
| `clearUser()` | `void` | Resets all state (use on logout) |

---

### 🔧 [`apis/booking.repository.ts`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/booking.repository.ts)

**Payment status endpoint fixed** (two changes):

```diff
# 1. Correct HTTP method: GET → POST
- const response = await api.get<T>(`/bookings/${id}/status`, { ... });
+ const response = await api.post<T>(`/payment/check/${id}`, { ... });

# 2. Correct endpoint path
  /bookings/{id}/status  ← returned 404
  /payment/check/{id}    ← correct endpoint
```

Both call sites in `paymentGateway/index.vue` — `checkPaymentStatus()` and `checkPaymentStatusManual()` — automatically use the corrected endpoint with no page-level changes needed.

---

### 🔧 [`pages/vehicle-rental/paymentGateway/index.vue`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/pages/vehicle-rental/paymentGateway/index.vue)

Commented out the `window.location.reload()` call inside `handlePaymentSuccess`:

```diff
- setTimeout(() => {
-   if (typeof window !== "undefined") {
-     try { window.location.reload(); } catch {}
-   }
- }, 100);
+ // setTimeout(() => {  ← disabled: Flutter WebView handles navigation natively
+ //   ...
+ // }, 100);
```

Prevents a forced page reload after payment success — the Flutter host handles the WebView transition instead.

---

### 🔧 [`types/api.d.ts`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/api.d.ts)

Added (kept in file, not re-exported from barrel):
- `UpdateProfilePayload` — write-payload shape (reserved for future use)
- `ApiError` — typed error shape with `displayMessage` field from the interceptor

### 🔧 [`types/index.ts`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/index.ts)

`UserProfile` exported. `UpdateProfilePayload` / `ApiError` kept internal (not in barrel) since the user domain is currently read-only.

### 🔧 [`app.vue`](file:///d:/TestingAxios/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/app.vue)

Added `<script setup lang="ts">` demo: calls `fetchProfile()` on mount, exposes `{ profile, loading, error }`. Ionic template unchanged.

---

## Usage Reference

### Fetch user profile in any page

```vue
<script setup lang="ts">
const { profile, loading, error, fetchProfile } = useUser()
onMounted(() => fetchProfile())
</script>

<template>
  <div v-if="loading">Loading…</div>
  <div v-else-if="error">{{ error }}</div>
  <div v-else>{{ profile?.fullName }}</div>
</template>
```

### Force-refresh profile (skip cache)

```ts
await fetchProfile({}, { force: true })
```

### Check payment status (correct endpoint)

```ts
// POST /payment/check/{transactionId}
const response = await bookingRepository.checkPaymentStatus({ id: txnId, transactionId: txnId })
if (response?.data?.paymentStatus === 2) {
  // Payment approved
}
```

### Add a new domain repository

```ts
// apis/product.repository.ts
import { HttpFactory } from '~/utils/HttpFactory'

class ProductRepository extends HttpFactory {
  getAll() { return this.get<ApiResponseWrapper<Product[]>>('/products') }
  getById(id: number) { return this.get<ApiResponseWrapper<Product>>(`/products/${id}`) }
}
export const useProductRepository = () => new ProductRepository(useApi())
```

---

## Verification

| Check | Result |
|---|---|
| `nuxt build` (client) | ✅ Built in 6.01s |
| `nuxt build` (server + Nitro) | ✅ Built |
| TypeScript errors | ✅ None |
| Payment status 404 | ✅ Fixed → `POST /payment/check/{id}` |
| Window reload on payment success | ✅ Disabled (Flutter handles navigation) |
