# Vehicle Rental Schedule Calendar Updates

This document provides a summary of all changes implemented for the vehicle rental availability schedule calendar in `apps/vet-car-rental`.

---

## 📌 Summary of Issues & Solutions

| Issue | Root Cause | Solution Implemented |
|---|---|---|
| **1. Missing Box Shadow** | Default `<ion-datetime>` lacked card shadow styling. | Added `box-shadow: 0 4px 16px rgba(0,0,0,0.1)`, `border-radius: 16px`, and `background: #ffffff` in `schedule.css`. |
| **2. Dates in Future Months Disabled** | API repository fetched schedule for initial month only. Date validation checked future dates against initial month's available dates. | Updated `getVehicleSchedule` API to accept `year` and `month` parameters. Added `schedulesByMonth` reactive map in `schedule/index.vue` to dynamically fetch and validate schedule data per month. |
| **3. Future Years Not Selectable** | `<ion-datetime>` without `:max` defaults the upper date bound to Dec 31 of the current year (2026). | Added `maxDateStr` computed property (+5 years from current year) and bound `:max="maxDateStr"` to `<ion-datetime>`. |

---

## 📁 File-by-File Technical Changes

### 1. `app/assets/css/schedule.css`
- **Updated `.dateItem` class** to apply rounded border radius and soft drop shadow:
```css
.dateItem {
  margin: 0 auto;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  background: #ffffff;
}
```

---

### 2. `app/apis/vehicleRental.repository.ts`
- **Updated `getVehicleSchedule` method** to accept optional `year` and `month` parameters and pass them in query string (`GET /mobile/catalog/vehicles/{id}/schedule?year=...&month=...`):

```typescript
getVehicleSchedule(id: number | string, year?: number, month?: number) {
  const query: Record<string, any> = {}
  if (year !== undefined) query.year = year
  if (month !== undefined) query.month = month
  return useApiClient<ApiResponseWrapper<VehicleScheduleData>>(
    `/api/proxy/mobile/catalog/vehicles/${id}/schedule`,
    {
      method: 'GET',
      query,
      key: `catalog-vehicle-schedule-${id}-${year ?? ''}-${month ?? ''}`,
    },
  )
}
```

---

### 3. `app/pages/vehicle-rental/schedule/index.vue`

#### A. Multi-Month Schedule State & Dynamic Fetching
- Created `schedulesByMonth` reactive map to store schedule responses keyed by `${year}-${month}` (e.g., `"2026-8"`, `"2027-1"`).
- Added `fetchScheduleForMonth(year, month)` to retrieve schedules from backend on demand.
- Added `initUpcomingMonths()` to pre-fetch current and upcoming 12 months for smooth navigation.

```typescript
const schedulesByMonth = ref<Record<string, VehicleScheduleData>>({});
const fetchingMonthsSet = ref(new Set<string>());

const fetchScheduleForMonth = async (year: number, month: number) => {
  const idNum = Number(vehicleId.value);
  if (!idNum) return;
  const key = `${year}-${month}`;
  if (schedulesByMonth.value[key] || fetchingMonthsSet.value.has(key)) {
    return;
  }
  fetchingMonthsSet.value.add(key);
  try {
    const { data: resData } = await vehicleRentalRepository.getVehicleSchedule(idNum, year, month);
    if (resData.value?.data) {
      schedulesByMonth.value = {
        ...schedulesByMonth.value,
        [key]: resData.value.data,
      };
    }
  } catch (err) {
    console.error(`[Schedule] Failed to fetch schedule for ${key}:`, err);
  } finally {
    fetchingMonthsSet.value.delete(key);
  }
};
```

#### B. Per-Month Date Enabling Logic (`isDateEnabled`)
- Extracted `year` and `month` from target date string (e.g. `"2027-01-15"` $\rightarrow$ `2027`, `1`).
- Dynamically triggers fetch for un-cached months while checking target date against that specific month's `availableDates` and `unavailableDates`:

```typescript
const isDateEnabled = (dateStr: string) => {
  if (!dateStr) return false;
  const formatted = dateStr.split("T")[0] ?? "";
  if (!formatted || formatted < todayStr.value) {
    return false;
  }

  const parts = formatted.split("-");
  if (parts.length < 3) return false;
  const y = parseInt(parts[0]!, 10);
  const m = parseInt(parts[1]!, 10);
  if (isNaN(y) || isNaN(m)) return false;

  const key = `${y}-${m}`;
  const schedule = schedulesByMonth.value[key];

  if (!schedule) {
    fetchScheduleForMonth(y, m);
    return true;
  }

  if (Array.isArray(schedule.unavailableDates)) {
    const unavailableList = schedule.unavailableDates.map((d) => d.split("T")[0]);
    if (unavailableList.includes(formatted)) {
      return false;
    }
  }

  if (Array.isArray(schedule.availableDates) && schedule.availableDates.length > 0) {
    const availableList = schedule.availableDates.map((d) => d.split("T")[0]);
    if (!availableList.includes(formatted)) {
      return false;
    }
  }

  return true;
};
```

#### C. Future Year Selection Support (`maxDateStr`)
- Added `maxDateStr` computed property allowing year selection up to +5 years from current year:
```typescript
const maxDateStr = computed(() => {
  const today = new Date();
  const year = today.getFullYear() + 5;
  return `${year}-12-31`;
});
```
- Bound `:max="maxDateStr"` to `<ion-datetime>` element:
```html
<ion-datetime
  v-model="datetimeValue"
  presentation="date"
  mode="md"
  :min="todayStr"
  :max="maxDateStr"
  :multiple="showTwoCols"
  :highlighted-dates="highlightedDates"
  :is-date-enabled="isDateEnabled"
  class="dateItem"
></ion-datetime>
```

---

## 🔍 Verification Summary

- **Future Months**: Navigating to August 2026, September 2026, ..., January 2027 dynamically fetches schedule data and enables dates in `availableDates`.
- **Future Years**: Month/Year selection wheel now lists future years (2026, 2027, 2028, 2029, 2030, 2031).
- **Styling**: `<ion-datetime>` renders with drop shadow elevation and rounded corners.
