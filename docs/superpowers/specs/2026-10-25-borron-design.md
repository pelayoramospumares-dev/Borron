# Borrón — Documento de diseño

*Título provisional · Fecha: 2026-10-25 · Estado: borrador para revisión*

---

## 1. Resumen

**Borrón** es un metroidvania 2D dibujado a mano (sin píxeles), con combate ágil y exigente y un mundo interconectado, en la línea de *Hollow Knight: Silksong* en **estilo visual y jugabilidad**. Historia, personajes, mundo y ambientación son **100 % originales**.

El jugador controla a una gota de **Tinta** —la misma corrupción que destruyó el reino— que ha despertado con conciencia propia. Su cuerpo líquido es a la vez su arma, su forma de moverse y su condena.

**Seña de identidad técnica:** animaciones extremadamente fluidas y limpias (60–120+ FPS reales, sin animación "a saltos") y efectos de partículas de tinta espectaculares.

---

## 2. Intención y criterios de éxito

**Lo que pidió el autor**
- Un metroidvania como Silksong en visuales y jugabilidad, sin copiar historia, personajes ni ambientación.
- Tono oscuro y melancólico.
- Protagonista que forma parte del mal que destruyó el reino.
- Corrupción en forma de sombra/tinta que borra forma, memoria y nombres.
- Mecánica de cuerpo de tinta + un gran árbol de habilidades.
- Godot 4. Claude programa; el autor dirige y aprende por el camino.
- Arte: personajes por código, escenarios con Higgsfield.
- Animaciones muy suaves y limpias (60–120 FPS) y partículas que se vean geniales.
- Estilo 2D tipo Hollow Knight / Silksong. **Nada de pixel art.**
- Objetivo final de este documento: una **beta** jugable (sin versión de Steam, sin historia completa ni finales).

**Suposiciones (pueden corregirse)**
- Plataforma objetivo: PC (Windows/Linux/macOS) con teclado y mando.
- Idioma del juego: español (textos preparados para traducir más adelante).
- El juego se desarrolla en dos hitos: **Prototipo 1** y **Beta** (ver §9).

**El juego funciona si…**
- Moverse se siente ágil, preciso y "líquido" desde el primer minuto.
- El combate es exigente pero justo; morir se siente culpa del jugador, no del juego.
- Las animaciones nunca dan tirones y las partículas hacen que cada golpe se sienta potente.
- El jugador quiere seguir explorando para encontrar el siguiente atajo, Recuerdo o habilidad.

---

## 3. Mundo y tono

Un reino antiguo yace en ruinas, devorado por **la Tinta**: una marea oscura que borró formas, recuerdos y nombres. Lo que queda son siluetas incompletas, edificios a medio borrar y supervivientes que han olvidado quiénes eran.

El protagonista es una gota de esa Tinta que despertó con voluntad. Los supervivientes le temen. Nadie sabe por qué piensa, ni siquiera él.

**Pilares de tono:** melancolía, silencio, belleza en la decadencia, soledad con destellos de ternura.

### Zonas de la beta

| # | Zona | Ambiente | Habilidad llave |
|---|------|----------|-----------------|
| 1 | **Las Afueras Borradas** | Aldea en ruinas a medio borrar, niebla gris, faroles apagados | **Forma charco** |
| 2 | **El Archivo Ahogado** | Biblioteca colosal inundada de Tinta, papeles flotando, estanterías como acantilados | **Hilo de tinta** (enganche/balanceo) |
| 3 | **El Pozo Madre** | Sima vertical hacia el origen de la Tinta, raíces negras, luz violeta enfermiza | **Salto salpicado** (doble salto) |

Más un **pequeño núcleo central** (un Tintero mayor) que conecta las tres zonas.

---

## 4. Jugabilidad

### 4.1 Movimiento
- Correr con aceleración/deceleración afinadas.
- **Salto variable** (altura según cuánto se mantiene el botón), *coyote time* y *buffer* de salto.
- **Dash** horizontal.
- **Deslizarse por paredes y salto de pared.**
- **Forma charco** (habilidad llave 1): el cuerpo se disuelve; pasa por rejillas y grietas, se desliza por superficies manchadas y atraviesa ataques con invulnerabilidad breve.
- **Hilo de tinta** (habilidad llave 2): lanza un hilo a puntos de enganche para balancearse o tirar de sí mismo.
- **Salto salpicado** (habilidad llave 3): doble salto con explosión de gotas.

