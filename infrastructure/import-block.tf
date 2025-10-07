import {
  to = azurerm_key_vault_secret.POSTGRES_PORT-V14
  id = "https://plumsi-sandbox.vault.azure.net/secrets/recipe-backend-POSTGRES-PORT-V14/a841fe458dfd4d51b90be0fa2af55855"
}

import {
  to = azurerm_key_vault_secret.POSTGRES_DATABASE-V14
  id = "https://plumsi-sandbox.vault.azure.net/secrets/recipe-backend-POSTGRES-DATABASE-V14/b86f01ae5c4841e2b6437c0b8eb484fe"
}

import {
  to = module.plum-redis-storage.azurerm_resource_group.cache-resourcegroup[0]
  id = "/subscriptions/bf308a5c-0624-4334-8ff8-8dca9fd43783/resourceGroups/plum-recipe-backend-session-storage-cache-sandbox"
}

import {
  to = module.postgresql_flexible.azurerm_resource_group.rg[0]
  id = "/subscriptions/bf308a5c-0624-4334-8ff8-8dca9fd43783/resourceGroups/plum-v14-flexible-data-sandbox"
}

