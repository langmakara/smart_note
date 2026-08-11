# Table Column Order API & Database Storage Specification

This document provides the database schema, REST API design, detailed field specification, and frontend integration guide for persisting user-customized column ordering in `InfiniteScrollTable`.

---

## 1. Deep-Dive Specification: `column_order` Field

### What is `column_order`?
`column_order` is an ordered array of column string `id`s serialized as JSON. It records the exact **left-to-right visual order** of table columns after a user drags and drops them.

### Mapping to React Code (`columns` definition)
Each column defined in React (`organization/index.jsx`) has a unique `id`:

```javascript
const columns = useMemo(() => [
  { id: "no",               Header: "Nº" },
  { id: "organizationCode", Header: "Customer Code", accessor: "organizationCode" },
  { id: "organizationName", Header: "Customer Name", accessor: "organizationName" },
  { id: "sourceName",       Header: "Source",        accessor: "sourceName" },
  { id: "telephone",        Header: "Telephone",     accessor: "telephone" },
  { id: "contactName",      Header: "Contact Name",  accessor: "contactName" },
  { id: "created",          Header: "Created Date",  accessor: "created" },
  { id: "action",           Header: "Action" }
], []);
```

### Examples of `column_order` Values

#### **A. Default Order (Original sequence)**
```json
["no", "organizationCode", "organizationName", "sourceName", "telephone", "contactName", "created", "action"]
```

#### **B. User moves "Telephone" to the FIRST position**
- **Visual Order in Table**: `Telephone` | `Nº` | `Customer Code` | `Customer Name` | `Source` | `Contact Name` | `Created Date` | `Action`
- **Database Value in `column_order`**:
```json
["telephone", "no", "organizationCode", "organizationName", "sourceName", "contactName", "created", "action"]
```

#### **C. User moves "Nº" to the LAST position**
- **Visual Order in Table**: `Customer Code` | `Customer Name` | `Source` | `Telephone` | `Contact Name` | `Created Date` | `Action` | `Nº`
- **Database Value in `column_order`**:
```json
["organizationCode", "organizationName", "sourceName", "telephone", "contactName", "created", "action", "no"]
```

### Backend Object / Entity Mapping Example (Java Spring Boot)

```java
@Entity
@Table(name = "tbl_user_column_setting")
public class UserColumnSetting {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "table_id", nullable = false, length = 100)
    private String tableId; // e.g. "organization-table"

    @Column(name = "column_order", columnDefinition = "TEXT", nullable = false)
    private String columnOrder; // JSON string e.g. "[\"telephone\",\"no\",...]"
}
```

---

## 2. Database Table Design (Schema)

Create a table named `tbl_user_column_setting` (or `user_table_column_settings`) to store user preferences per table.

### SQL DDL (MySQL / MariaDB)

```sql
CREATE TABLE `tbl_user_column_setting` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT 'ID of the logged-in user',
  `table_id` VARCHAR(100) NOT NULL COMMENT 'Unique key of the table e.g. organization-table, lead-table',
  `column_order` TEXT NOT NULL COMMENT 'JSON array string of column IDs, e.g. ["no","organizationCode","organizationName"]',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_table` (`user_id`, `table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### SQL DDL (PostgreSQL)

```sql
CREATE TABLE user_column_settings (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  table_id VARCHAR(100) NOT NULL,
  column_order JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uk_user_table UNIQUE (user_id, table_id)
);
```

### Field Descriptions

| Column Name | Data Type | Key | Description |
| :--- | :--- | :--- | :--- |
| `id` | BIGINT | PRIMARY KEY | Auto-increment primary key |
| `user_id` | BIGINT | FOREIGN KEY | Identifies which user configured this order |
| `table_id` | VARCHAR(100) | UNIQUE (user_id, table_id) | Unique table key (e.g. `organization-table`, `lead-table`) |
| `column_order` | TEXT / JSON / JSONB | - | Array of column IDs in user's custom sequence |
| `created_at` | DATETIME | - | Record creation timestamp |
| `updated_at` | DATETIME | - | Record update timestamp |

---

## 3. API Endpoints Specification

### 3.1 Get Saved Column Order for a Table

- **HTTP Method**: `GET`
- **URL Path**: `/api/v1/user-column-settings/{tableId}`
- **Headers**: 
  - `Authorization: Bearer <token>`
- **Response (200 OK)**:

```json
{
  "status": true,
  "data": {
    "tableId": "organization-table",
    "columnOrder": [
      "telephone",
      "no",
      "organizationCode",
      "organizationName",
      "sourceName",
      "contactName",
      "created",
      "action"
    ]
  }
}
```

---

### 3.2 Save / Update Column Order for a Table (Upsert)

- **HTTP Method**: `POST` (or `PUT`)
- **URL Path**: `/api/v1/user-column-settings`
- **Headers**:
  - `Authorization: Bearer <token>`
  - `Content-Type: application/json`
- **Request Body**:

```json
{
  "tableId": "organization-table",
  "columnOrder": [
    "telephone",
    "no",
    "organizationCode",
    "organizationName",
    "sourceName",
    "contactName",
    "created",
    "action"
  ]
}
```

- **Response (200 OK)**:

```json
{
  "status": true,
  "message": "Column order updated successfully",
  "data": {
    "tableId": "organization-table",
    "updatedAt": "2026-08-11T15:34:00Z"
  }
}
```

---

## 4. Frontend Integration Flow (`InfiniteScrollTable.jsx`)

When integrating API persistence into `InfiniteScrollTable`:

1. **On Table Mount (`useEffect`)**: Call `GET /api/v1/user-column-settings/{tableId}` to retrieve `columnOrder`. If data exists, invoke `setColumnOrder(data.columnOrder)`.
2. **On Drag & Drop (`handleDrop`)**: Call `POST /api/v1/user-column-settings` with `{ tableId, columnOrder: newOrder }`.

### Sample Integration Code Snippet:

```javascript
// 1. Fetch saved order from API on mount
useEffect(() => {
  if (tableId && isMoveColumn) {
    apiClient.get(`/api/v1/user-column-settings/${tableId}`)
      .then((res) => {
        const savedOrder = res.data?.data?.columnOrder;
        if (Array.isArray(savedOrder) && savedOrder.length > 0) {
          setColumnOrder(savedOrder);
        }
      })
      .catch((err) => console.error("Failed to fetch column order", err));
  }
}, [tableId, isMoveColumn]);

// 2. Save order to API after drag & drop
const saveColumnOrder = (newOrder) => {
  if (tableId && isMoveColumn) {
    apiClient.post(`/api/v1/user-column-settings`, {
      tableId,
      columnOrder: newOrder,
    }).catch((err) => console.error("Failed to save column order", err));
  }
};
```
