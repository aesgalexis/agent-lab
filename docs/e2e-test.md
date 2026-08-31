# Prueba de extremo a extremo

La prueba parte de un fallo deliberado en `sandbox-project/src/text_stats.py`. El agente debe leer la tarea, inspeccionar archivos, corregir el código, ejecutar `unittest` y dejar un resumen. El repositorio conserva el resultado validado; para repetir la demostración, restaura primero el fixture de forma explícita:

```powershell
.\scripts\reset-sandbox.ps1
```

## 1. Línea base

```powershell
git status --short
docker compose run --rm --no-deps agent-canvas bash -lc "cd /projects/sandbox-project && python -m unittest discover -s tests -v"
```

El test `test_counts_words_not_characters` debe fallar. Esto demuestra que la prueba detecta el defecto inicial.

## 2. Servicios y modelo

```powershell
.\scripts\start.ps1
.\scripts\status.ps1
.\scripts\test-model.ps1
```

La última orden debe mostrar `AGENT_LAB_MODEL_OK` y el identificador `qwen2.5-coder:7b`.

## 3. Configurar Agent Canvas

`start.ps1` llama a `configure-openhands.ps1`. Este script usa la API actual de Agent Server para validar una inferencia, guardar y activar `ollama-local`, y registrar `/projects/sandbox-project`. La clave de sesión se lee de `.env` y nunca se imprime.

Para comprobarlo o regenerarlo sin reiniciar:

```powershell
.\scripts\configure-openhands.ps1
```

## 4. Tarea del agente

Desde el fixture restaurado, ejecuta:

```powershell
.\scripts\run-agent-test.ps1
```

El script crea una conversación con las herramientas `terminal` y `file_editor`, `native_tool_calling=false`, máximo 20 iteraciones y workspace limitado. También puede hacerse desde <http://127.0.0.1:8000/canvas> usando el perfil `ollama-local` y el contenido de `sandbox-project/TASK.md`.

El resultado esperado es:

- el agente lee `README.md`, `TASK.md`, el código y los tests;
- modifica `src/text_stats.py`;
- ejecuta `python -m unittest discover -s tests -v`;
- crea `AGENT_RESULT.md`;
- los tests terminan en `OK`.

## 5. Evidencias y revisión

```powershell
.\scripts\verify-agent-result.ps1
git status --short
git diff -- sandbox-project
```

Revisa el diff antes de aceptar o confirmar cambios. Conserva la conversación en `.runtime/openhands` y realiza un commit separado para el resultado del agente; así se distingue con claridad la infraestructura del trabajo producido por el modelo.

La primera carga de contexto en CPU puede tardar varios minutos. Las iteraciones posteriores reutilizan caché y fueron notablemente más rápidas en el PC validado.
