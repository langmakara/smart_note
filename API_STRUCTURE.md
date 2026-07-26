# Nuxt 4.4 API Integration Architecture

This document defines the production-ready directory structure, architectural patterns, and implementation guidelines for integrating external REST APIs within our Nuxt 4.4 application. 

This setup utilizes the **Repository Pattern** on the frontend alongside Nuxt 4.4's native `createUseFetch` utility, combined with a secure **Nitro Server Layer** (`server/` directory) to handle private keys, databases, and Cross-Origin Resource Sharing (CORS) limits.

---

## 📁 1. Directory Structure

The structure adheres entirely to the Nuxt 4 `app/` and `server/` directory specifications.

```text
my-nuxt-app/
├── app/                    # Frontend Layer (Runs on Client & Server)
│   ├── apis/
│   │   ├── index.ts               # Base HTTP factory client (createUseFetch)
│   │   ├── auth.repository.ts     # Domain: Session and Authorization
│   │   └── products.repository.ts # Domain: Product Catalog and Management
│   ├── types/
│   │   ├── api.d.ts               # Unified API contract definitions
│   │   └── index.ts               # Global types barrel export
│   └── pages/
│       └── products.vue           # Pure UI view component
├── server/                 # Backend Layer (Runs STRICTLY on the Server)
│   ├── api/
│   │   ├── proxy/
│   │   │   └── [...].ts           # CORS API Reverse-Proxy endpoint
│   │   └── secure-data.ts         # Secure endpoint utilizing private .env keys
│   └── middleware/
│       └── auth.ts                # Server-side token validation middleware
├── nuxt.config.ts                 # Application configurations
└── .env                           # Local environment secrets
```

---

## 🛠️ 2. Core Frontend Implementation Files

### 📄 `nuxt.config.ts`
Registers backwards compatibility parameters and safely splits public configuration from secure server runtime secrets.

```typescript
export default defineNuxtConfig({
  // Nuxt 4 capability version declaration
  future: {
    compatibilityVersion: 4,
  },
  runtimeConfig: {
    // Private keys: ONLY available inside the server/ directory
    stripeSecretKey: process.env.STRIPE_SECRET_KEY,
    privateBackendUrl: process.env.PRIVATE_BACKEND_URL || 'https://internal-backend.com',
    
    // Public keys: Accessible anywhere (client browser and server)
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || '/api/proxy',
    }
  }
})
```

### 📄 `app/types/api.d.ts`
Declared interfaces matching the precise shape of server payloads to keep our components fully type-safe.

```typescript
export interface ApiResponseWrapper<T> {
  data: T
  status: string
  timestamp: string
}

export interface Product {
  id: string
  title: string
  price: number
  description: string
  category: string
  image: string
}

export interface CreateProductPayload {
  title: string
  price: number
  description: string
  category: string
}
```

### 📄 `app/apis/index.ts`
Configures the core factory client engine using Nuxt 4.4's `createUseFetch`. It targets either our local Nitro proxy or an external endpoint while safely applying authorization cookies.

```typescript
import { createUseFetch } from '#app'

export const useApiClient = createUseFetch((currentOptions) => {
  const runtimeConfig = useRuntimeConfig()
  
  return {
    ...currentOptions,
    // Safely reads global base url configuration (pointing to local proxy if needed)
    baseURL: currentOptions.baseURL ?? (runtimeConfig.public.apiBaseUrl as string),
    
    // Interceptor: Attaches Authorization tokens prior to outgoing requests
    onRequest({ options }) {
      const token = useCookie('auth_token').value
      if (token) {
        options.headers = (options.headers || {}) as Record<string, string>
        options.headers['Authorization'] = `Bearer ${token}`
      }
    },

    // Interceptor: Catches errors globally (e.g., handles expired tokens)
    onResponseError({ response }) {
      if (response.status === 401) {
        const token = useCookie('auth_token')
        token.value = null // Purge invalid session data
        navigateTo('/auth/login') // Force login redirection
      }
    }
  }
})
```

### 📄 `app/apis/products.repository.ts`
Abstracts specific resource URLs into neat modular function calls. This protects pages from breaking if URLs change.

