# Nuxt 4.4 API Integration Architecture

This document defines the production-ready directory structure, architectural patterns, and implementation guidelines for integrating external REST APIs within our Nuxt 4.4 application. 

This setup utilizes the **Repository Pattern** alongside Nuxt 4.4's native `createUseFetch` utility to ensure separation of concerns, secure token authorization, and strict TypeScript types.

---

## 📁 1. Directory Structure

The structure adheres entirely to the Nuxt 4 `app/` directory convention and Layer-first architecture.

```text
my-nuxt-app/
├── app/
│   ├── apis/
│   │   ├── index.ts               # Base HTTP factory client (createUseFetch)
│   │   ├── auth.repository.ts     # Domain: Session and Authorization
│   │   └── products.repository.ts # Domain: Product Catalog and Management
│   ├── types/
│   │   ├── api.d.ts               # Unified API contract definitions
│   │   └── index.ts               # Global types barrel export
│   └── pages/
│       └── products.vue           # Pure UI view component
├── nuxt.config.ts                 # Application configurations
└── .env                           # Local environment secrets
```

---

## 🛠️ 2. Core Implementation Files

### 📄 `nuxt.config.ts`
Registers backwards compatibility parameters and safely exposes environment variables to the client browser framework.

```typescript
export default defineNuxtConfig({
  // Nuxt 4 capability version declaration
  future: {
    compatibilityVersion: 4,
  },
  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL || 'https://example.com',
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
Configures the core factory client engine using Nuxt 4.4's `createUseFetch`. It isolates global rules like base endpoints, standard authorizations, and security logouts.

```typescript
import { createUseFetch } from '#app'

export const useApiClient = createUseFetch((currentOptions) => {
  const runtimeConfig = useRuntimeConfig()
  
  return {
    ...currentOptions,
    // Safely reads global base url configuration
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

## 🎨 3. Usage Pattern inside Vue Components

### 📄 `app/pages/products.vue`
Pages and UI layouts import the modular domain repositories directly. This prevents networking boilerplate code from filling up the component files.

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

## 💎 4. Architectural Rules and Compliance

1. **Never Hardcode Endpoints:** Do not write strings like `/v1/products` inside your Vue files. Keep them confined to their specific domain `.repository.ts` file.
2. **Handle Form Actions Independently:** Always wrap client interactions (like clicks and submissions) inside explicit functions with `try/catch` processing blocks rather than calling components inline.
3. **Keep Types Strict:** Assign exact type models (e.g., `<ApiResponseWrapper<Product[]>>`) to your repository functions. Avoid using `any` or forced `as type` castings inside components.
