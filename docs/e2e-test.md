# Prueba de extremo a extremo

La prueba parte de un fallo deliberado en `sandbox-project/src/text_stats.py`. El agente debe leer la tarea, inspeccionar archivos, corregir el código, ejecutar `unittest` y dejar un resumen. No se debe corregir manualmente antes de la conversación.

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

1. Abre <http://127.0.0.1:8000/canvas>.
2. En `Settings > LLM`, pestaña `Advanced`, crea `ollama-qwen-coder-7b`.
3. Usa modelo `openai/qwen2.5-coder:7b`, base URL `http://ollama:11434/v1` y API key `local-llm`.
4. En `Settings > Agent`, asigna ese perfil al agente OpenHands.
5. Abre el workspace `/projects/sandbox-project`.

## 4. Tarea del agente

Copia como mensaje el contenido de `sandbox-project/TASK.md`. No le des instrucciones adicionales ni edites el proyecto durante la ejecución.

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
