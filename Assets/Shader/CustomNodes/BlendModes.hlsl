#ifndef BLEND_MODES_INCLUDED
#define BLEND_MODES_INCLUDED

float3 BlendMultiply(float3 baseColor, float3 blend)
{
    return baseColor * blend;
}

float3 BlendScreen(float3 baseColor, float3 blend)
{
    return 1.0 - (1.0 - baseColor) * (1.0 - blend);
}

float3 BlendOverlay(float3 baseColor, float3 blend)
{
    return lerp(
        2.0 * baseColor * blend,
        1.0 - 2.0 * (1.0 - baseColor) * (1.0 - blend),
        step(0.5, baseColor)
    );
}

float3 BlendHardLight(float3 baseColor, float3 blend)
{
    return BlendOverlay(blend, baseColor);
}

float3 BlendSoftLight(float3 baseColor, float3 blend)
{
    float3 dark = baseColor - (1.0 - 2.0 * blend) * baseColor * (1.0 - baseColor);
    float3 light = baseColor + (2.0 * blend - 1.0) * (sqrt(max(baseColor, 0.0)) - baseColor);
    return lerp(dark, light, step(0.5, blend));
}

float3 BlendColorDodge(float3 baseColor, float3 blend)
{
    return saturate(baseColor / max(1.0 - blend, 0.001));
}

float3 BlendColorBurn(float3 baseColor, float3 blend)
{
    return saturate(1.0 - (1.0 - baseColor) / max(blend, 0.001));
}

float3 BlendDifference(float3 baseColor, float3 blend)
{
    return abs(baseColor - blend);
}

float3 BlendExclusion(float3 baseColor, float3 blend)
{
    return baseColor + blend - 2.0 * baseColor * blend;
}

float BlendLum(float3 c)
{
    return dot(c, float3(0.299, 0.587, 0.114));
}

float3 BlendClipColor(float3 c)
{
    float lum = BlendLum(c);
    float minC = min(c.r, min(c.g, c.b));
    float maxC = max(c.r, max(c.g, c.b));

    if (minC < 0.0)
    {
        c = lum + ((c - lum) * lum) / max(lum - minC, 0.001);
    }

    if (maxC > 1.0)
    {
        c = lum + ((c - lum) * (1.0 - lum)) / max(maxC - lum, 0.001);
    }

    return saturate(c);
}

float3 BlendSetLum(float3 c, float lum)
{
    return BlendClipColor(c + (lum - BlendLum(c)));
}

float3 BlendSetSat(float3 c, float sat)
{
    float minC = min(c.r, min(c.g, c.b));
    float maxC = max(c.r, max(c.g, c.b));

    if (maxC <= minC + 0.0001)
    {
        return float3(0.0, 0.0, 0.0);
    }

    float3 result = (c - minC) * sat / max(maxC - minC, 0.001);
    return saturate(result);
}

float3 BlendHue(float3 baseColor, float3 blend)
{
    float sat = max(baseColor.r, max(baseColor.g, baseColor.b)) - min(baseColor.r, min(baseColor.g, baseColor.b));
    return BlendSetLum(BlendSetSat(blend, sat), BlendLum(baseColor));
}

float3 BlendSaturation(float3 baseColor, float3 blend)
{
    float sat = max(blend.r, max(blend.g, blend.b)) - min(blend.r, min(blend.g, blend.b));
    return BlendSetLum(BlendSetSat(baseColor, sat), BlendLum(baseColor));
}

float3 BlendLuminosity(float3 baseColor, float3 blend)
{
    return BlendSetLum(baseColor, BlendLum(blend));
}

float3 ApplyCssFilter(float3 col, float brightness, float contrast, float saturation)
{
    col *= brightness;
    col = (col - 0.5) * contrast + 0.5;
    float gray = BlendLum(col);
    col = lerp(float3(gray, gray, gray), col, saturation);
    return saturate(col);
}

float3 FilterBrightness(float3 col, float brightness)
{
    return saturate(col * brightness);
}

float3 FilterContrast(float3 col, float contrast)
{
    return saturate((col - 0.5) * contrast + 0.5);
}

float3 FilterSaturation(float3 col, float saturation)
{
    float gray = BlendLum(col);
    return saturate(lerp(float3(gray, gray, gray), col, saturation));
}

void Overlay_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    float3 overlaid = BlendOverlay(baseColor, blend);
    result = lerp(baseColor, overlaid, opacity);
}

void ColorDodge_float(float3 baseColor, float3 blend, out float3 result)
{
    result = BlendColorDodge(baseColor, blend);
}

void Multiply_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendMultiply(baseColor, blend), opacity);
}

void Screen_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendScreen(baseColor, blend), opacity);
}

void HardLight_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendHardLight(baseColor, blend), opacity);
}

void SoftLight_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendSoftLight(baseColor, blend), opacity);
}

void ColorBurn_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendColorBurn(baseColor, blend), opacity);
}

void Difference_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendDifference(baseColor, blend), opacity);
}

void Exclusion_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendExclusion(baseColor, blend), opacity);
}

void Hue_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendHue(baseColor, blend), opacity);
}

void SaturationBlend_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendSaturation(baseColor, blend), opacity);
}

void Saturation_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendSaturation(baseColor, blend), opacity);
}

void Luminosity_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    result = lerp(baseColor, BlendLuminosity(baseColor, blend), opacity);
}

void ApplyCssFilter_float(float3 color, float brightness, float contrast, float saturation, out float3 result)
{
    result = ApplyCssFilter(color, brightness, contrast, saturation);
}

void Brightness_float(float3 color, float brightness, out float3 result)
{
    result = FilterBrightness(color, brightness);
}

void Contrast_float(float3 color, float contrast, out float3 result)
{
    result = FilterContrast(color, contrast);
}

void FilterSaturation_float(float3 color, float saturation, out float3 result)
{
    result = FilterSaturation(color, saturation);
}

#endif // BLEND_MODES_INCLUDED
