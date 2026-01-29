/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_VORTEX_DAO_ADDRESS: string
  readonly VITE_VORTEX_RESOLVER_ADDRESS: string
  readonly VITE_PELLION_SHIELD_ADDRESS: string
  readonly VITE_RPC_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
