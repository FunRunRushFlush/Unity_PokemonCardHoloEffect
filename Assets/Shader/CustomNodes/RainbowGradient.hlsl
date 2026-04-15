#ifndef RAINBOW_GRADIENT_INCLUDED
#define RAINBOW_GRADIENT_INCLUDED

// Custom Function: "RainbowGradient"
// Input: float t (0-1)
// Output: float3 color

void RainbowGradient_float(float t, out float3 color) {
    float3 red     = float3(0.973, 0.055, 0.208);  // #f80e35
    float3 yellow  = float3(0.933, 0.875, 0.063);  // #eedf10
    float3 green   = float3(0.129, 0.914, 0.522);  // #21e985
    float3 cyan    = float3(0.051, 0.741, 0.914);  // #0dbde9
    float3 violet  = float3(0.788, 0.161, 0.945);  // #c929f1
    
    float segment = t * 5.0;
    float localT = frac(segment);
    int idx = (int)floor(segment) % 5;
    
    if (idx == 0) color = lerp(red, yellow, localT);
    else if (idx == 1) color = lerp(yellow, green, localT);
    else if (idx == 2) color = lerp(green, cyan, localT);
    else if (idx == 3) color = lerp(cyan, violet, localT);
    else color = lerp(violet, red, localT);
}

#endif // RAINBOW_GRADIENT_INCLUDED