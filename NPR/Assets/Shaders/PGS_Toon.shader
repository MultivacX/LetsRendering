Shader "Custom/PGS_Toon" {
    Properties {
		_Outline ("Outline", Range(0, 1)) = 0.1
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _NormalZ ("Normal Z", Range(-1, 1)) = -0.5

		_Color ("Color Tint", Color) = (1, 1, 1, 1)
	}
    SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		UsePass "Custom/ProceduralGeometrySilhouetting01/OUTLINE"
		UsePass "Custom/PGS_Color/COLOR"
    }
    FallBack "Diffuse"
}