```typescript
import { useApiClient } from './index'
import type { ApiResponseWrapper, Product, CreateProductPayload } from '../types/api'

export const productsRepository = {
  /**
   * SSR-Safe Retrieval
   * Safely loads data during Server Side Rendering without double hydration calls.
   */
  getAllProducts() {
    return useApiClient<ApiResponseWrapper<Product[]>>('/v1/products', {
      method: 'GET',
      key: 'products-list-cache' // Unique key handles SSR state hydration
    })
  },

  /**
   * Action Mutation
   * Handles dynamic data writes on demand (triggered by forms/buttons).
   */
  createNewProduct(payload: CreateProductPayload) {
    return useApiClient<ApiResponseWrapper<Product>>('/v1/products', {
      method: 'POST',
      body: payload
    })
  }
}
```

---

## 🔒 3. Core Backend Implementation Files (`server/`)

Code written within this section executes exclusively on the server instance. It never streams down to the user's browser, making it ideal for guarding sensitive logic.

### 📄 `server/api/proxy/[...].ts` (Reverse Proxy Solution)
Handles external API traffic server-to-server. This circumvents browser-enforced **CORS limitations** and prevents endpoint mapping exposures.

```typescript
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  
  // Extract the remaining wild-card route structure (e.g., /api/proxy/v1/products -> /v1/products)
  const targetPath = event.path.replace(/^\/api\/proxy/, '')
  
  // Forward client request over to the firewalled core backend service
  return proxyRequest(
    event,
    `${config.privateBackendUrl}${targetPath}`
  )
})
```

### 📄 `server/api/secure-data.ts` (Handling Sensitive Private Tokens)
Executes logic that relies on hidden environment parameters (like payment processing or AI generation endpoints) without leaking credentials to client inspectors.

```typescript
export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  
  // 1. Safe extraction of a fully hidden private token
  const secretToken = config.stripeSecretKey
  
  if (!secretToken) {
    throw createError({
      statusCode: 500,
      statusMessage: 'Server infrastructure token initialization failure.'
    })
  }
  
  // 2. Safely call external payment network on behalf of the client browser
  const data = await $fetch('https://stripe.com', {
    headers: { Authorization: `Bearer ${secretToken}` }
  })
  
  return { success: true, payload: data }
})
```

### 📄 `server/middleware/auth.ts` (Global Server Requests Check)
Intercepts inbound traffic hitting the Nuxt web application server or API layers to check server validation rules prior to rendering payload layouts.

```typescript
export default defineEventHandler((event) => {
  // Catch only backend-focused API endpoints
  if (event.path.startsWith('/api/')) {
    const cookies = parseCookies(event)
    const token = cookies['auth_token']
    
    // Optional: Log server network interactions safely
    console.log(`[Server API Route Request]: ${event.path} at ${new Date().toISOString()}`)
    
    // Perform light route sanity check or session schema lookups
    if (!token && event.path.includes('/secure-data')) {
      throw createError({
        statusCode: 401,
        statusMessage: 'Unauthorized backend asset request exception.'
      })
    }
  }
})
```

---

## 🎨 4. Usage Pattern inside Vue Components

### 📄 `app/pages/products.vue`
Pages and UI layouts import the modular domain repositories directly. This keeps the component clean and free of networking boilerplate.

```vue
<script setup lang="ts">
import { productsRepository } from '~/apis/products.repository'

// 1. Core Load Phase: Execute SSR async data fetcher
const { data: response, pending, error } = await productsRepository.getAllProducts()

// Wrap properties to guarantee clean reactive reading array layers
const products = computed(() => response.value?.data || [])

// 2. Local View Mutation Action Phase
const isSubmitting = ref(false)

async function handleCreateProduct() {
  isSubmitting.value = true
  try {
    const payload = { 
      title: 'New Workspace Desk', 
      price: 299, 
      description: 'Solid Oak Office Desk', 
      category: 'furniture' 
    }
    
    const result = await productsRepository.createNewProduct(payload)
    
    // Inject the freshly built database item right back to current reactive array state
    if (result?.data && response.value) {
      response.value.data.push(result.data)
    }
  } catch (err) {
    console.error('Request processing error: ', err)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <main class="container">
    <h1>Store Products Catalog</h1>

    <div v-if="pending">Syncing remote network feeds...</div>
    <div v-else-if="error">System error: {{ error.message }}</div>

    <section v-else>
      <button :disabled="isSubmitting" @click="handleCreateProduct">
        {{ isSubmitting ? 'Creating...' : 'Quick Add Item' }}
      </button>

      <ul>
        <li v-for="item in products" :key="item.id">
          <strong>{{ item.title }}</strong> — \${{ item.price }}
        </li>
      </ul>
    
  </main>
</template>
```

---
