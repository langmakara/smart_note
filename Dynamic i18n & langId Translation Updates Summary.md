# Dynamic i18n & `langId` Translation Updates Summary

## Overview
This document summarizes the changes and fixes implemented to support dynamic language translation and `langId` URL parameter detection from mobile MiniApp launches (`?langId=1` for Khmer, `?langId=2` for English, `?langId=3` for Chinese).

---

## Summary of Changes

### 1. Fix TypeScript Object Literal Duplicate Property Keys
- **File**: [app/components/helpers/languages/index.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/components/helpers/languages/index.ts)
- **Problem**: TypeScript error `An object literal cannot have multiple properties with the same name` due to duplicate keys `1` and `"1"`, `2` and `"2"`, `3` and `"3"`.
- **Fix**: Removed redundant `"1"`, `"2"`, `"3"` string keys from `LANG_ID_TO_CODE_MAP`. In JavaScript, numeric keys automatically resolve to string keys.

```typescript
export const LANG_ID_TO_CODE_MAP: Record<number | string, SupportedLocale> = {
  1: "km",
  2: "en",
  3: "zh",
  km: "km",
  en: "en",
  zh: "zh",
};
```

---

### 2. Extend Vehicle Rental Type Definitions
- **File**: [app/types/vehicle-rental.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/types/vehicle-rental.ts)
- **Change**: Added optional localized properties (`titleEn`, `titleKh`, `titleZh`, `descriptionEn`, `descriptionKh`, `descriptionZh`, `locationEn`, `locationKh`, `locationZh`, `rawItem`) to the `RentalType` interface.

---

### 3. Dynamic i18n Support in RentalTypeCard Component
- **File**: [app/components/vehicle-rental/RentalTypeCard.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/components/vehicle-rental/RentalTypeCard.vue)
- **Change**:
  - Integrated `useI18n()` composable.
  - Added reactive computed properties (`displayTitle`, `displayDescription`, `displayLocation`) to render text dynamically based on active locale (`km`, `zh`, `en`) with fallbacks.

```typescript
const { locale } = useI18n();

const displayTitle = computed(() => {
  const r = props.rental as any;
  const loc = locale.value;
  if (loc === "km") return r.titleKh || r.nameKh || r.titleEn || r.title || "";
  if (loc === "zh") return r.titleZh || r.nameZh || r.titleEn || r.title || "";
  return r.titleEn || r.nameEn || r.title || "";
});
```

---

### 4. Reactive Locale Resolution in Main Rental Page
- **File**: [app/pages/index.vue](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/pages/index.vue)
- **Change**:
  - Added reactive dependency on `locale.value` from `useI18n()`.
  - Mapped API item response attributes into localized `RentalType` fields so the list re-renders instantly whenever language changes.

---

### 5. Immediate `langId` Detection on Mobile App Startup
- **File**: [app/plugins/i18n-detector.client.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/plugins/i18n-detector.client.ts)
- **Change**:
  - Enhanced initial sync to read `langId` directly from `window.location.search` if `route.query` is not yet initialized during MiniApp startup.
  - Added a reactive watcher on `route.query.langId` / `lang_id` / `lang`.

```typescript
if (!targetQueryVal && typeof window !== "undefined" && window.location?.search) {
  const searchParams = new URLSearchParams(window.location.search);
  targetQueryVal = searchParams.get("langId") || searchParams.get("lang_id") || searchParams.get("lang");
}
```

---

### 6. Language Header Injection in HTTP API Client
- **File**: [app/apis/index.ts](file:///d:/UDAYA/github/PR_VET_Car_Rental_ReactJS/apps/vet-car-rental/app/apis/index.ts)
- **Change**:
  - Updated `useApiClient` `onRequest` interceptor to read the `lang_id` cookie and automatically forward `x-lang-id` and `lang-id` HTTP headers to backend API endpoints.

```typescript
const langIdCookie = useCookie<string | number | null>('lang_id')
if (langIdCookie.value) {
  headers.set('x-lang-id', String(langIdCookie.value))
  headers.set('lang-id', String(langIdCookie.value))
}
```

---

## Language Mapping Reference

| `langId` | Locale Code | Language Name |
| :--- | :--- | :--- |
| `1` | `"km"` | Khmer (ខ្មែរ) |
| `2` | `"en"` | English |
| `3` | `"zh"` | Chinese (中文) |
