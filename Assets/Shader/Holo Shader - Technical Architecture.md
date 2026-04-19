# Pokemon Cards Holo Shader - Technical Architecture

This Unity project ports the CSS holo-card effect system from:

https://poke-holo.simey.me/

The goal is to keep one main Unity shader pipeline that can render many Pokemon-style holo families by changing material/profile properties instead of swapping many unrelated shaders.

Important current decision: the first full HLSL compositor was too hard for the team to reason about and tune. It is now treated as a prototype/reference. The active designer-facing shader is `HoloCard-BasicGloss.shadergraph`, rebuilt one holo layer at a time.

Current checkpoint: the active graph is intentionally a Basic Gloss workbench. The full future property contract is documented below, but `HoloCard-BasicGloss.shadergraph` exposes only the four properties it actually uses today. Add the other properties back only when the visible graph layers need them.

## Current Architecture

The holo system is split into four layers:

1. **Interaction layer**
   - File: `Assets/Scripts/CardInteraction.cs`
   - Reads mouse/raycast interaction.
   - Drives card tilt with spring motion.
   - Writes animated shader properties every frame.
   - Does not know which holo mode is active.

2. **Profile/config layer**
   - Files:
     - `Assets/Scripts/HoloCardProfile.cs`
     - `Assets/Scripts/HoloCardController.cs`
     - `Assets/Scripts/HoloCardEnums.cs`
   - Stores static per-card data such as holo mode, textures, mask behavior, glow color, and tuning values.
   - Pushes those static values through `MaterialPropertyBlock`.
   - Keeps card data separate from pointer/tilt behavior.

3. **ShaderGraph layer**
   - Active file: `Assets/Shader/HoloCard-BasicGloss.shadergraph`
   - Reference file: `Assets/Shader/HoloCard-Shader.shadergraph`
   - This is the main shader asset used by the card material.
   - It starts with only the properties needed for Basic Gloss:
     - `_CardArt`
     - `_PointerX`
     - `_PointerY`
     - `_CardOpacity`
   - Its active output is a visible node chain.
   - Current active output:
     - `_CardArt` sample -> `Overlay.baseColor`
     - `GlareLayer` -> `Overlay.blend`
     - `_CardOpacity` -> `Overlay.opacity`
     - `Overlay.result` -> `SurfaceDescription.BaseColor`
     - `_CardArt.a` -> `SurfaceDescription.Alpha`
   - The old `HoloCardCompositeGraph` node remains in `HoloCard-Shader.shadergraph` only as a grouped reference node.

4. **HLSL recipe layer**
   - Files:
     - `Assets/Shader/CustomNodes/BlendModes.hlsl`
     - `Assets/Shader/CustomNodes/HoloCardComposite.hlsl`
     - `Assets/Shader/CustomNodes/HoloCardComposite_REFERENCE.hlsl`
   - `BlendModes.hlsl` is still active and should stay small: CSS blend modes and filter helpers only.
   - `HoloCardComposite.hlsl` and `HoloCardComposite_REFERENCE.hlsl` are prototype/reference files for CSS parity logic, masks, gradients, and recipe ideas.
   - New production work should move one understandable layer at a time into visible ShaderGraph nodes. Use HLSL only for math that is genuinely painful or unclear in nodes.

## Important Files

| File | Purpose |
| --- | --- |
| `Assets/Prefab/Card.prefab` | Canonical test prefab. Contains `CardInteraction` and `HoloCardController`. |
| `Assets/Shader/HoloCard-BasicGloss.shadergraph` | Active clean ShaderGraph used by the card front material. |
| `Assets/Shader/HoloCard-Shader.shadergraph` | Previous larger ShaderGraph. Keep as reference while rebuilding. |
| `Assets/Shader/HoloCardLEGACY-ShaderLEGACY.shadergraph` | Reference copy of the previous full-composite graph. Do not tune this as the active shader. |
| `Assets/Shader/MAT_HoloCard-BasicGloss.mat` | Active material assigned to `CardFront` on the canonical prefab. |
| `Assets/Shader/MAT_HoloCard-Shader.mat` | Previous material with broad fallback textures/default values. |
| `Assets/Shader/CustomNodes/HoloCardComposite.hlsl` | Prototype/reference compositor still used by the disconnected reference node. |
| `Assets/Shader/CustomNodes/HoloCardComposite_REFERENCE.hlsl` | Snapshot of the old full compositor before the designer-visible rebuild. |
| `Assets/Shader/CustomNodes/BlendModes.hlsl` | Active CSS blend/filter helper library for small Custom Function nodes. |
| `Assets/Scripts/CardInteraction.cs` | Runtime pointer, opacity, background movement, tilt, and spring animation. |
| `Assets/Scripts/HoloCardProfile.cs` | ScriptableObject data model for one holo card setup. |
| `Assets/Scripts/HoloCardController.cs` | Applies a `HoloCardProfile` to the renderer through a `MaterialPropertyBlock`. |
| `Assets/Scripts/HoloCardEnums.cs` | Shared enum values for holo modes and layout masks. |
| `Assets/HoloProfiles/*.asset` | Ready-made profile assets for major holo families. |
| `Assets/Editor/HoloTextureImportPostprocessor.cs` | Import settings for foil, glitter, grain, pattern, cosmos, and mask textures. |

