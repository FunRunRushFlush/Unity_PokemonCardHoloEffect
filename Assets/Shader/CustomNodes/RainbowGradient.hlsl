#ifndef RAINBOW_GRADIENT_INCLUDED
#define RAINBOW_GRADIENT_INCLUDED

void RainbowGradient_float(float t, out float3 color)
{
    float3 red = float()
    result = lerp(baseColor, overlaid, opacity);
}

void ColorDodge_float(float3 baseColor, float3 blend, out float3 result)
{
    result = saturate(baseColor / max(1.0 - blend, 0.001));
}

#endif // RAINBOW_GRADIENT_INCLUDED