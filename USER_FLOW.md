# User Flow - Smart Notes

## 1. App Launch Flow

```
┌─────────────────────────────────────┐
│         App Launch                   │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│      Loading Screen                  │
│   (Initialization & Setup)           │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│   Security Check                     │
│   (Password Enabled?)                │
└──────────┬───────────────────────────┘
           │
     ┌─────┴─────┐
     │            │
    Yes          No
     │            │
     ▼            ▼
┌──────────┐  ┌─────────────────┐
│ Password │  │  Main Wrapper   │
│ Verify   │  │  (Home Page)    │
└────┬─────┘  └─────────────────┘
     │
     ▼ (Success)
┌─────────────────┐
│  Main Wrapper   │
│  (Home Page)    │
└─────────────────┘
```

## 2. Main Navigation Flow

```
┌─────────────────────────────────────────────────┐
│              Bottom Navigation                   │
├───────────┬───────────┬────────────┬────────────┤
│   Home    │  Calendar │  Alerts    │  Settings  │
└─────┬─────┴─────┬─────┴──────┬─────┴──────┬─────┘
      │           │            │            │
      ▼           ▼            ▼            ▼
┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐
│  Notes    │ │  Events   │ │Notifs     │ │Appearance│
│  Todos    │ │  Calendar │ │  List     │ │Security  │
│  Summary  │ │  Grid     │ │           │ │Language  │
└───────────┘ └───────────┘ └───────────┘ │Notifs    │
                                          └───────────┘
```

## 3. Home Page User Flow

```
┌─────────────────────────────────────┐
│           Home Page                  │
└─────────────────┬───────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐ ┌─────────────────┐
│   Quick Add     │ │   View Recent   │
│   FAB Button    │ │   Items         │
└────────┬────────┘ └────────┬────────┘
         │                    │
         ▼                    ▼
┌─────────────────┐ ┌─────────────────┐
│   Select Type   │ │  Item Detail    │
│   (Note/Todo/   │ │  Bottom Sheet   │
│   Event)        │ └────────┬────────┘
└────────┬────────┘          │
         │                   ▼
         ▼          ┌─────────────────┐
┌─────────────────┐│   Edit/Delete    │
│   Create New    ││   Options        │
│   Item          │└─────────────────┘
└─────────────────┘
```

## 4. Notes Management Flow

```
┌─────────────────────────────────────┐
│        Create Note                   │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│   Note Edit Page                     │
│   - Title Input                      │
│   - Content Editor                   │
│   - Save Button                      │
│   - Delete Button (if exists)       │
└──────────┬───────────────────────────┘
           │
     ┌─────┴─────┐
     │            │
    Save        Delete
     │            │
     ▼            ▼
┌──────────┐  ┌──────────┐
│  Return  │  │ Confirm  │
│  to Home │  │  Delete  │
└──────────┘  └────┬─────┘
                   │
                   ▼
            ┌──────────┐
            │  Return  │
            │  to Home │
            └──────────┘
```

## 5. To-Do Management Flow

```
┌─────────────────────────────────────┐
│        Create To-Do                 │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│   To-Do Edit Page                    │
│   - Title Input                      │
│   - Description (Optional)           │
│   - Due Date/Time                     │
│   - Priority Level                   │
│   - Reminder Toggle                   │
│   - Save Button                      │
└──────────┬───────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│   Home Page (Updated)               │
│   - New To-Do in list                │
│   - Checkbox to mark complete        │
└─────────────────────────────────────┘
```

## 6. Calendar & Events Flow

```
┌─────────────────────────────────────┐
│        Calendar Page                 │
└─────────────────┬───────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐ ┌─────────────────┐
│  Tap Date on    │ │  Tap Event      │
│  Calendar Grid  │ │  Card           │
└────────┬────────┘ └────────┬────────┘
         │                    │
         ▼                    ▼
┌─────────────────┐ ┌─────────────────┐
│  Events List    │ │  Event Detail   │
│  for Selected  │ │  Bottom Sheet   │
│  Date           │ │  - Edit         │
└────────┬────────┘ │  - Delete       │
         │          └────────┬────────┘
         ▼                    │
┌─────────────────┐            ▼
│  + Add Event    │   ┌─────────────────┐
│  (FAB)          │   │  Event Edit    │
└────────┬────────┘   │  Page          │
         │            └─────────────────┘
         ▼
┌─────────────────┐
│  Event Edit     │
│  Page           │
└─────────────────┘
```