## Reference Assets

These files are kept so developers can compare against the previous attempt:

- `Assets/Shader/HoloCardLEGACY-ShaderLEGACY.shadergraph`
- `Assets/Shader/CustomNodes/HoloCardComposite_REFERENCE.hlsl`
- the grouped `REFERENCE - Full HLSL Prototype` node inside `HoloCard-Shader.shadergraph`

Do not tune these first. Treat them like a map of ideas. The active shader should be made understandable in visible ShaderGraph groups.

## Runtime Data Flow

At runtime, values move like this:

```text
Mouse/raycast
  -> CardInteraction
  -> animated MaterialPropertyBlock values
  -> HoloCard-BasicGloss.shadergraph
  -> visible ShaderGraph layer nodes
  -> small blend helper functions when needed
  -> final RGB/alpha
```

Static card setup moves like this:

```text
HoloCardProfile asset
  -> HoloCardController
  -> static MaterialPropertyBlock values
  -> HoloCard-BasicGloss.shadergraph
  -> visible ShaderGraph properties/layer controls
```

`CardInteraction` and `HoloCardController` intentionally write to the same renderer using `MaterialPropertyBlock`. Each script first calls `GetPropertyBlock`, changes only its own values, then calls `SetPropertyBlock`, so the two systems can coexist.

## Shader Property Contract

This is the target contract for the full holo shader family. The current clean Basic Gloss graph uses only `_CardArt`, `_PointerX`, `_PointerY`, and `_CardOpacity`.

### Animated Properties

These are updated every frame by `CardInteraction`.

| Property | Range | Meaning |
| --- | --- | --- |
| `_PointerX` | `0..1` | Pointer position from left to right. |
| `_PointerY` | `0..1` | Pointer position from bottom to top in Unity/card space. |
| `_BackgroundX` | `0..1` | Smoothed/parallax background X value. |
| `_BackgroundY` | `0..1` | Smoothed/parallax background Y value. |
| `_PointerFromCenter` | `0..1` | Distance from center, normalized. |
| `_PointerFromLeft` | `0..1` | Same base X value, kept for CSS parity. |
| `_PointerFromTop` | `0..1` | Y helper value, kept for CSS parity/future recipes. |
| `_CardOpacity` | `0..1` | Effect fade in/out during hover. |

### Static Per-Card Properties

These are pushed by `HoloCardController` from a `HoloCardProfile`.

| Property | Meaning |
| --- | --- |
| `_HoloMode` | Selects which holo recipe branch runs. |
| `_LayoutMaskMode` | Selects procedural layout mask. |
| `_UseMaskTex` | Multiplies procedural mask by `_MaskTex` when enabled. |
| `_CardGlowColor` | Tint/glow color used by some recipes. |
| `_FoilBrightness` | Brightness tuning, especially for reverse holo. |
| `_EffectStrength` | Global multiplier for recipe visibility. |
| `_SeedX`, `_SeedY` | Stable per-card offsets to avoid identical texture movement. |

### Texture Properties

| Property | Meaning |
| --- | --- |
| `_CardArt` | Base card/front image. |
| `_FoilTex` | Foil/noise/pattern layer. |
| `_MaskTex` | Optional alpha or grayscale mask. |
| `_GlitterTex` | Sparkle/glitter layer. |
| `_GrainTex` | Grain/metallic texture for V-family modes. |
| `_PatternTex` | Pattern fallback for VMAX/VSTAR/gold/full-art styles. |
| `_CosmosBottomTex` | Cosmos bottom layer. |
| `_CosmosMiddleTex` | Cosmos middle layer. |
| `_CosmosTopTex` | Cosmos top layer. |

