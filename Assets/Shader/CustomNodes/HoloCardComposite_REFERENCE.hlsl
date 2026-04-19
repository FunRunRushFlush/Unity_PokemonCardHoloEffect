#ifndef HOLO_CARD_COMPOSITE_INCLUDED
#define HOLO_CARD_COMPOSITE_INCLUDED

#include "Assets/Shader/CustomNodes/BlendModes.hlsl"

static const float PI_HOLO = 3.14159265359;

float HoloHash(float2 p)
{
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return frac(p.x * p.y);
}

float2 CssUv(float2 uv)
{
    return float2(uv.x, 1.0 - uv.y);
}

float RectMask(float2 cssUv, float left, float top, float right, float bottom)
{
    float insideX = step(left, cssUv.x) * step(cssUv.x, right);
    float insideY = step(top, cssUv.y) * step(cssUv.y, bottom);
    return insideX * insideY;
}

float StageMask(float2 cssUv)
{
    float body = RectMask(cssUv, 0.08, 0.16, 0.92, 0.4715);
    float upperRight = RectMask(cssUv, 0.57, 0.0985, 0.915, 0.16);
    float upperMid = RectMask(cssUv, 0.17, 0.12, 0.57, 0.16);
    return saturate(body + upperRight + upperMid);
}

float BorderMask(float2 cssUv)
{
    return RectMask(cssUv, 0.04, 0.028, 0.96, 0.972);
}

float LayoutMask(float2 cssUv, float layoutMaskMode)
{
    int mode = (int)round(layoutMaskMode);

    if (mode == 1) return RectMask(cssUv, 0.08, 0.0985, 0.92, 0.4715);
    if (mode == 2) return StageMask(cssUv);
    if (mode == 3) return RectMask(cssUv, 0.085, 0.145, 0.915, 0.518);
    if (mode == 4) return BorderMask(cssUv);
    if (mode == 5) return 1.0 - RectMask(cssUv, 0.08, 0.0985, 0.92, 0.4715);
    if (mode == 6) return 1.0 - StageMask(cssUv);
    if (mode == 7) return 1.0 - RectMask(cssUv, 0.085, 0.145, 0.915, 0.518);
    if (mode == 8) return 1.0;

    return 1.0;
}

float TextureMask(float4 maskSample)
{
    return saturate(max(maskSample.a, maskSample.r));
}

float2 DirectionFromDegrees(float degrees)
{
    float r = radians(degrees);
    return normalize(float2(cos(r), sin(r)));
}

float LinearCoord(float2 cssUv, float degrees, float2 offset, float scale)
{
    return dot(cssUv + offset, DirectionFromDegrees(degrees)) * scale;
}

float Band(float t, float center, float width)
{
    float d = abs(frac(t) - center);
    return smoothstep(width, 0.0, d);
}

float Radial(float2 cssUv, float2 pointer, float inner, float outer)
{
    float d = distance(cssUv, pointer);
    return 1.0 - smoothstep(inner, outer, d);
}

float Scanlines(float2 uv, float frequency)
{
    return lerp(0.06, 0.42, step(0.5, frac(uv.y * frequency)));
}

float3 Sunpillar(float t)
{
    float3 c0 = float3(0.973, 0.055, 0.208);
    float3 c1 = float3(0.933, 0.875, 0.063);
    float3 c2 = float3(0.129, 0.914, 0.522);
    float3 c3 = float3(0.051, 0.741, 0.914);
    float3 c4 = float3(0.416, 0.353, 0.804);
    float3 c5 = float3(0.788, 0.161, 0.945);

    float x = frac(t) * 6.0;
    float f = frac(x);
    int i = (int)floor(x);

    if (i == 0) return lerp(c0, c1, f);
    if (i == 1) return lerp(c1, c2, f);
    if (i == 2) return lerp(c2, c3, f);
    if (i == 3) return lerp(c3, c4, f);
    if (i == 4) return lerp(c4, c5, f);
    return lerp(c5, c0, f);
}

