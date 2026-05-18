library trippo_shared;

// Models
export 'src/models/user_model.dart';
export 'src/models/driver_model.dart';
export 'src/models/trip_model.dart';
export 'src/models/vehicle_model.dart';
export 'src/models/location_model.dart';
export 'src/models/wallet_model.dart';
export 'src/models/notification_model.dart';
export 'src/models/pricing_model.dart';
export 'src/models/dispatch_model.dart';
export 'src/models/promo_model.dart';

// Services
export 'src/services/api_service.dart';
export 'src/services/socket_service.dart';
export 'src/services/gps_tracking_service.dart';
export 'src/services/pricing_service.dart';
export 'src/services/notification_service.dart';
export 'src/services/dispatch_service.dart';
export 'src/services/geo_spatial_service.dart';
export 'src/services/anti_fraud_service.dart';
export 'src/services/promo_service.dart';
export 'src/services/event_bus_service.dart';
export 'src/services/offline_service.dart';
export 'src/services/wallet_service.dart' hide Settlement;
export 'src/services/dispatch_scoring_service.dart' hide DriverScore;

// Map Services (Open-Source)
export 'src/services/map/map_service.dart';
export 'src/services/map/osrm_routing_service.dart';
export 'src/services/map/nominatim_service.dart';
export 'src/services/map/route_parser.dart';
export 'src/services/map/tile_provider.dart';

// Theme & Design System
export 'src/theme/madar_theme.dart';

// Widgets
export 'src/widgets/madar_widgets.dart';
export 'src/widgets/madar_loading.dart';
export 'src/widgets/trippo_map.dart';
export 'src/widgets/car_marker.dart';

// Utils
export 'src/utils/kalman_filter.dart';
export 'src/utils/gps_utils.dart';
export 'src/utils/geo_utils.dart';

// Constants
export 'src/constants/trip_states.dart';
export 'src/constants/api_constants.dart';
export 'src/constants/app_constants.dart';

