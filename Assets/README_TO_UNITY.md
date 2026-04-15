# 🃏 Pokemon Holographic Card Effect — Unity Port

A Unity recreation of the stunning holographic card effects from [pokemon-cards-css](https://github.com/simeydotme/pokemon-cards-css), which achieves photorealistic holo shimmer using only CSS, JS, and Svelte.

This guide breaks down the original web architecture and maps every technique to a Unity equivalent — shader uniforms, HLSL blend modes, spring physics, and 3D transforms.

---

## How the Original Works

The CSS project achieves realism through **5 layered systems**:

| CSS/Svelte System | Unity Equivalent |
|---|---|
| CSS Custom Properties (`--pointer-x`, `--pointer-y`, etc.) | Shader Uniforms via `Material.SetFloat()` / `MaterialPropertyBlock` |
| Multi-layer gradients + CSS blend modes (`color-dodge`, `overlay`, etc.) | Multi-layer HLSL shader with blend mode formulas |
| Svelte spring physics (`stiffness: 0.066, damping: 0.25`) | Custom C# spring class |
| `perspective: 600px` + `rotateX()` / `rotateY()` | `Transform.rotation` + Unity perspective camera |
| PNG textures (glitter, foil, cosmos nebula layers) | `Texture2D` samples in shader |

### Layer Stack (per card)

```
.card
  └─ .card__translater       →  perspective: 600px, translate3d, scale
     └─ .card__rotator       →  rotateX / rotateY (tilt)
        ├─ .card__front      →  Card art image
        ├─ .card__back       →  Back side (rotateY 180°)
        ├─ .card__shine      →  Holographic effect (z: 1px)
        │   ├─ :before       →  Secondary rainbow layer (z: 1px)
        │   └─ :after        →  Radial spotlight falloff (z: 1.2px)
        └─ .card__glare      →  Reflective glare (z: 1.41px)
```

### CSS Custom Properties (updated at 60fps from JS)

| Property | Range | Purpose |
|---|---|---|
| `--pointer-x` / `--pointer-y` | 0–100% | Cursor position on card → radial gradient center |
| `--background-x` / `--background-y` | 37–63% | Remapped cursor → gradient offset (subtler parallax) |
| `--pointer-from-center` | 0–1 | Euclidean distance from center → brightness falloff |
| `--pointer-from-left` / `--pointer-from-top` | 0–1 | Normalized vectors → gradient position mapping |
| `--card-opacity` | 0–1 | Glare visibility (0 = dormant, 1 = interacting) |
| `--rotate-x` / `--rotate-y` | ±14° | Card tilt from mouse offset |

### Spring Physics (Svelte Motion)

All values are smoothed through springs, not set directly:

| Spring | Stiffness | Damping | Controls |
|---|---|---|---|
| `springRotate` | 0.066 | 0.25 | 3D card tilt |
| `springGlare` | 0.066 | 0.25 | Light position + opacity |
| `springBackground` | 0.066 | 0.25 | Shimmer gradient offset |
| `springScale` | 0.033 | 0.45 | Zoom (1.0 → 1.75) |
| `springTranslate` | 0.033 | 0.45 | Card centering on activation |
| `springRotateDelta` | 0.033 | 0.45 | Initial 360° spin animation |

Formula per frame:
```
velocity += (target - current) * stiffness
velocity *= (1 - damping)
current  += velocity
```

### Blend Modes (CSS → HLSL)

These CSS blend modes are the core of the holo look. HLSL equivalents:

```hlsl
float3 ColorDodge(float3 base, float3 blend)  { return base / max(1.0 - blend, 0.001); }
float3 Overlay(float3 base, float3 blend)     { return base < 0.5 ? 2*base*blend : 1 - 2*(1-base)*(1-blend); }
float3 HardLight(float3 base, float3 blend)   { return Overlay(blend, base); }
float3 SoftLight(float3 base, float3 blend)   { return blend < 0.5 ? base-(1-2*blend)*base*(1-base) : base+(2*blend-1)*(sqrt(base)-base); }
float3 Multiply(float3 base, float3 blend)    { return base * blend; }
float3 Screen(float3 base, float3 blend)      { return 1 - (1-base) * (1-blend); }
float3 Exclusion(float3 base, float3 blend)   { return base + blend - 2*base*blend; }
float3 Difference(float3 base, float3 blend)  { return abs(base - blend); }
```

### Filter Chain (CSS → HLSL)

```hlsl
float3 ApplyFilter(float3 col, float brightness, float contrast, float saturation) {
    col *= brightness;
    col = saturate((col - 0.5) * contrast + 0.5);
    float gray = dot(col, float3(0.299, 0.587, 0.114));
    col = lerp(gray.xxx, col, saturation);
    return col;
}
```

---

## Rarity Variants

Each rarity uses different gradient configurations, textures, and blend chains. **Start with Regular Holo** — it's the simplest.

### Regular Holo
- **Shine**: `repeating-linear-gradient(110deg)` with 5 sunpillar colors, offset by `_BackgroundX/Y × 2.6/3.5`
- **Scanlines**: Horizontal 1px alternating dark/light bars via `repeating-linear-gradient(90deg)`
- **Spotlight**: Radial gradient at pointer, `mix-blend-mode: luminosity`
- **Filters**: `brightness(1.1) contrast(1.1) saturate(1.2)` on shine, `brightness(0.6) contrast(4)` on spotlight
- **Clip**: Masked to illustration area only (`inset(9.85% 8% 52.85% 8%)`)

### Cosmos Holo
- 3 stacked PNG nebula textures (`cosmos-bottom`, `cosmos-middle-trans`, `cosmos-top-trans`)
- Each layer offset differently for **parallax depth** (10%, 15%, 20% multipliers)
- Rainbow stripes at 82° angle blended via `multiply`
- Radial gradient at pointer blended via `multiply`

### Rainbow / Secret Holo
- Diagonal `linear-gradient(-45deg)` with 7 dark hue stops
- `glitter.png` texture at 25% scale, `soft-light` blend
- Second rainbow gradient at -30° with 3× repetition
- Brightness tied to `_PointerFromCenter` (dim edges, bright center)
- Extreme contrast (2.2×) + high saturation

### Radiant Holo
- **Cross-hatch**: Two opposing `repeating-linear-gradient` at ±45° with 10 gradient stops each
- Blend chain: `exclusion → darken → color-dodge`
- Rainbow stripes at 55° with **inverted parallax** (-2.5× multiplier)
- Extreme filter: `brightness(0.5) contrast(2) saturate(1.75)`

### Secret Rare (Gold)
- **Conic gradient** — 360° color wheel from sunpillar palette
- Gold diagonal wash: `hsl(46, 95%, 50%)` → `hsl(52, 100%, 69%)`
- Dual glitter layers displaced by 10% for sparkle parallax
- 2.7× saturation for hyper-saturated colors

### Reverse Holo
- **Inverted clip mask**: Everything EXCEPT illustration area shimmers
- Per-type brightness: Lightning 0.7, Darkness 0.8, Metal 0.6
- Diagonal flash + foil texture + `difference` blend

### Sunpillar Color Palette

```
Red:     hsl(2,   100%, 73%)  →  #f80e35
Yellow:  hsl(53,  100%, 69%)  →  #eedf10
Green:   hsl(93,  100%, 69%)  →  #21e985
Cyan:    hsl(176, 100%, 76%)  →  #0dbde9
Blue:    hsl(228, 100%, 74%)  →  #6a5acd (approx)
Magenta: hsl(283, 100%, 73%)  →  #c929f1
```

---

## Implementation Plan

### Phase 1: Project Setup & Card Mesh

1. Create a **Unity URP project**
2. Build a **Card prefab**:
   - Quad mesh with 2.5:3.5 aspect ratio (or rounded-rect)
   - `CardFront` (Quad + card art texture), `CardBack` (Quad, rotated 180°)
   - Shine/Glare handled **in the shader**, not as separate objects
   - `BoxCollider` for raycasting

### Phase 2: Input & Spring Physics

3. **`CardInteraction.cs`**:
   - Raycast through mouse → hit card collider → UV to percentage (0–100%)
   - Derive: `pointerFromCenter`, `pointerFromLeft`, `pointerFromTop`
   - Rotation: `(percent - 50) / 3.5` → ±14° max
   - Background offset: `Mathf.Lerp(37, 63, percent / 100)`

4. **`SpringFloat.cs` / `SpringVector2.cs`**:
   - 6 spring instances with configs matching the Svelte project
   - Update every frame, pass values to shader via `MaterialPropertyBlock`

5. Apply to transform:
   ```csharp
   transform.localRotation = Quaternion.Euler(-springRotate.y, springRotate.x, 0);
   transform.localScale = Vector3.one * springScale.current;
   ```

### Phase 3: Holo Shader (HLSL)

6. **Shader uniforms**: `_PointerX/Y`, `_BackgroundX/Y`, `_PointerFromCenter`, `_CardOpacity`, `_CardArt`, `_GlitterTex`, `_FoilTex`

7. **Base layer**: Sample `_CardArt`

8. **Shine layer**:
   - Rainbow gradient: `float t = frac(dot(uv + offset, direction) * frequency)` → lerp sunpillar colors
   - Scanlines: `frac(uv.y * height) > 0.5 ? 1 : dark`
   - Spotlight: `smoothstep()` from pointer position
   - Blend + filter chains as described above
   - UV-based mask for illustration area

9. **Glare layer**: Radial gradient at pointer, overlay blend, × `_CardOpacity`

10. **Rarity variants** via `#pragma multi_compile` keywords

### Phase 4: Textures

11. Export from CSS project's img or recreate:
    - `glitter.png` — random white dots on transparent (can also be procedural)
    - Foil patterns, cosmos nebula layers
    - Import settings: Wrap=Repeat, Filter=Bilinear

### Phase 5: Card Data

12. **`CardData` ScriptableObject**: `cardName`, `cardArt`, `rarity` (enum), `pokemonType` (glow color), `foilTexture` *(parallel with Phase 2–3)*

13. **`CardManager.cs`**: Instantiate prefab, set material props, handle click-to-zoom

### Phase 6: Polish

14. **Showcase auto-rotation**:
    ```csharp
    r += 0.05f * Time.deltaTime * 50f;
    springRotate.target = new Vector2(Mathf.Sin(r) * 25f, Mathf.Cos(r) * 25f);
    ```

15. **Optional — Gyroscope**: `Input.gyro.attitude` → clamp ±18°/±16° → rotation springs

---

## Files to Create

| Path | Purpose |
|---|---|
| `Assets/Shaders/HoloCard.shader` | Main holographic shader (HLSL) |
| `Assets/Scripts/CardInteraction.cs` | Input → springs → shader uniforms |
| `Assets/Scripts/SpringFloat.cs` | Spring physics utility |
| `Assets/Scripts/CardData.cs` | ScriptableObject definition |
| `Assets/Scripts/CardManager.cs` | Card instantiation & state |
| `Assets/Textures/` | Glitter, foil, cosmos textures |
| `Assets/Prefabs/Card.prefab` | Card quad + collider |

## Reference Files (from CSS project)

| File | What to learn |
|---|---|
| Card.svelte | Interaction model, spring config, CSS property mapping |
| Math.js | `clamp()`, `adjust()` utilities |
| regular-holo.css | Simplest holo variant — start here |
| base.css | Layer structure, blend modes, filter chains |

---

## Verification Checklist

- [ ] Visual parity: side-by-side with [web demo](https://pokemon-cards-css.pages.dev), same card + mouse position
- [ ] Spring feel: rapid mouse movement + release → correct overshoot/damping
- [ ] Rotation: ±14° range, mouse X → `rotateY` axis mapping
- [ ] Blend modes: test scene with solid colors → verify each formula vs. CSS output
- [ ] Performance: 60fps on mid-range GPU, check pass count via Frame Debugger
- [ ] Mobile: gyroscope → same behavior as desktop mouse

## Architecture Decisions

- **HLSL over ShaderGraph** — ShaderGraph can't express `frac()`, custom blend modes, multi-layer compositing cleanly
- **URP** — Better shader customization + mobile support
- **Start with Regular Holo** — simplest variant (3 gradient layers + scanlines), then add complexity
- **Single shader with `#pragma multi_compile`** — avoids shader duplication, allows per-variant optimization

---

## Optional Enhancements

- **VFX Graph Glitter**: World-space particles instead of texture — potentially more realistic sparkle
- **Card Collection UI**: ScrollView with pooled card instances, or 3D cards in world space with camera movement
- **Higher-res textures**: The CSS project's PNGs are web-optimized; Unity can use 2K+ textures

---

Wechsle in den Implementierungs-Modus und ich schreibe das als README.md ins Projekt — oder kopiere den Inhalt oben direkt.