float3 DarkRainbow(float t)
{
    float3 c0 = float3(0.37, 0.16, 0.16);
    float3 c1 = float3(0.39, 0.29, 0.18);
    float3 c2 = float3(0.25, 0.35, 0.14);
    float3 c3 = float3(0.14, 0.35, 0.35);
    float3 c4 = float3(0.17, 0.27, 0.39);
    float3 c5 = float3(0.25, 0.14, 0.31);

    float x = frac(t) * 6.0;
    float f = frac(x);
    int i = (int)floor(x);

    if (i == 0) return lerp(c0, c1, f);
    if (i == 1) return lerp(c1, c2, f);
    if (i == 2) return lerp(c2, c3, f);
    if (i == 3) return lerp(c3, c4, f);
    if (i == 4) return lerp(c4, c5, f);
    return lerp(c5, c0, f);
}

float3 GrayBands(float2 cssUv, float degrees, float2 offset, float scale)
{
    float t = frac(LinearCoord(cssUv, degrees, offset, scale));
    float band = Band(t, 0.38, 0.03) + Band(t, 0.45, 0.018) + Band(t, 0.52, 0.03);
    return lerp(float3(0.055, 0.08, 0.16), float3(0.62, 0.72, 0.72), saturate(band));
}

float3 CrossHatch(float2 cssUv, float2 bgOffset)
{
    float a = frac(LinearCoord(cssUv, 45.0, bgOffset * 1.5, 34.0));
    float b = frac(LinearCoord(cssUv, -45.0, bgOffset * 1.5, 34.0));
    float la = smoothstep(0.0, 0.55, a) * (1.0 - smoothstep(0.55, 1.0, a));
    float lb = smoothstep(0.0, 0.55, b) * (1.0 - smoothstep(0.55, 1.0, b));
    float v = saturate(la + lb);
    return lerp(float3(0.04, 0.04, 0.04), float3(0.65, 0.65, 0.65), v);
}

float4 SampleTex(UnityTexture2D tex, float2 uv)
{
    return SAMPLE_TEXTURE2D(tex.tex, tex.samplerstate, uv);
}

float3 ApplyMaskedBlend(float3 baseColor, float3 blend, float mask, float opacity, int blendMode)
{
    float3 blended = blend;

    if (blendMode == 0) blended = BlendColorDodge(baseColor, blend);
    else if (blendMode == 1) blended = BlendOverlay(baseColor, blend);
    else if (blendMode == 2) blended = BlendHardLight(baseColor, blend);
    else if (blendMode == 3) blended = BlendSoftLight(baseColor, blend);
    else if (blendMode == 4) blended = BlendMultiply(baseColor, blend);
    else if (blendMode == 5) blended = BlendScreen(baseColor, blend);
    else if (blendMode == 6) blended = BlendExclusion(baseColor, blend);
    else if (blendMode == 7) blended = BlendDifference(baseColor, blend);
    else if (blendMode == 8) blended = BlendLuminosity(baseColor, blend);
    else if (blendMode == 9) blended = BlendSaturation(baseColor, blend);

    return lerp(baseColor, blended, saturate(mask * opacity));
}

float3 BasicGloss(float3 baseColor, float2 cssUv, float2 pointer, float opacity, float strength)
{
    float glare = Radial(cssUv, pointer, 0.02, 0.85);
    float3 glareColor = lerp(float3(0.12, 0.12, 0.12), float3(1.0, 1.0, 1.0), glare);
    return ApplyMaskedBlend(baseColor, glareColor, 1.0, opacity * 0.45 * strength, 1);
}

