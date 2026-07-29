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