### 4.2 Combate
- Ataque cuerpo a cuerpo en tres direcciones: lateral, arriba, abajo (el golpe hacia abajo rebota sobre enemigos y peligros).
- **Tinta (recurso):** se gana golpeando. Se gasta en curarse y en ataques especiales.
- **Inestabilidad:** sube al acumular Tinta sin gastarla.
  - Más Inestabilidad → más daño y velocidad, pero se recibe más daño y el cuerpo se deforma visualmente.
- **Desborde:** al llegar al máximo, estado de poder breve y brutal; al terminar, el jugador queda vulnerable unos segundos.
- **Sensación de golpe:** *hit-stop* (congelado de 2–6 fotogramas), retroceso, sacudida de cámara proporcional y salpicaduras de tinta.
- **Muerte:** el jugador reaparece en el último Tintero y deja una **mancha** donde murió con parte de sus Recuerdos no gastados; tocarla los recupera. Si muere de nuevo antes, se pierden.

### 4.3 Enemigos y jefes (beta)
- **Zona 1:** patrullero, volador, tirador + jefe.
- **Zona 2:** 2 enemigos nuevos (p. ej. uno que nada en la Tinta y emerge, uno que se protege con escudo de papel) + jefe.
- **Zona 3:** 2 enemigos nuevos (p. ej. uno que se divide al morir, uno que corrompe el suelo) + jefe.
- Cada jefe con al menos 2 fases y patrones legibles (telegrafiados con animación y partículas).

### 4.4 Progresión: árbol de habilidades
- **Moneda: Recuerdos**, fragmentos de memoria del reino. Se encuentran explorando, los sueltan enemigos (poco) y jefes (mucho).
- Se gastan en los **Tinteros**.
- **Tres ramas:**

| Rama | Enfoque | Ejemplos de nodos |
|------|---------|-------------------|
| **Forma** | Defensa y control | +vida, parada, la Inestabilidad sube más lento, curación más rápida |
| **Marea** | Movimiento | Dash más largo, charco que daña, deslizarse por techos, rebote en enemigos |
| **Voracidad** | Ataque y riesgo | Tentáculos, púas, robar habilidades a enemigos, Desborde más largo |

- **Prototipo 1:** 3 nodos por rama (9).
- **Beta:** 6–8 nodos por rama (18–24), con nodos que dependen de habilidades llave.
- Regla clave: **las habilidades llave nunca están en el árbol**; el árbol solo las mejora o modifica. Así el diseño del mapa sigue siendo de metroidvania.

### 4.5 Mundo y sistemas de la beta
- **Tinteros:** guardado, descanso (reaparecen enemigos) y compra de nodos.
- **Mapa del mundo:** se revela al explorar; marcadores básicos (Tinteros, jefes derrotados, PNJ).
- **PNJ con diálogos:** 4–6 supervivientes con diálogos breves que cambian con el progreso.
- **Tienda:** 1 comerciante en el núcleo central (objetos de mejora, fragmentos de mapa), pagando con Recuerdos.
- **Guardado:** varias ranuras de partida.

---

## 5. Dirección de arte

### 5.1 Estilo
- **2D dibujado/pintado en alta resolución. Nada de pixel art.**
- Siluetas negras vivas (protagonista y enemigos) sobre **fondos pintados, desvaídos y melancólicos** con varias capas de profundidad (*parallax*).
- Resolución base **1920×1080**, assets preparados para verse nítidos hasta 4K. Filtrado suave, sin *pixel snap*.

### 5.1b Escenarios en profundidad (técnica tipo Hollow Knight)
Hollow Knight coloca dibujos 2D a distintas distancias de una cámara con perspectiva: al moverte, lo lejano se desplaza despacio y lo cercano rápido, y hay elementos que pasan **por delante** del jugador. *Borrón* reproduce ese efecto en el 2D de Godot:
- Cada elemento del escenario tiene una **profundidad** `depth` (0 = plano de juego; positiva = detrás; negativa = delante).
- Su desplazamiento sigue la fórmula de perspectiva `factor = F / (F + depth)` con `F = 1000`, idéntica a la de una cámara 3D. Así no hay solo 3 capas: puede haber decenas de elementos, cada uno a su distancia.
- **Niebla atmosférica:** cuanto más lejos, más se tiñe del color de niebla de la zona y pierde contraste. Lo que está delante del jugador se oscurece casi a silueta y se desenfoca.
- Se mantiene el 2D (en vez de 3D real) porque personajes, físicas, luces 2D y *glow* ya son 2D; el resultado visual es el mismo.

