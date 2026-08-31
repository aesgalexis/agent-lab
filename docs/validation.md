# Registro de validación

Fecha: 31-08-2026, zona horaria Europe/Madrid.

## Completado

| Comprobación | Resultado |
| --- | --- |
| Repositorio remoto | `origin=https://github.com/aesgalexis/agent-lab.git` |
| Git | 2.55.0 |
| Ollama nativo | 0.33.2, API limitada a `127.0.0.1:11434` |
| Modelo | `qwen2.5-coder:7b`, inventariado por `GET /v1/models` |
| Respuesta del modelo | `AGENT_LAB_MODEL_OK`, 6,8 s en primera medición y 7,5 s desde el script |
| Hardware de inferencia | CPU; AMD Radeon 740M descartada por controlador incompatible |
| Docker Desktop | 4.88.1, instalación por usuario |
| Docker CLI | 29.7.2 |
| Docker Compose | 5.4.0 |
| Compose del laboratorio | sintaxis, imágenes y servicios validados con `docker compose config` |
| Scripts PowerShell | todos analizados por el parser sin errores |
| Exclusión de secretos/estado | `.env` y `.runtime/` confirmados mediante `git check-ignore` |
| Fixture del agente | dos tests fallan antes de la reparación, como se esperaba |

## Pendiente tras reinicio

1. Habilitar las características WSL y Virtual Machine Platform desde PowerShell como administrador.
2. Reiniciar Windows, actualizar WSL e iniciar Docker Desktop.
3. Descargar/verificar las dos imágenes fijadas y arrancar Compose.
4. Configurar el perfil local en Agent Canvas.
5. Ejecutar la tarea de `sandbox-project/TASK.md` con OpenHands.
6. Verificar tests, `AGENT_RESULT.md`, conversación y diff; crear un commit separado con el resultado del agente.

No se marca la prueba OpenHands como completada hasta disponer de esas evidencias.