## Holo Mode Values

These values are defined in `HoloMode` and mirrored in HLSL:

| Value | Mode |
| --- | --- |
| `0` | BasicGloss |
| `1` | RegularHolo |
| `2` | ReverseHolo |
| `3` | CosmosHolo |
| `4` | AmazingRare |
| `5` | RadiantHolo |
| `6` | TrainerGalleryHolo |
| `7` | VRegular |
| `8` | VFullArt |
| `9` | VMAX |
| `10` | VSTAR |
| `11` | RainbowRare |
| `12` | RainbowAlt |
| `13` | SecretGold |
| `14` | TrainerGallerySecretGold |
| `15` | ShinyRare |
| `16` | ShinyV |
| `17` | ShinyVMAX |

## Layout Mask Values

These values are defined in `LayoutMaskMode` and mirrored in HLSL:

| Value | Mode |
| --- | --- |
| `0` | FullCard |
| `1` | ArtworkWindow |
| `2` | StageArtworkWindow |
| `3` | TrainerArtworkWindow |
| `4` | BorderInset |
| `5` | InverseArtworkWindow |
| `6` | InverseStageArtworkWindow |
| `7` | InverseTrainerArtworkWindow |
| `8` | TextureMaskOnly |

## UV And CSS Parity

Unity UVs and CSS percentage coordinates do not use the same vertical direction.

Inside the HLSL prototype, the shader converts Unity UVs to CSS-style UVs:

```hlsl
cssUv = float2(uv.x, 1.0 - uv.y);
```

In ShaderGraph, use a `Split` node on UV and a `One Minus` node on `Y` to create the same CSS-style vertical coordinate.

Use `cssUv` for:

- layout masks
- CSS-style gradient positioning
- radial glare positions
- conic/rainbow/scanline placement

The raw pointer values still come from `CardInteraction` as Unity/card-space values. The HLSL wrapper flips pointer Y internally for CSS-style radial math.

## How To Use A Holo Profile

1. Select `Assets/Prefab/Card.prefab`.
2. Find the `HoloCardController` component.
3. Assign a profile from `Assets/HoloProfiles`.
4. Press Play.
5. Hover the card with the mouse.

Ready-made profile assets:

- `BasicGloss.asset`
- `RegularHolo.asset`
- `ReverseHolo.asset`
- `CosmosHolo.asset`
- `RadiantHolo.asset`
- `VFullArt.asset`
- `RainbowRare.asset`
- `SecretGold.asset`
- `ShinyVMAX.asset`

To create a new profile:

1. Right-click in the Project window.
2. Choose `Create > Holo Cards > Holo Card Profile`.
3. Assign card art and effect textures.
4. Choose `Holo Mode`.
5. Choose `Layout Mask Mode`.
6. Tune brightness, effect strength, glow color, and mask usage.
7. Assign the profile to `HoloCardController`.

## How To Add A New Holo Mode

Use this process to keep the system maintainable:

1. Add a value to `HoloMode` in `Assets/Scripts/HoloCardEnums.cs`.
2. Add the same value to the ShaderGraph mode switch only after the current visible layers are understood.
3. Build the mode from named visible layer groups:
   - base card art
   - procedural or texture mask
   - pointer glare
   - gradient or foil texture
   - final blend
4. Reuse `BlendModes.hlsl` Custom Function nodes for CSS blend math.
5. Use `HoloCardComposite_REFERENCE.hlsl` only as a translation guide, not as the place for new production tuning.
6. Create a new `HoloCardProfile` asset for the mode.
7. Test these pointer positions:
   - center: `(0.5, 0.5)`
   - top-left: `(0, 1)`
   - top-right: `(1, 1)`
   - bottom-left: `(0, 0)`
   - bottom-right: `(1, 0)`
8. Compare against the original CSS source.

Keep one mode readable before starting the next mode. Visual parity is easier to tune when every layer has a name, a small group, and a small number of designer-facing controls.

## How To Modify Existing Modes

Most visual tuning should happen in `HoloCard-BasicGloss.shadergraph`.

Recommended tuning order:

1. Tune masks first.
2. Tune texture scale/offset.
3. Tune gradient angle/frequency.
4. Tune blend mode.
5. Tune brightness/contrast/saturation.
6. Tune pointer response.
7. Tune final opacity/effect strength.

Avoid tuning five variables at once. Change one thing, check center and corners, then continue.

When a mode still exists only in `HoloCardComposite_REFERENCE.hlsl`, port it by copying the idea, not the entire function. Create one visible graph layer, verify it, then add the next layer.