### 5.2 Paleta
- **Fondos:** grises fríos, azules apagados, sepia y blanco hueso.
- **Protagonista y Tinta:** negro profundo con brillos húmedos.
- **Recuerdos:** dorado pálido luminoso.
- **Desborde / corrupción intensa:** violeta y carmesí brillantes (con *glow*).
- **Cada zona** tiene un color de acento propio: Afueras = gris niebla; Archivo = azul tinta y papel amarillento; Pozo = violeta enfermizo.

### 5.3 Reparto de producción
- **Personajes, enemigos y jefes: código (Claude).** Formas vectoriales (Polygon2D) con esqueleto 2D y animación procedural + shaders. Es la parte que tiene que moverse con fluidez perfecta.
- **Fondos, escenarios, arte de menú, ilustraciones de Recuerdos y retratos de PNJ: Higgsfield.**
  - La conexión de Higgsfield disponible para Claude **no genera imágenes**: el autor genera en la web de Higgsfield con prompts que prepara Claude, y Claude las integra.
  - Claude mantiene una **guía de prompts** (`docs/art/prompts.md`) con estilo, paleta, iluminación y encuadre comunes para que todo sea coherente.
  - Cada fondo se genera por **capas separadas** (lejana, media y cercana). Si una capa sale con fondo, Claude lo recorta por script.

---

## 6. Animación fluida (prioridad máxima)

**Objetivo:** el juego corre a la frecuencia del monitor (60, 120, 144 Hz o más) y **toda** animación es continua, nunca fotograma a fotograma con pocos dibujos.

- **Animación procedural y esquelética** en lugar de *sprite sheets*: el cuerpo se construye con polígonos y huesos 2D, y las poses se interpolan con curvas. A 120 Hz se ven 120 poses distintas por segundo.
- **Principios de animación aplicados por código:** anticipación, *squash & stretch*, movimiento secundario (gotas y apéndices que siguen al cuerpo con física tipo muelle/verlet) y *easing* en todas las transiciones.
- **Cuerpo de tinta con shader:** bordes ondulantes, goteo y brillo húmedo; la Inestabilidad aumenta la deformación en tiempo real.
- **Interpolación de físicas** activada en Godot: la lógica corre a paso fijo y el render se interpola, sin tirones en monitores de alta frecuencia.
- **Rendimiento:** mínimo 60 FPS estables en un PC modesto; sin límite superior (V-Sync configurable en opciones).
- **Cámara suave:** seguimiento con amortiguación, anticipación en la dirección del movimiento y límites por sala.

---

## 7. Partículas y efectos (seña de identidad)

- **Partículas por GPU** (GPUParticles2D) con texturas suaves de gotas generadas por código.
- **Efectos clave:**
  - Salpicaduras de tinta al golpear, recibir daño, aterrizar, hacer dash y entrar o salir del charco.
  - Estelas líquidas en el dash y en los ataques.
  - Goteo continuo del protagonista (más intenso con Inestabilidad).
  - Explosión de Desborde con *glow* violeta y carmesí.
  - Ambiente: ceniza, polvo y papeles flotando (Archivo), esporas violetas (Pozo).
  - Recuerdos: partículas doradas luminosas.
- **Iluminación 2D:** luces puntuales (Light2D), HDR 2D y *glow* (WorldEnvironment) para que lo luminoso brille de verdad sobre lo oscuro.
- **Manchas persistentes:** la tinta salpicada deja marcas temporales en el escenario.
- **Feedback:** *hit-stop*, sacudida de cámara y destello breve en los impactos.

---

## 8. Arquitectura técnica

### 8.1 Herramientas
- **Motor:** Godot 4, la última versión estable en el momento de empezar, fijada para todo el proyecto.
- **Lenguaje:** GDScript, con tipado estático para detectar errores pronto y que el código sea fácil de leer.
- **Control de versiones:** Git, con un repositorio remoto en GitHub para que el trabajo no se pierda (el contenedor de Claude es temporal).

### 8.2 Estructura del proyecto
```
borron/
├── project.godot
├── autoload/        # Servicios globales
│   ├── game_state.gd     # Progreso: habilidades, Recuerdos, jefes, mapa
│   ├── save_manager.gd   # Guardar/cargar (JSON en user://)
│   ├── event_bus.gd      # Señales globales (jugador murió, jefe derrotado…)
│   └── audio_manager.gd  # Música por capas y efectos
├── player/          # Protagonista: máquina de estados, movimiento, combate, cuerpo procedural
├── components/      # Piezas reutilizables: Health, Hitbox, Hurtbox, InkResource…
├── enemies/         # Base común + un archivo por enemigo
├── bosses/
├── world/           # Salas por zona, transiciones, Tinteros, puertas y bloqueos
├── skills/          # Árbol de habilidades como datos (Resources .tres)
├── vfx/             # Partículas, shaders y efectos de cámara
├── ui/              # HUD, menú de pausa, árbol, mapa, diálogos, tienda
├── art/             # Fondos de Higgsfield, texturas
├── audio/
├── tests/           # Pruebas automáticas (GUT)
└── docs/
```

