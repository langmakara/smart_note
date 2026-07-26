# Nuxt 4.4 API Integration Architecture

This document defines the production-ready directory structure, architectural patterns, and implementation details for integrating external REST APIs within our Nuxt 4.4 application.

This setup utilizes the **Repository Pattern** on the frontend alongside Nuxt 4.4's native `createUseFetch` utility, combined with a secure **Nitro Server Layer** (`server/` directory) to handle private keys, CORS limits, and server-side request proxying.

---

## 📁 1. Directory Structure

The structure adheres entirely to the Nuxt 4 `app/` and `server/` directory specifications.

```text
vet-car-rental/
├── app/                    # Frontend Layer (Runs on Client & Server)
│   ├── apis/
│   │   ├── index.ts               # Base HTTP factory client (createUseFetch)
│   │   └── vehicleRental.repository.ts # Domain: Vehicle Catalog and Management
│   ├── types/
│   │   ├── api.d.ts               # Unified API contract definitions
│   │   ├── vehicle-rental.ts      # Domain UI vehicle types
│   │   └── index.ts               # Global types barrel export
│   └── pages/
│       └── index.vue              # Pure UI view component using repositories
├── server/                 # Backend Layer (Runs STRICTLY on the Server)
│   ├── api/
│   │   ├── features/
│   │   │   ├── vehicleRental.ts   # Server-side endpoint for rental types
│   │   │   └── filterOptions.ts   # Server-side endpoint for catalog filters
│   │   └── proxy/
│   │       └── [...].ts           # CORS API Reverse-Proxy endpoint
│   ├── utils/
│   │   └── resolveApiBaseUrl.ts   # Server-only API URL resolver
│   └── middleware/
│       └── auth.ts                # Server-side token validation middleware
├── nuxt.config.ts                 # Application configurations
└── .env                           # Local environment secrets
```

---

## 🛠️ 2. Core Frontend Implementation Files

### 📄 `nuxt.config.ts`
Registers compatibility parameters and safely splits public configuration from secure server runtime secrets.

```typescript
export default defineNuxtConfig({
  future: {
    compatibilityVersion: 4,
  },
  runtimeConfig: {
    // Private keys: ONLY available inside the server/ directory
    apiBaseUrl: process.env.NUXT_API_BASE_URL || '',
    
    // Public keys: Accessible anywhere (client browser and server)
    public: {
      nodeEnv: process.env.VITE_NODE_ENV || 'dev',
      apiUrl: process.env.VITE_API_URL || '',
      apiUrlProd: process.env.VITE_API_URL_PROD || '',
      apiUrlQa: process.env.VITE_API_URL_QA || '',
      apiUrlLocal: process.env.VITE_API_URL_LOCAL || '',
      apiUrlDev: process.env.VITE_API_URL_DEV || '',
    }
  }
})
```

### 📄 `app/types/api.d.ts`
Declared interfaces matching the precise shape of server payloads to keep components and repositories fully type-safe.

```typescript
export interface ApiResponseWrapper<T> {
  success: boolean
  status: number
  message: string
  data: T
  timestamp: string
}

export interface RawRentalTypeItem {
  id?: string | number
  nameEn?: string
  nameKh?: string
  descriptionEn?: string
  fileUrl?: string
  [key: string]: any
}

export interface FilterOptionsData {
  guests?: number[]
  ratings?: number[]
  categories?: any[]
  rentalTypes?: any[]
}
```

### 📄 `app/apis/index.ts`
Configures the core factory client engine using Nuxt 4.4's `createUseFetch`. It targets local Nitro proxy/features while safely attaching authorization cookies.

```typescript
import { createUseFetch } from '#app'

export const useApiClient = createUseFetch((currentOptions) => {
  const { getToken } = useAuthToken()

  return {
    ...currentOptions,
    // Interceptor: Attaches Authorization tokens prior to outgoing requests
    onRequest({ options }) {
      const token = getToken()
      if (token) {
        options.headers = (options.headers || {}) as Record<string, string>
        options.headers['Authorization'] = token.startsWith('Bearer ')
          ? token
          : `Bearer ${token}`
      }
    },

    // Interceptor: Catches errors globally (e.g., handles expired tokens)
    onResponseError({ response }) {
      if (response?.status === 401) {
        console.warn('[useApiClient] Unauthorized (401). Token may be expired.')
      }
    }
  }
})
```

### 📄 `app/apis/vehicleRental.repository.ts`
Abstracts specific resource URLs into modular function calls, keeping pages decoupled from endpoint endpoints.

```typescript
import { useApiClient } from './index'
import type { ApiResponseWrapper, RawRentalTypeItem, FilterOptionsData } from '~/types/api'

export const vehicleRentalRepository = {
  /**
   * Fetch available rental types
   */
  getRentalTypes() {
    return useApiClient<ApiResponseWrapper<RawRentalTypeItem[]>>('/api/features/vehicleRental', {
      method: 'GET',
      key: 'catalog-rental-types'
    })
  },

  /**
   * Fetch filter options
   */
  getFilterOptions() {
    return useApiClient<ApiResponseWrapper<FilterOptionsData>>('/api/features/filterOptions', {
      method: 'GET',
      key: 'catalog-filter-options'
    })
  }
}
```

---

## 🔒 3. Core Backend Implementation Files (`server/`)

Code written within this section executes exclusively on the server instance.

### 📄 `server/utils/resolveApiBaseUrl.ts`
Server-only utility that safely resolves active environment API base URLs without violating Nuxt 4 client/server import boundaries.

```typescript
export function resolveApiBaseUrl(): string {
  const config = useRuntimeConfig()
  const pub = config.public
  const activeEnv = (String(pub.nodeEnv || 'dev')).toLowerCase().trim()

  let baseUrl = String(pub.apiUrl || '')
  if (!baseUrl) {
    if (activeEnv === 'pro' || activeEnv === 'production') baseUrl = pub.apiUrlProd as string
    else if (activeEnv === 'qa') baseUrl = pub.apiUrlQa as string
    else if (activeEnv === 'local') baseUrl = pub.apiUrlLocal as string
    else baseUrl = pub.apiUrlDev as string
  }
  return baseUrl.replace(/\/+$/, '')
}
```

### 📄 `server/api/proxy/[...].ts` (Reverse Proxy Solution)
Handles external API traffic server-to-server to circumvent browser-enforced **CORS limitations**.

```typescript
export default defineEventHandler(async (event) => {
  const baseUrl = resolveApiBaseUrl()
  const targetPath = event.path.replace(/^\/api\/proxy/, '')
  
  return proxyRequest(event, `${baseUrl}${targetPath}`)
})
```

---

## 🎨 4. Usage Pattern inside Vue Components

### 📄 `app/pages/index.vue`
Pages and UI layouts import modular domain repositories directly.

```vue
<script setup lang="ts">
import { vehicleRentalRepository } from '~/apis/vehicleRental.repository'
import RentalTypeCard from '~/components/vehicle-rental/RentalTypeCard.vue'

// 1. SSR-Safe Fetching using repository
const { data: response, pending } = await vehicleRentalRepository.getRentalTypes()

// 2. Computed presentation layer
const rentalTypes = computed(() => {
  const items = response.value?.data || []
  return items.map(item => ({
    id: item.id,
    title: item.nameEn || item.nameKh,
    description: item.descriptionEn || ''
  }))
})
</script>

<template>
  <main class="container">
    <div v-if="pending">Loading...</div>
    <div v-else>
      <RentalTypeCard v-for="item in rentalTypes" :key="item.id" :rental="item" />
    </div>
  </main>
</template>
```