float3 RegularHolo(float3 baseColor, float2 cssUv, float2 pointer, float2 bg, float mask, float opacity, float strength)
{
    float2 bgOffset = float2((0.5 - bg.x) * 2.6, (0.5 - bg.y) * 3.5);
    float3 rainbow = Sunpillar(LinearCoord(cssUv, 110.0, bgOffset, 3.6));
    float lines = Scanlines(cssUv, 520.0);
    float3 shine = ApplyCssFilter(BlendOverlay(rainbow, float3(lines, lines, lines)), 1.1, 1.1, 1.2);

    float beamA = Band(LinearCoord(cssUv, 90.0, float2((0.5 - bg.x) * 1.65 + bg.y * 0.5, bg.x), 5.0), 0.35, 0.05);
    float beamB = Band(LinearCoord(cssUv, 90.0, float2((0.5 - bg.x) * -0.9 - bg.y * 0.75, bg.y), 5.0), 0.45, 0.035);
    float beam = saturate(beamA + beamB);
    shine = BlendHardLight(shine, float3(beam, beam, beam));

    float spotlight = Radial(cssUv, pointer, 0.0, 0.9);
    shine = BlendLuminosity(shine, ApplyCssFilter(lerp(float3(0.0, 0.0, 0.0), float3(0.9, 0.9, 0.9), spotlight), 0.6, 4.0, 1.0));

    float3 col = ApplyMaskedBlend(baseColor, shine, mask, opacity * strength, 0);
    float3 glare = lerp(float3(0.0, 0.04, 0.06), float3(0.9, 1.0, 1.0), Radial(cssUv, pointer, 0.02, 0.9));
    return ApplyMaskedBlend(col, glare, mask, opacity * 0.55 * strength, 1);
}

float3 ReverseHolo(float3 baseColor, float3 foil, float2 cssUv, float2 pointer, float mask, float opacity, float foilBrightness, float pointerFromCenter, float strength)
{
    float radial = Radial(cssUv, pointer, 0.02, 0.55);
    float diag = Band(LinearCoord(cssUv, -45.0, pointer, 1.6), 0.5, 0.18);
    float3 flash = lerp(foil, float3(1.0, 1.0, 1.0), radial);
    flash = BlendDifference(flash, float3(diag, diag, diag));
    flash = ApplyCssFilter(flash, foilBrightness, 1.5, 1.0);
    float localOpacity = saturate((1.5 * opacity) - pointerFromCenter) * strength;
    return ApplyMaskedBlend(baseColor, flash, mask, localOpacity, 0);
}

float3 CosmosHolo(float3 baseColor, float3 bottom, float3 middle, float3 top, float2 cssUv, float2 pointer, float mask, float opacity, float pointerFromCenter, float strength)
{
    float2 p0 = lerp(float2(0.10, 0.10), float2(0.90, 0.90), pointer);
    float2 p1 = lerp(float2(0.15, 0.15), float2(0.85, 0.85), pointer);
    float2 p2 = lerp(float2(0.20, 0.20), float2(0.80, 0.80), pointer);
    float3 stripes0 = Sunpillar(LinearCoord(cssUv, 82.0, p0, 2.5));
    float3 stripes1 = Sunpillar(LinearCoord(cssUv, 82.0, p1, 2.5));
    float3 stripes2 = Sunpillar(LinearCoord(cssUv, 82.0, p2, 2.5));

    float3 shine = BlendColorBurn(bottom, stripes0);
    shine = BlendOverlay(shine, BlendScreen(middle, stripes1));
    shine = BlendMultiply(shine, BlendMultiply(top, stripes2));
    shine = ApplyCssFilter(shine, 1.15, 1.45, 0.85);

    float3 col = ApplyMaskedBlend(baseColor, shine, mask, opacity * strength, 0);
    float3 glare = lerp(float3(0.1, 0.08, 0.18), float3(0.92, 0.96, 1.0), Radial(cssUv, pointer, 0.02, 0.78));
    return ApplyMaskedBlend(col, glare, mask, opacity * (0.25 + pointerFromCenter) * strength, 1);
}