### 8.3 Principios
- **Una pieza, una función:** cada componente (vida, golpe, recurso de tinta) es independiente y se prueba por separado.
- **El jugador es una máquina de estados** (quieto, correr, saltar, caer, pared, dash, charco, atacar, curar, Desborde, muerto). Cada estado vive en su propio archivo.
- **Datos separados del código:** valores de movimiento, nodos del árbol y estadísticas de enemigos en *Resources* editables. El autor puede ajustar números sin tocar código.
- **Salas como escenas independientes** conectadas por transiciones; el mundo carga una sala cada vez.
- **Comunicación por señales** (EventBus) en lugar de referencias directas entre sistemas.

### 8.4 Audio (beta)
- **Efectos:** bibliotecas libres de derechos (CC0) y efectos procesados.
- **Música:** el autor la consigue (generada con una herramienta de música por IA o encargada); Claude la integra con **capas adaptativas** (la música se intensifica en combate y con Inestabilidad alta).

### 8.5 Manejo de errores
- El guardado escribe primero a un archivo temporal y luego lo renombra: un cierre inesperado nunca corrompe la partida.
- Las partidas guardadas llevan un número de versión para poder migrarlas cuando el juego cambie.
- Si un asset falta, se usa un sustituto visible (rosa) y se registra un aviso, sin cerrar el juego.

---

## 9. Hitos

### Hito 1 — Prototipo "La Primera Mancha"
**Pregunta que responde:** *¿se siente bien ser tinta?* · Duración de juego: 15–20 min.

- Movimiento completo (correr, salto variable, dash, pared) + **forma charco**.
- Combate en tres direcciones, Tinta, curación, Inestabilidad y Desborde con deformación visual.
- 3 enemigos (patrullero, volador, tirador) + 1 jefe.
- Zona 1 (unas 10 salas) con un camino bloqueado que solo se abre con la forma charco.
- Tinteros (guardado y descanso).
- Mini árbol: 9 nodos. Recuerdos escondidos.
- Fondos de Higgsfield en 2–3 salas clave; el resto, provisional.
- Animación fluida, partículas e iluminación de base ya al nivel de calidad objetivo para el protagonista.
- Teclado y mando, menú de pausa, guardado.

### Hito 2 — Beta
Todo lo del Prototipo, más:
- Zonas 2 y 3 + núcleo central; 3 jefes en total.
- Habilidades llave 2 y 3 (hilo de tinta, salto salpicado).
- Árbol completo (18–24 nodos).
- Mapa del mundo.
- PNJ con diálogos (4–6) y una tienda.
- Música y sonido definitivos.
- Fondos de Higgsfield en todas las salas.
- Mancha de muerte con Recuerdos recuperables.
- Menú de opciones (volumen, V-Sync, controles) y varias ranuras de guardado.

**Fuera de este documento:** versión de Steam, historia completa y finales.

Cada hito tendrá **su propio plan de implementación**. Primero se planifica y construye el Hito 1; el Hito 2 se planifica cuando el Prototipo esté validado.

---

## 10. Pruebas y validación

- **Pruebas automáticas (GUT)** para la lógica: árbol de habilidades, compras con Recuerdos, cálculo de Inestabilidad y Desborde, daño, guardado y carga.
- **Ejecución sin pantalla:** Claude ejecuta Godot en modo *headless* en la nube para comprobar que el proyecto carga sin errores y que las pruebas pasan.
- **Sensación de juego:** la valida el autor jugando en su ordenador. Claude no puede ver el juego en movimiento, así que el autor le cuenta qué se siente raro, lento o injusto, y Claude ajusta los valores.
- **Rendimiento:** contador de FPS de depuración activable con una tecla.

---

## 11. Riesgos

| Riesgo | Mitigación |
|--------|-----------|
| La animación procedural queda "robótica" | Aplicar los principios de animación desde el primer día; iterar con el feedback del autor jugando |
| Fondos de IA incoherentes entre sí | Guía de prompts común y generación por capas; Claude revisa cada imagen antes de integrarla |
| Claude no puede ver el juego en tiempo real | Ciclos cortos: pequeños cambios, el autor prueba y comenta |
| El alcance de la beta crece demasiado | Hitos separados; nada entra en el Hito 1 que no esté en §9 |
| Pérdida de trabajo por el contenedor temporal | Subir cada avance a GitHub |
