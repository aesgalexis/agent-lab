# Arquitectura del laboratorio

## Decisiones de la fase 1

Agent Canvas es la interfaz principal actual de OpenHands. Se usa la distribución todo-en-uno oficial, que contiene el cliente web, Agent Server, Automation Server e ingress. No se usa `openhands serve`, que corresponde a la GUI legacy.

Docker define la frontera de confianza. El agente recibe un único montaje de lectura/escritura: `/projects/sandbox-project`. Ollama se ejecuta como servicio separado en la misma red de Compose. Esto permite sustituir la inferencia sin modificar el contenedor del agente.

Las versiones se fijan en `.env.example` y se copian a `.env` durante el bootstrap. Actualizarlas debe ser una decisión explícita y verificada, no un efecto accidental de `latest`.

## Componentes

| Componente | Responsabilidad | Ubicación |
| --- | --- | --- |
| Agent Canvas | UI, conversaciones, terminal, archivos y configuración | contenedor `agent-lab-canvas` |
| OpenHands Agent Server 1.44.0 | ejecución del agente y sus herramientas | incluido en Agent Canvas 1.16.0 |
| Ollama | API de inferencia local compatible con OpenAI | contenedor `agent-lab-ollama` |
| Qwen 2.5 Coder 7B | modelo inicial de código | `%USERPROFILE%/.ollama` |
| Docker Desktop/WSL 2 | runtime y aislamiento Linux | dependencia externa de Windows |
| `sandbox-project` | workspace controlado para la prueba | repositorio, montado de forma exclusiva |
| `fixtures` | estado defectuoso reproducible para repetir la prueba | repositorio, fuera del montaje del agente |

## Flujo de una tarea

1. El navegador envía la tarea a Agent Canvas en `127.0.0.1:8000`.
2. Agent Server construye el contexto y llama a `http://ollama:11434/v1`.
3. Ollama ejecuta el modelo y devuelve la siguiente acción.
4. Las herramientas del agente leen, escriben o ejecutan comandos dentro del contenedor.
5. El único código del host visible es `sandbox-project`.
6. Los cambios aparecen directamente en Git y se revisan con `git diff -- sandbox-project`.

El perfil `ollama-local` usa la interfaz OpenAI-compatible con `native_tool_calling=false`. Qwen 2.5 Coder 7B sobre Ollama puede serializar una llamada nativa como JSON de texto; el conversor de herramientas del SDK transforma en cambio las acciones a eventos estructurados que Agent Server puede ejecutar.

## Seguridad y red

- Los puertos publicados se ligan a `127.0.0.1`, no a la LAN.
- Ollama escucha en `0.0.0.0` sólo dentro de su contenedor para aceptar tráfico de la red Compose.
- `.env` contiene secretos locales y está ignorado por Git.
- No se monta el socket Docker ni el repositorio completo en Agent Canvas.
- No se conectan GitHub, repositorios existentes, secretos personales ni servicios cloud.

El modelo y el agente pueden generar acciones incorrectas. El contenedor reduce el alcance en archivos, pero no convierte la ejecución de código desconocido en una operación sin riesgo.

## Evolución prevista

- **Cambiar de modelo:** añadir perfiles LLM y cambiar `OLLAMA_MODEL`.
- **Modelos mayores:** mover `OLLAMA_DATA_PATH` a otro disco y ampliar RAM/GPU.
- **GPU remota:** detener el servicio Ollama local y apuntar el perfil a un endpoint OpenAI-compatible remoto mediante VPN o túnel autenticado.
- **Varios modelos:** mantener varios perfiles; Ollama comparte el almacén de pesos.
- **Varios agentes:** separar front-end y backends de Agent Canvas en puertos distintos o añadir servicios de Agent Server.
- **Interfaz propia:** consumir Agent Server directamente y mantener Ollama detrás de la misma interfaz compatible.
- **Orquestación multiagente:** añadir una capa separada; no acoplarla al runtime de inferencia ni al workspace base.

La separación estable es `interfaz -> backend de agente -> endpoint LLM -> workspace`. Mientras se conserve, cada capa puede migrar de forma independiente.
