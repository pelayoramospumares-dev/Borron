# Fondos de Borrón con Higgsfield: guía y prompts

El juego ya funciona sin estas imágenes: cada sala tiene un escenario procedural en profundidad. Las imágenes pintadas se **añaden encima** como capas a distintas distancias, igual que en Hollow Knight. Si una imagen no existe, el juego la ignora.

## Cómo generarlas

1. En Higgsfield elige **Nano Banana Pro**.
   - Resolución **4K**.
   - Formato **21:9** para las capas lejanas y medias, **16:9** para las cercanas.
2. Genera primero `r01_far`. Cuando te guste, úsala como **imagen de referencia** en todas las demás. Así todas comparten estilo y paleta.
3. Descarga cada imagen como PNG y guárdala con el nombre exacto en `art/backgrounds/zone1/`, por ejemplo `art/backgrounds/zone1/r01_far.png`.
4. Las capas **media** y **cercana** se generan sobre fondo blanco liso. Quítale el fondo con:
   ```
   python3 tools/strip_background.py r01_mid.png art/backgrounds/zone1/r01_mid.png
   ```
   También puedes pasármelas a mí y lo hago yo.
5. Abre el proyecto en Godot (se importan solas) y pulsa F5.

> No incluyas personajes ni criaturas en los fondos: los personajes los dibuja el juego. Y nada de pixel art.

## Guía de estilo (va al final de cada prompt)

```
STYLE: hand-painted 2D video game background, digital matte painting with visible soft brush strokes, melancholic and quiet, muted desaturated palette of cold greys, faded blues, sepia and bone white, heavy atmospheric fog that swallows distant shapes, soft diffuse overcast light, silhouettes become lighter and hazier with distance, parts of buildings look half-erased as if wiped away by ink, subtle ink-wash texture. No characters, no creatures, no text, no UI, no pixel art, no 3D render look.
```

Paleta de referencia (spec §5.2):

| Uso | Color |
|---|---|
| Fondo lejano | gris niebla `#9EA3AD` |
| Fondo medio | gris azulado `#6B7080` |
| Sombras y tinta | casi negro `#141419` |
| Acentos cálidos (pocos) | dorado pálido `#E8D49A` |

## Capas por sala

Cada sala lleva tres capas. La cámara las mueve a distinta velocidad:

| Capa | Archivo | Profundidad | Qué debe contener |
|---|---|---|---|
| Lejana | `<sala>_far.png` | 4000 (se mueve al 20 %) | Cielo, horizonte, siluetas muy lejanas y con mucha niebla |
| Media | `<sala>_mid.png` | 1500 (al 40 %) | Edificios o estructuras a media distancia, recortados sobre fondo blanco |
| Cercana | `<sala>_near.png` | 400 (al 71 %) | Elementos grandes y oscuros cerca del plano de juego, sobre fondo blanco |

En las tres capas, **la parte inferior de la imagen es el nivel del suelo**. Deja el tercio inferior oscuro o vacío: el juego dibuja ahí el suelo jugable.

---

### r01 · Despertar (inicio del juego)

**r01_far** (21:9)
```
Wide panoramic distant view of a ruined medieval village on rolling hills under a pale overcast sky, rooftops and a broken bell tower dissolving into thick fog, some houses look partially erased leaving blank gaps, very low contrast, lots of empty misty sky in the upper half. STYLE: ...
```

**r01_mid** (21:9, fondo blanco)
```
Row of abandoned half-collapsed village houses and leaning wooden fences seen at middle distance, slate-grey and faded blue, their edges dissolving like smeared ink, a few dark empty windows, isolated on a plain pure white background, nothing below the ground line. STYLE: ...
```

**r01_near** (16:9, fondo blanco)
```
Foreground silhouettes close to the camera: a crooked unlit iron street lantern, a broken stone wall fragment and dry grass tufts, very dark charcoal tones almost black, isolated on a plain pure white background, objects stand on the bottom edge of the image. STYLE: ...
```

### r06 · Santuario de la forma charco

**r06_far** (21:9)
```
Distant ruined chapel with a tall narrow spire half erased into the fog, faint pale golden glow coming from inside the chapel windows, quiet sacred melancholic mood, overcast sky, low contrast. STYLE: ...
```

**r06_mid** (21:9, fondo blanco)
```
Middle-distance remains of a small stone shrine: cracked arches, broken pillars, hanging chains and an empty pedestal, grey stone stained with dripping black ink, isolated on a plain pure white background. STYLE: ...
```

**r06_near** (16:9, fondo blanco)
```
Foreground: dark gnarled roots and broken stone steps wrapped in dried ink stains, near-black silhouettes, isolated on a plain pure white background, standing on the bottom edge. STYLE: ...
```

### r10 · Arena del Escriba Hueco (jefe)

**r10_far** (21:9)
```
Vast ruined scriptorium hall open to a stormy grey sky, enormous broken bookshelves and fallen giant pages drifting in the fog, an oppressive and solemn atmosphere, dark ink stains running down the walls, low contrast distance. STYLE: ...
```

**r10_mid** (21:9, fondo blanco)
```
Middle-distance huge stone writing desks and toppled bookshelves, scattered giant quill pens and scrolls, ink pouring from cracks, grey and bone-white tones, isolated on a plain pure white background. STYLE: ...
```

**r10_near** (16:9, fondo blanco)
```
Foreground: piles of torn paper, a massive broken inkwell and dark tattered banners, near-black silhouettes, isolated on a plain pure white background, standing on the bottom edge. STYLE: ...
```

---

Sustituye `STYLE: ...` por el bloque de la guía de estilo. Cuando tengas las imágenes, pásamelas: reviso que encajen con la paleta y la niebla antes de integrarlas.