float3 AmazingRare(float3 baseColor, float3 foil, float3 glitterA, float3 glitterB, float2 cssUv, float2 pointer, float2 bg, float mask, float opacity, float pointerFromCenter, float strength)
{
    float radial = Radial(cssUv, pointer, 0.04, 0.9);
    float3 glitter = BlendSoftLight(glitterA, glitterB);
    float3 foilLayer = BlendColorBurn(foil, lerp(float3(0.0, 0.0, 0.0), float3(0.95, 0.9, 0.75), radial));
    float3 rainbow = Sunpillar(LinearCoord(cssUv, 133.0, (0.5 - bg) * 3.0, 2.0));
    float3 shine = BlendScreen(glitter, foilLayer);
    shine = BlendSaturation(shine, ApplyCssFilter(rainbow, 0.75 - pointerFromCenter * 0.5, 1.0, 1.0));
    return ApplyMaskedBlend(baseColor, shine, mask, opacity * strength, 3);
}

float3 RadiantHolo(float3 baseColor, float3 foil, float3 glitter, float2 cssUv, float2 pointer, float2 bg, float mask, float artMask, float opacity, float3 glow, float strength)
{
    float2 bgOffset = (bg - float2(0.5, 0.5));
    float3 cross = CrossHatch(cssUv, bgOffset);
    float radial = Radial(cssUv * 0.5 + float2(0.25, 0.25), pointer * 0.5 + float2(0.25, 0.25), 0.02, 0.8);
    float3 main = BlendColorDodge(BlendExclusion(lerp(glow, float3(0.95, 0.95, 0.95), radial), cross), cross);
    main = ApplyCssFilter(main, 0.5, 2.0, 1.75);

    float3 col = ApplyMaskedBlend(baseColor, main, mask, opacity * strength, 0);
    float3 rainbowFoil = BlendHardLight(foil, Sunpillar(LinearCoord(cssUv, 55.0, (0.5 - bg) * -2.5, 2.2)));
    rainbowFoil = ApplyCssFilter(rainbowFoil, 0.6, 3.0, 2.0);
    col = ApplyMaskedBlend(col, rainbowFoil, artMask, opacity * strength, 0);
    return ApplyMaskedBlend(col, ApplyCssFilter(glitter, 0.66, 2.0, 0.5), mask, opacity * 0.45 * strength, 1);
}

float3 TrainerGalleryHolo(float3 baseColor, float2 cssUv, float2 pointer, float2 bg, float mask, float opacity, float pointerFromCenter, float strength)
{
    float3 iris = Sunpillar(LinearCoord(cssUv, -22.0, float2(0.0, bg.y), 2.1));
    iris = ApplyCssFilter(iris, pointerFromCenter * 0.3 + 0.5, 2.3, 1.0);
    float radial = Radial(cssUv * float2(1.0, 0.75), pointer * float2(1.0, 0.75), 0.02, 0.65);
    float3 shine = BlendHardLight(iris, lerp(float3(0.1, 0.0, 0.12), float3(1.0, 1.0, 1.0), radial));
    float3 col = ApplyMaskedBlend(baseColor, shine, mask, opacity * strength, 0);
    return ApplyMaskedBlend(col, lerp(float3(0.3, 0.38, 0.38), float3(1.0, 1.0, 1.0), radial), mask, opacity * 0.45 * strength, 3);
}

