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

#endif // BLEND_MODES_INCLUDED