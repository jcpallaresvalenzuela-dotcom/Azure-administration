# 🔄 GitHub Actions – ACR Repository Cleanup

Este repositorio contiene **dos workflows** en GitHub Actions para gestionar y eliminar todos los repositorios de un **Azure Container Registry (ACR)**.

---

## 📂 Workflows

### 1. `reusable-acr-delete-repos.yml`
**Ubicación:** `.github/workflows/reusable-acr-delete-repos.yml`

Este workflow permite **listar y eliminar** todos los repositorios dentro de un ACR.

- **Inputs:**
  - `dry-run` (boolean) → Si está en `true`, solo lista los repositorios sin eliminarlos.
- **Secrets requeridos:**
  - `SERVICE_PRINCIPAL` → Credenciales de Azure en formato JSON (`az ad sp create-for-rbac --sdk-auth`).
  - `ACR_NAME` → Nombre corto del ACR 
  - **Modo de ejecución:**
  - Puede ejecutarse **manualmente** desde la pestaña *Actions* (`workflow_dispatch`).
  - Puede ser **reutilizado** por otros workflows mediante `workflow_call`.

🔑 Este workflow está pensado tanto para pruebas (con `dry-run`) como para ser invocado desde otros workflows.

---

### 2. `scheduled-acr-delete.yml`
**Ubicación:** `.github/workflows/scheduled-acr-delete.yml`

Este workflow se encarga de **ejecutar automáticamente** la limpieza de repositorios en el ACR.

- **Triggers:**
  - **`schedule`** → Todos los días a las **01:00 UTC**.  
    - En España:  
      - Verano (CEST, UTC+2) → 03:00 hora local  
      - Invierno (CET, UTC+1) → 02:00 hora local
  - **`workflow_dispatch`** → Puede lanzarse manualmente desde *Actions* para ejecutar la limpieza en el momento.
- **Secrets requeridos:**
  - `SERVICE_PRINCIPAL`
  - `ACR_NAME`
- **Comportamiento:**
  - Siempre elimina los repositorios encontrados (**sin modo `dry-run`**).
  - Internamente, llama al workflow `reusable-acr-delete-repos.yml` pasándole `dry-run: false`.

---

## 🛠 Requisitos previos

1. **Service Principal en Azure** con permisos:
   - `AcrPull` (listar repositorios).
   - `AcrDelete` (eliminarlos).
2. Guardar las credenciales en el secret `SERVICE_PRINCIPAL`.
3. Guardar el nombre corto del ACR en el secret `ACR_NAME`.

---

## ▶️ Ejecución

- **Manual (testing / dry-run):**
  - Ir a *Actions* → seleccionar `Reusable - Delete all repositories in ACR (Azure CLI)` → *Run workflow*.
  - Elegir `dry-run: true` para solo listar.

- **Automática (producción):**
  - El workflow `Scheduled - Delete ACR repos` correrá todos los días a la hora programada.
  - También se puede disparar manualmente para ejecutar la limpieza inmediata.

---

## 📌 Notas

- Si se define `dry-run: true`, no se elimina nada, solo se listan los repositorios.
- El secreto `ACR_NAME` **debe ser solo el nombre corto** del ACR, nunca la URL completa.
- Los tiempos de ejecución pueden variar unos minutos debido a la programación de GitHub Actions.
