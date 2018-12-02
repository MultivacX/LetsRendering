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

float3 HalfLambertDiffuseLighting (
    float3 SurfaceColor, // objects color
    float3 LightColor, // lights color * intensity
    float LightAttenuation, // value of light at point (shadow/falloff)
    float wrapValue, // [0.5, 1]
    float exponent, // 1.0
    float3 normalDirection,
    float3 lightDirection) {

    // saturate(dot(normalDirection, lightDirection))
    float NdotL = max(0.0, dot(normalDirection, lightDirection));
    float HalfLambertDiffuse = pow(NdotL * wrapValue + (1.0 - wrapValue), exponent) * SurfaceColor;
    float3 finalColor = HalfLambertDiffuse * LightAttenuation * LightColor;
    return finalColor;
}

float3 PhongSpecularLighting (
    float3 LightColor,
    float3 SpecularColor,
    float SpecularGloss,
    float3 worldLightDir, 
    float3 worldNormal, 
    float3 worldPosition, 
    float3 worldCamreraPos) {

    // Get the reflect direction in world space
    float3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
    // Get the view direction in world space
    float3 viewDir = normalize(worldCamreraPos - worldPosition);
    // Compute specular term
    float3 specular = LightColor * SpecularColor * pow(saturate(dot(reflectDir, viewDir)), SpecularGloss);
    return specular;
}

float3 BlinnPhongSpecularLighting (
    float3 LightColor,
    float3 SpecularColor,
    float SpecularGloss,
    float3 worldLightDir, 
    float3 worldNormal, 
    float3 worldPosition, 
    float3 worldCamreraPos) {

    // Get the view direction in world space
    float3 viewDir = normalize(worldCamreraPos - worldPosition);
    // Get the half direction in world space
	float3 halfDir = normalize(worldLightDir + viewDir);
    // Compute specular term
    float3 specular = LightColor * SpecularColor * pow(saturate(dot(worldNormal, halfDir)), SpecularGloss);
    return specular;
}

float3 BandedLighting (
    float LightSteps,
    float3 LightColor,
    float3 diffuseColor,
    float LightAttenuation,
    float3 normalDirection,
    float3 lightDirection) {
    float NdotL = max(0.0, dot( normalDirection, lightDirection ));

    float lightBandsMultiplier = LightSteps / 256;
    float lightBandsAdditive = LightSteps / 2;
    fixed bandedNdotL = (floor((NdotL * 256 + lightBandsAdditive) / LightSteps)) * lightBandsMultiplier;

    float3 lightingModel = bandedNdotL * diffuseColor;
    float attenuation = LightAttenuation;//LIGHT_ATTENUATION(i);
    float3 attenColor = attenuation * LightColor;
    float4 finalDiffuse = float4(lightingModel * attenColor,1);
    return finalDiffuse;
}

#endif // LIGHTING_MODELS_INCLUDED