float3 VFamily(float3 baseColor, float3 textureLayer, float2 cssUv, float2 pointer, float2 bg, float mask, float opacity, float pointerFromCenter, float strength, int variant)
{
    float brightness = 0.8;
    float contrast = 2.95;
    float saturation = 0.65;
    float angle = 133.0;
    float bandScale = 8.0;
    int firstBlend = 5;

    if (variant == 1)
    {
        brightness = pointerFromCenter * 0.4 + 0.4;
        contrast = 1.4;
        saturation = 2.25;
        firstBlend = 3;
    }
    else if (variant == 2)
    {
        brightness = pointerFromCenter * 0.4 + 0.4;
        contrast = 2.0;
        saturation = 1.0;
        bandScale = 4.0;
        firstBlend = 7;
    }
    else if (variant == 3)
    {
        brightness = pointerFromCenter * 0.75 + 0.25;
        contrast = 2.0;
        saturation = 1.25;
        firstBlend = 3;
    }

    float3 sun = Sunpillar(cssUv.y * 3.0 + bg.y * 2.0);
    float3 bands = GrayBands(cssUv, angle, bg, bandScale);
    float radial = Radial(cssUv, pointer, 0.08, 0.95);
    float3 shine = textureLayer;
    shine = firstBlend == 7 ? BlendExclusion(shine, sun) : BlendSoftLight(shine, sun);
    shine = BlendHardLight(shine, bands);
    shine = BlendHardLight(shine, lerp(float3(0.15, 0.15, 0.15), float3(0.0, 0.0, 0.0), radial));
    shine = ApplyCssFilter(shine, brightness, contrast, saturation);

    float3 col = ApplyMaskedBlend(baseColor, shine, mask, opacity * strength, 0);
    float3 afterLayer = ApplyCssFilter(BlendExclusion(sun, GrayBands(cssUv, angle, -bg, bandScale * 0.65)), pointerFromCenter * 0.4 + 0.8, 1.5, 1.25);
    col = ApplyMaskedBlend(col, afterLayer, mask, opacity * 0.45 * strength, variant == 0 ? 3 : 6);

    float glareOpacity = variant == 2 ? (0.2 + pointerFromCenter * 0.8) : 0.5;
    float3 glare = lerp(float3(0.15, 0.15, 0.18), float3(1.0, 1.0, 1.0), radial);
    return ApplyMaskedBlend(col, glare, mask, opacity * glareOpacity * strength, 2);
}

float3 RainbowMode(float3 baseColor, float3 foil, float3 glitter, float2 cssUv, float2 pointer, float2 bg, float mask, float opacity, float pointerFromCenter, float strength, bool alt)
{
    float3 dark = DarkRainbow(LinearCoord(cssUv, alt ? -30.0 : -45.0, bg * (alt ? 1.5 : 0.5), 2.0));
    float3 sparkle = BlendSoftLight(glitter, dark);
    float3 first = alt ? BlendLuminosity(Sunpillar(LinearCoord(cssUv, 133.0, bg, 2.0)), sparkle) : sparkle;
    first = ApplyCssFilter(first, pointerFromCenter * (alt ? 0.3 : 0.25) + (alt ? 0.3 : 0.6), alt ? 3.0 : 2.2, alt ? 1.8 : 0.75);

    float3 col = ApplyMaskedBlend(baseColor, first, mask, opacity * strength, alt ? 2 : 1);
    float3 second = BlendSoftLight(glitter, DarkRainbow(LinearCoord(cssUv, -60.0, alt ? -bg * 1.5 : pointer, 3.0)));
    second = ApplyCssFilter(second, pointerFromCenter * (alt ? 0.5 : 0.3) + (alt ? 0.6 : 0.55), alt ? 3.0 : 2.0, 1.0);
    col = ApplyMaskedBlend(col, second, mask, opacity * strength, 0);
    return ApplyMaskedBlend(col, ApplyCssFilter(foil, alt ? 1.5 : 2.5, alt ? 1.5 : 1.0, 1.0), mask, opacity * 0.25 * strength, alt ? 0 : 4);
}

