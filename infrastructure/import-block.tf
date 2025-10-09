# Import blocks for existing Redis resources

# Import the existing Redis cache
import {
  to = module.plum-redis-storage.azurerm_redis_cache.redis
  id = "/subscriptions/bf308a5c-0624-4334-8ff8-8dca9fd43783/resourceGroups/plum-recipe-backend-session-storage-cache-sandbox/providers/Microsoft.Cache/redis/plum-recipe-backend-session-storage-sandbox"
}

import {
  to = module.plum-redis-storage.azurerm_private_endpoint.this[0]
  id = "/subscriptions/bf308a5c-0624-4334-8ff8-8dca9fd43783/resourceGroups/plum-recipe-backend-session-storage-cache-sandbox/providers/Microsoft.Network/privateEndpoints/plum-recipe-backend-session-storage-sandbox"
}