## Texture Import Rules

`HoloTextureImportPostprocessor` applies import settings automatically.

Foil, glitter, grain, pattern, and cosmos textures:

- Wrap Mode: Repeat
- Filter Mode: Bilinear

Mask textures:

- Wrap Mode: Clamp
- Filter Mode: Bilinear

Card art:

- Wrap Mode: Clamp
- Filter Mode: Bilinear or Trilinear

If a texture behaves strangely, check its import settings first.

## Prefab Rules

Use `Assets/Prefab/Card.prefab` as the canonical prefab.

Expected structure:

```text
Card
  CardInteraction
  HoloCardController
  BoxCollider
  CardTranslation
    CardRotation
      CardFront
      CardBack
```

Important:

- `CardFront` uses the holo material.
- `CardBack` stays a separate renderer.
- `CardInteraction` should keep pointer/tilt/spring behavior.
- `HoloCardController` should only push profile/static shader values.
- Do not move pointer logic into `HoloCardController`.
- Avoid stencil objects for the core effect. Use them only for special demos.

## ShaderGraph Rules

`HoloCard-BasicGloss.shadergraph` should stay readable.

It should contain:

- exposed properties
- named layer groups
- small Custom Function nodes only for blend/filter helpers
- final Base Color/Alpha output

Avoid returning to a single giant Custom Function node for the whole effect. The old full compositor is available as a reference, but it made visual tuning too opaque for the team.

Good graph groups:

- `Base Card Art`
- `Pointer Glare`
- `Artwork Mask`
- `Foil Texture`
- `Rainbow Gradient`
- `Final Blend`

Bad graph groups:

- `Everything`
- `Mode Logic`
- `Secret Sauce`
- giant unlabelled chains that only one developer understands

## Troubleshooting

### ShaderGraph shows pink material

Check Unity Console first. Common causes:

- HLSL compile error in a small blend helper or the reference node
- missing ShaderGraph property
- typo between C# property name and HLSL property name
- texture property not exposed in the graph
- Unity has not reimported the shader graph after file edits

### Effect does not change when switching profiles

Check:

- `HoloCardController.profile` is assigned.
- `cardFrontRenderer` points to `CardFront`.
- `CardFront` uses `MAT_HoloCard-BasicGloss`.
- The selected profile has textures assigned.
- `_EffectStrength` is above `0`.
- `useMaskTex` is not hiding everything with a bad mask.

### Hover does nothing

Check:

- The root `Card` object has a collider.
- `CardInteraction.mainCamera` resolves to `Camera.main`.
- The camera ray hits the root card collider.
- `cardFrontRenderer` is assigned.
- `_CardOpacity` changes during hover.

### Glare appears vertically flipped

Check the CSS/Unity coordinate conversion:

- Unity/card pointer top is `_PointerY = 1`.
- CSS UV top is `cssUv.y = 0`.
- Use the internally flipped pointer for CSS radial math.

### Reverse holo is too bright or too dark

Tune `foilBrightness` in the profile.

If `foilBrightness` is `0`, `HoloCardProfile.EffectiveFoilBrightness` uses these defaults:

- Lightning: `0.7`
- Darkness: `0.8`
- Metal: `0.6`
- default: `0.55`

## Validation Checklist

For each mode:

1. Assign the correct profile.
2. Verify center pointer.
3. Verify four corners.
4. Sweep left to right.
5. Sweep top to bottom.
6. Compare against the CSS reference.
7. Check masks with and without `_MaskTex`.
8. Check that `CardBack` is unaffected.
9. Check play mode and edit mode profile assignment.

## Performance Notes

The current design prioritizes visual parity first.

Potential performance cleanup later:

- Convert heavy mode branches into shader keywords.
- Split only the most expensive modes if profiling proves the single dynamic mode shader is too costly.
- Reduce texture samples in glitter-heavy modes.
- Prebake some masks or patterns.
- Lower scanline/glitter frequencies for mobile.

Do not split the shader early. First make the modes visually correct, then profile.

## Development Order

Recommended order for future work:

1. Confirm `BasicGloss` compiles and renders.
2. Tune `RegularHolo` against `regular-holo.css`.
3. Tune `ReverseHolo`.
4. Tune `CosmosHolo`.
5. Tune `RadiantHolo`.
6. Tune V-family modes.
7. Tune Rainbow/Gold/Shiny modes.
8. Profile and optimize.

Keep each step small and testable.