float3 SecretGold(float3 baseColor, float3 foil, float3 glitterA, float3 glitterB, float2 cssUv, float2 pointer, float mask, float opacity, float pointerFromCenter, float strength, bool trainerGallery)
{
    float angle = atan2(cssUv.y - 0.5, cssUv.x - 0.5) / (2.0 * PI_HOLO) + 0.5;
    float3 conic = Sunpillar(angle);
    float radial = Radial(cssUv, pointer, 0.04, 0.9);
    float3 gold = lerp(float3(0.95, 0.64, 0.02), float3(1.0, 0.9, 0.25), cssUv.x);

    float3 glitter = trainerGallery ? BlendSoftLight(glitterA, conic) : BlendHardLight(BlendSoftLight(glitterA, glitterB), conic);
    glitter = ApplyCssFilter(glitter, trainerGallery ? 1.0 : 0.4 + pointerFromCenter * 0.2, trainerGallery ? 1.0 : 1.0, trainerGallery ? 1.0 : 2.7);

    float3 foilLayer = trainerGallery ? BlendExclusion(foil, lerp(float3(0.0, 0.0, 0.0), gold, radial)) : BlendScreen(foil, gold);
    foilLayer = ApplyCssFilter(foilLayer, trainerGallery ? 1.0 : 1.25, trainerGallery ? 1.0 : 1.25, trainerGallery ? 1.0 : 0.35);

    float3 col = ApplyMaskedBlend(baseColor, glitter, mask, opacity * strength, 0);
    col = ApplyMaskedBlend(col, foilLayer, mask, opacity * (trainerGallery ? 0.9 : 0.65) * strength, trainerGallery ? 6 : 5);
    return ApplyMaskedBlend(col, lerp(float3(0.14, 0.06, 0.02), float3(1.0, 0.94, 0.72), radial), mask, opacity * 0.45 * strength, 2);
}

float3 ShinyMode(float3 baseColor, float3 foil, float3 glitter, float2 cssUv, float2 pointer, float2 bg, float mask, float opacity, float pointerFromCenter, float strength, int variant)
{
    float3 silverFoil = ApplyCssFilter(foil, variant == 2 ? 1.0 : 0.8, variant == 2 ? 1.2 : 1.6, variant == 2 ? 0.45 : 0.75);

    if (variant == 2)
    {
        float3 rare = RainbowMode(baseColor, silverFoil, glitter, cssUv, pointer, bg, mask, opacity, pointerFromCenter, strength, true);
        return ApplyMaskedBlend(rare, lerp(float3(0.12, 0.14, 0.16), float3(0.92, 0.92, 0.92), Radial(cssUv, pointer, 0.02, 0.8)), mask, opacity * 0.45 * strength, 1);
    }

    float3 v = VFamily(baseColor, silverFoil, cssUv, pointer, bg, mask, opacity, pointerFromCenter, strength, 1);
    float3 glare = variant == 1 ? float3(0.18, 0.2, 0.22) : float3(0.35, 0.36, 0.38);
    return ApplyMaskedBlend(v, glare, mask, opacity * pointerFromCenter * 0.35 * strength, variant == 1 ? 4 : 1);
}

