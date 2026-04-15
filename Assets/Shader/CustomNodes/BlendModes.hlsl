#ifndef BLEND_MODES_INCLUDED
#define BLEND_MODES_INCLUDED

// --- Overlay ---
void Overlay_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    float3 overlaid = lerp(
        2.0 * baseColor * blend,
        1.0 - 2.0 * (1.0 - baseColor) * (1.0 - blend),
        step(0.5, baseColor)
    );
    result = lerp(baseColor, overlaid, opacity);
}

// --- Color Dodge ---
void ColorDodge_float(float3 baseColor, float3 blend, out float3 result)
{
    result = saturate(baseColor / max(1.0 - blend, 0.001));
}

// --- Hard Light (= Overlay with swapped args) ---
void HardLight_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    float3 hardlit = lerp(
        2.0 * baseColor * blend,
        1.0 - 2.0 * (1.0 - baseColor) * (1.0 - blend),
        step(0.5, blend)
    );
    result = lerp(baseColor, hardlit, opacity);
}

// --- Soft Light ---
void SoftLight_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    float3 softlit = lerp(
        baseColor - (1.0 - 2.0 * blend) * baseColor * (1.0 - baseColor),
        baseColor + (2.0 * blend - 1.0) * (sqrt(baseColor) - baseColor),
        step(0.5, blend)
    );
    result = lerp(baseColor, softlit, opacity);
}

// --- Screen ---
void Screen_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    float3 screened = 1.0 - (1.0 - baseColor) * (1.0 - blend);
    result = lerp(baseColor, screened, opacity);
}

// --- Multiply ---
void Multiply_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    float3 multiplied = baseColor * blend;
    result = lerp(baseColor, multiplied, opacity);
}

// --- Exclusion ---
void Exclusion_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    float3 excluded = baseColor + blend - 2.0 * baseColor * blend;
    result = lerp(baseColor, excluded, opacity);
}

// --- Difference ---
void Difference_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    float3 diffed = abs(baseColor - blend);
    result = lerp(baseColor, diffed, opacity);
}

// --- Luminosity ---
// Used by the spotlight layer in regular holo
void Luminosity_float(float3 baseColor, float3 blend, float opacity, out float3 result)
{
    // Extract luminance from blend, apply to base hue/saturation
    float lumBase  = dot(baseColor, float3(0.299, 0.587, 0.114));
    float lumBlend = dot(blend,     float3(0.299, 0.587, 0.114));
    float3 lumAdjusted = baseColor + (lumBlend - lumBase);
    result = lerp(baseColor, saturate(lumAdjusted), opacity);
}

#endif // BLEND_MODES_INCLUDED