## 7. Notifications Flow

```
┌─────────────────────────────────────┐
│      Notifications Page              │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│   Notification List                  │
│   - Event Reminders                  │
│   - To-Do Due Reminders              │
│   - Sorted by time                   │
└──────────┬───────────────────────────┘
           │
           ▼
┌─────────────────────────────────────┐
│   Tap Notification                   │
│   - Navigate to related item         │
│   - Mark as read                     │
│   - Delete notification              │
└─────────────────────────────────────┘
```

## 8. Settings Flow

```
┌─────────────────────────────────────┐
│         Settings Page                │
└─────────────────┬───────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    ▼             ▼             ▼
┌────────┐   ┌──────────┐   ┌──────────┐
│Appear- │   │Security  │   │ Language │
│ance    │   │          │   │          │
└───┬────┘   └────┬─────┘   └────┬─────┘
    │             │             │
    ▼             ▼             ▼
┌────────┐   ┌──────────┐   ┌──────────┐
│ -Theme │   │ -Password│   │ -Select  │
│ -Color │   │  Enable  │   │  Language│
└────────┘   │ -Change  │   └──────────┘
             │  PIN     │
             └────┬─────┘
                  │
                  ▼
          ┌──────────────┐
          │ Notification │
          │ Settings     │
          └──────────────┘
```

## 9. Security Settings Flow

```
┌─────────────────────────────────────┐
│      Security Settings               │
└─────────────────┬───────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐ ┌─────────────────┐
│  Enable Password│ │  Disable Password│
│  (First Time)   │ │  (Verify First)  │
└────────┬────────┘ └────────┬────────┘
         │                   │
         ▼                   ▼
┌─────────────────┐ ┌─────────────────┐
│  Set 4-6 Digit  │ │  Return to      │
│  PIN            │ │  Settings       │
└────────┬────────┘ └─────────────────┘
         │
         ▼
┌─────────────────┐
│  Confirm PIN   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Password      │
│  Enabled       │
└─────────────────┘
```

## 10. Theme/Appearance Flow

```
┌─────────────────────────────────────┐
│    Appearance Settings                │
└─────────────────┬───────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐ ┌─────────────────┐
│   Dark Mode     │ │  Accent Color   │
│   Toggle        │ │  Picker         │
│                 │ │                 │
│   - Light       │ │  - Color Grid   │
│   - Dark        │ │  - Preview      │
│   - System      │ │  - Apply        │
└─────────────────┘ └─────────────────┘
```

## 11. Complete User Journey Summary

### New User First Launch
1. App loads → Initialize database
2. Security check → Password disabled (default)
3. Navigate to Home Page
4. See empty state with prompt to create first item

### Returning User (No Security)
1. App loads → Initialize
2. Security check → Skip (not enabled)
3. Navigate to Home Page

### Returning User (With Security)
1. App loads → Initialize
2. Security check → Password screen
3. Enter correct PIN
4. Navigate to Home Page

### Creating Content
1. Tap FAB on Home Page
2. Select type (Note/To-Do/Event)
3. Fill in details
4. Save → Return to Home

### Managing Existing Content
1. Tap item on Home/Calendar
2. View detail bottom sheet
3. Edit or Delete
4. Changes saved automatically

### Customizing App
1. Go to Settings
2. Adjust appearance (theme/colors)
3. Enable security (password)
4. Change language
5. Configure notifications

---

## Screen List

| Screen | Purpose |
|--------|---------|
| Loading Screen | App initialization |
| Security Page | Password verification/setup |
| Home Page | Notes, To-Dos, quick actions |
| Note Edit Page | Create/edit notes |
| To-Do Edit Page | Create/edit to-dos |
| Calendar Page | View calendar and events |
| Event Edit Page | Create/edit calendar events |
| Notifications Page | View reminders and alerts |
| Settings Page | App configuration |
| Appearance Settings | Theme and color options |
| Security Settings | Password management |
| Language Settings | Language selection |
| Notification Settings | Alert preferences |