void HoloCardComposite_float(
    UnityTexture2D CardArt,
    UnityTexture2D FoilTex,
    UnityTexture2D MaskTex,
    UnityTexture2D GlitterTex,
    UnityTexture2D GrainTex,
    UnityTexture2D PatternTex,
    UnityTexture2D CosmosBottomTex,
    UnityTexture2D CosmosMiddleTex,
    UnityTexture2D CosmosTopTex,
    float2 UV,
    float PointerX,
    float PointerY,
    float BackgroundX,
    float BackgroundY,
    float PointerFromCenter,
    float PointerFromLeft,
    float PointerFromTop,
    float CardOpacity,
    float HoloMode,
    float LayoutMaskMode,
    float UseMaskTex,
    float3 CardGlowColor,
    float FoilBrightness,
    float EffectStrength,
    float SeedX,
    float SeedY,
    out float3 Color,
    out float Alpha)
{
    float2 cssUv = CssUv(UV);
    float2 pointer = float2(PointerX, PointerY);
    float2 cssPointer = CssUv(pointer);
    float2 bg = float2(BackgroundX, BackgroundY);
    float2 seed = float2(SeedX, SeedY);

    float4 cardArt = SampleTex(CardArt, UV);
    float4 maskSample = SampleTex(MaskTex, UV);
    float layout = LayoutMask(cssUv, LayoutMaskMode);
    float texMask = TextureMask(maskSample);
    float mask = lerp(layout, layout * texMask, saturate(UseMaskTex));
    float artMask = RectMask(cssUv, 0.08, 0.0985, 0.92, 0.4715) * lerp(1.0, texMask, saturate(UseMaskTex));

    float2 bgDelta = bg - float2(0.5, 0.5);
    float2 glitterUvA = UV * 4.0 + seed * 0.17;
    float2 glitterUvB = UV * 4.0 - pointer * 0.02 + seed.yx * 0.13;
    float4 foilSample = SampleTex(FoilTex, UV + bgDelta * 0.08);
    float4 glitterSampleA = SampleTex(GlitterTex, glitterUvA);
    float4 glitterSampleB = SampleTex(GlitterTex, glitterUvB);
    float4 grainSample = SampleTex(GrainTex, UV * float2(3.0, 1.0) + bgDelta * 0.2);
    float4 patternSample = SampleTex(PatternTex, UV * 3.0 + bgDelta * 0.18);
    float4 cosmosBottom = SampleTex(CosmosBottomTex, UV + lerp(float2(0.10, 0.10), float2(0.90, 0.90), cssPointer) * 0.08 + seed * 0.01);
    float4 cosmosMiddle = SampleTex(CosmosMiddleTex, UV + lerp(float2(0.15, 0.15), float2(0.85, 0.85), cssPointer) * 0.08 + seed.yx * 0.01);
    float4 cosmosTop = SampleTex(CosmosTopTex, UV + lerp(float2(0.20, 0.20), float2(0.80, 0.80), cssPointer) * 0.08 - seed * 0.01);

    float3 baseColor = cardArt.rgb;
    float opacity = saturate(CardOpacity);
    float strength = max(EffectStrength, 0.0);
    int mode = (int)round(HoloMode);

    float3 result = BasicGloss(baseColor, cssUv, cssPointer, opacity, strength);

    if (mode == 1)
    {
        result = RegularHolo(baseColor, cssUv, cssPointer, bg, mask, opacity, strength);
    }
    else if (mode == 2)
    {
        result = ReverseHolo(baseColor, foilSample.rgb, cssUv, cssPointer, mask, opacity, FoilBrightness, PointerFromCenter, strength);
    }
    else if (mode == 3)
    {
        result = CosmosHolo(baseColor, cosmosBottom.rgb, cosmosMiddle.rgb, cosmosTop.rgb, cssUv, cssPointer, mask, opacity, PointerFromCenter, strength);
    }
    else if (mode == 4)
    {
        result = AmazingRare(baseColor, foilSample.rgb, glitterSampleA.rgb, glitterSampleB.rgb, cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength);
    }
    else if (mode == 5)
    {
        result = RadiantHolo(baseColor, foilSample.rgb, glitterSampleA.rgb, cssUv, cssPointer, bg, mask, artMask, opacity, CardGlowColor, strength);
    }
    else if (mode == 6)
    {
        result = TrainerGalleryHolo(baseColor, cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength);
    }
    else if (mode == 7)
    {
        result = VFamily(baseColor, grainSample.rgb, cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, 0);
    }
    else if (mode == 8)
    {
        result = VFamily(baseColor, max(foilSample.rgb, patternSample.rgb), cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, 1);
    }
    else if (mode == 9)
    {
        result = VFamily(baseColor, max(foilSample.rgb, patternSample.rgb), cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, 2);
    }
    else if (mode == 10)
    {
        result = VFamily(baseColor, max(foilSample.rgb, patternSample.rgb), cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, 3);
    }
    else if (mode == 11)
    {
        result = RainbowMode(baseColor, max(foilSample.rgb, patternSample.rgb), glitterSampleA.rgb, cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, false);
    }
    else if (mode == 12)
    {
        result = RainbowMode(baseColor, max(foilSample.rgb, patternSample.rgb), glitterSampleA.rgb, cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, true);
    }
    else if (mode == 13)
    {
        result = SecretGold(baseColor, max(foilSample.rgb, patternSample.rgb), glitterSampleA.rgb, glitterSampleB.rgb, cssUv, cssPointer, mask, opacity, PointerFromCenter, strength, false);
    }
    else if (mode == 14)
    {
        result = SecretGold(baseColor, max(foilSample.rgb, patternSample.rgb), glitterSampleA.rgb, glitterSampleB.rgb, cssUv, cssPointer, mask, opacity, PointerFromCenter, strength, true);
    }
    else if (mode == 15)
    {
        result = ShinyMode(baseColor, max(foilSample.rgb, patternSample.rgb), glitterSampleA.rgb, cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, 0);
    }
    else if (mode == 16)
    {
        result = ShinyMode(baseColor, max(foilSample.rgb, patternSample.rgb), glitterSampleA.rgb, cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, 1);
    }
    else if (mode == 17)
    {
        result = ShinyMode(baseColor, max(foilSample.rgb, patternSample.rgb), glitterSampleA.rgb, cssUv, cssPointer, bg, mask, opacity, PointerFromCenter, strength, 2);
    }

    Color = saturate(result);
    Alpha = cardArt.a;
}

