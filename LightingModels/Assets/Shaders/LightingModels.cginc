#if !defined(LIGHTING_MODELS_INCLUDED)
#define LIGHTING_MODELS_INCLUDED

float3 LambertDiffuseLighting (
    float3 SurfaceColor, // objects color
    float3 LightColor, // lights color * intensity
    float LightAttenuation, // value of light at point (shadow/falloff)
    float3 normalDirection,
    float3 lightDirection) {

    // saturate(dot(normalDirection, lightDirection))
    float NdotL = max(0.0, dot(normalDirection, lightDirection));
    float LambertDiffuse = NdotL * SurfaceColor;
    float3 finalColor = LambertDiffuse * LightAttenuation * LightColor;
    return finalColor;
}

#endif // LIGHTING_MODELS_INCLUDED