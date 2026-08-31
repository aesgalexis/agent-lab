# Agent Lab

Laboratorio local, pequeño y reproducible para ejecutar un agente OpenHands sobre código aislado con un modelo servido por Ollama. La primera configuración usa `qwen2.5-coder:7b` y la interfaz moderna Agent Canvas; no usa la GUI local legacy de OpenHands ni servicios de pago.

## Estado de la fase 1

- Repositorio principal: este repositorio.
- Ollama nativo 0.33.2 instalado en Windows y modelo `qwen2.5-coder:7b` descargado.
- API local de Ollama verificada con una respuesta determinista.
- Docker Desktop 4.88.1 instalado por usuario; Docker 29.7.2 y Compose 5.4.0 verificados.
- Stack reproducible definido con Ollama 0.33.1 y Agent Canvas 1.16.0; `docker compose config` validado.
- Proyecto de prueba limitado a [`sandbox-project`](sandbox-project/README.md).
- Pendiente en este PC: habilitar WSL 2 como administrador, reiniciar, iniciar Docker Desktop y ejecutar la prueba de agente completa.

## Arquitectura

```text
Navegador
  └── http://127.0.0.1:8000/canvas
        └── Agent Canvas + Agent Server (contenedor)
              ├── /projects/sandbox-project  <── ./sandbox-project
              ├── estado persistente         <── ./.runtime/openhands
              └── http://ollama:11434/v1
                    └── Ollama (contenedor)
                          └── modelos          <── %USERPROFILE%/.ollama
```

Sólo `sandbox-project` se monta en el contenedor del agente. Agent Canvas no ve el resto de este repositorio ni otros proyectos del PC. Los puertos 8000 y 11434 se publican exclusivamente en `127.0.0.1`; el `0.0.0.0` de Ollama existe sólo dentro del contenedor.

Consulta las decisiones y extensiones previstas en [`docs/architecture.md`](docs/architecture.md).

## Requisitos de Windows

- Windows 10 22H2+ o Windows 11 compatible con WSL 2.
- Virtualización habilitada en BIOS/UEFI.
- WSL 2.1.5 o posterior.
- Docker Desktop con backend WSL 2.
- Git.

No hacen falta Node, npm ni Python en Windows: viven en el entorno del agente. Sigue [`docs/windows-setup.md`](docs/windows-setup.md) para completar el único paso de administrador pendiente.

## Arranque rápido

Desde PowerShell, en la raíz del repositorio:

```powershell
.\scripts\bootstrap.ps1
.\scripts\start.ps1
```

Abre <http://127.0.0.1:8000/canvas>. En el primer arranque crea un perfil LLM avanzado:

- Nombre: `ollama-qwen-coder-7b`
- Modelo: `openai/qwen2.5-coder:7b`
- Base URL: `http://ollama:11434/v1`
- API key: `local-llm`

Después selecciona ese perfil en `Settings > Agent`, abre el workspace `/projects/sandbox-project` y usa la tarea de [`sandbox-project/TASK.md`](sandbox-project/TASK.md). El procedimiento completo y las evidencias esperadas están en [`docs/e2e-test.md`](docs/e2e-test.md).

## Comandos habituales

```powershell
# Preparar .env y directorios persistentes
.\scripts\bootstrap.ps1

# Arrancar Ollama y Agent Canvas; descarga el modelo si falta
.\scripts\start.ps1

# Comprobar contenedores, API y modelo
.\scripts\status.ps1

# Probar directamente el endpoint compatible con OpenAI
.\scripts\test-model.ps1

# Verificar el resultado después de que trabaje el agente
.\scripts\verify-agent-result.ps1

# Detener el stack sin borrar datos
.\scripts\stop.ps1
```

## Cambiar de modelo

1. Cambia `OLLAMA_MODEL` en `.env`.
2. Ejecuta `.\scripts\start.ps1`; descargará el modelo si falta.
3. Crea o edita un perfil LLM de Agent Canvas usando `openai/<modelo>`.
4. Usa una conversación nueva o cambia de perfil con `/model`.

Para modelos de mayor tamaño probablemente hará falta más RAM o inferencia remota. No cambies `OLLAMA_CONTEXT_LENGTH` por debajo de 22000 para OpenHands; este laboratorio usa 32768.

## Persistencia y límites

| Elemento | Ubicación | Versionado |
| --- | --- | --- |
| Configuración, scripts y documentación | raíz del repositorio | Sí |
| Proyecto aislado | `sandbox-project/` | Sí |
| Secretos locales | `.env` | No |
| Conversaciones y ajustes de OpenHands | `.runtime/openhands/` | No |
| Logs generados por scripts | `.runtime/logs/` | No |
| Pesos y metadatos de Ollama | `%USERPROFILE%/.ollama/` | No |
| Imágenes y runtime Docker | almacenamiento de Docker Desktop/WSL | No |

`docker compose down` conserva todo lo anterior. No uses `down -v` ni borres `%USERPROFILE%/.ollama` salvo que quieras eliminar datos deliberadamente.

## Documentación

- [`docs/architecture.md`](docs/architecture.md): componentes, fronteras y evolución.
- [`docs/windows-setup.md`](docs/windows-setup.md): instalación y comprobaciones de Windows.
- [`docs/e2e-test.md`](docs/e2e-test.md): prueba completa y revisión de cambios.
- [`docs/troubleshooting.md`](docs/troubleshooting.md): problemas encontrados y soluciones.
- [`docs/validation.md`](docs/validation.md): evidencias ejecutadas y trabajo pendiente.

## Fuentes de referencia

La configuración sigue la documentación oficial actual de [Agent Canvas](https://docs.openhands.dev/openhands/usage/agent-canvas/setup), su [backend Docker](https://docs.openhands.dev/openhands/usage/agent-canvas/backend-setup/docker), la guía de [LLM locales de OpenHands](https://docs.openhands.dev/openhands/usage/llms/local-llms), [Ollama en Windows](https://docs.ollama.com/windows) y [Docker Desktop en Windows](https://docs.docker.com/desktop/setup/install/windows-install/).