UnityTexture2D HoloBuildTexture2D(TEXTURE2D_PARAM(tex, samplerstate), float4 texelSize)
{
    return UnityBuildTexture2DStructInternal(TEXTURE2D_ARGS(tex, samplerstate), texelSize, float4(1.0, 1.0, 0.0, 0.0));
}

void HoloCardCompositeGraph_float(float2 UV, out float3 Color, out float Alpha)
{
    HoloCardComposite_float(
        HoloBuildTexture2D(TEXTURE2D_ARGS(_CardArt, sampler_CardArt), _CardArt_TexelSize),
        HoloBuildTexture2D(TEXTURE2D_ARGS(_FoilTex, sampler_FoilTex), _FoilTex_TexelSize),
        HoloBuildTexture2D(TEXTURE2D_ARGS(_MaskTex, sampler_MaskTex), _MaskTex_TexelSize),
        HoloBuildTexture2D(TEXTURE2D_ARGS(_GlitterTex, sampler_GlitterTex), _GlitterTex_TexelSize),
        HoloBuildTexture2D(TEXTURE2D_ARGS(_GrainTex, sampler_GrainTex), _GrainTex_TexelSize),
        HoloBuildTexture2D(TEXTURE2D_ARGS(_PatternTex, sampler_PatternTex), _PatternTex_TexelSize),
        HoloBuildTexture2D(TEXTURE2D_ARGS(_CosmosBottomTex, sampler_CosmosBottomTex), _CosmosBottomTex_TexelSize),
        HoloBuildTexture2D(TEXTURE2D_ARGS(_CosmosMiddleTex, sampler_CosmosMiddleTex), _CosmosMiddleTex_TexelSize),
        HoloBuildTexture2D(TEXTURE2D_ARGS(_CosmosTopTex, sampler_CosmosTopTex), _CosmosTopTex_TexelSize),
        UV,
        _PointerX,
        _PointerY,
        _BackgroundX,
        _BackgroundY,
        _PointerFromCenter,
        _PointerFromLeft,
        _PointerFromTop,
        _CardOpacity,
        _HoloMode,
        _LayoutMaskMode,
        _UseMaskTex,
        _CardGlowColor.rgb,
        _FoilBrightness,
        _EffectStrength,
        _SeedX,
        _SeedY,
        Color,
        Alpha
    );
}

#endif // HOLO_CARD_COMPOSITE_INCLUDED
