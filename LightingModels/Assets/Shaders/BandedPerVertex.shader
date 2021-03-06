﻿Shader "Custom/BandedPerVertex" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _DiffuseLightAttenuation ("Diffuse Light Attenuation", Range(0, 1)) = 1.0
		_LightSteps ("Banded Light Steps", Range(1, 256)) = 1.0
    }
    SubShader {
        Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
            #include "LightingModels.cginc"
			
			fixed4 _Color;
            float _DiffuseLightAttenuation;
			float _LightSteps;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};
			
			v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Transform the normal from object space to world space
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// Get the light direction in world space
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// Compute diffuse term
				fixed3 diffuse = BandedLighting (
					_LightSteps,
					_LightColor0.rgb,
					_Color.rgb,
					_DiffuseLightAttenuation,
					worldNormal,
					worldLight);
				
				o.color = ambient + diffuse;
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				return fixed4(i.color, _Color.a);
			}
			
			ENDCG
		}
    }
    FallBack "Diffuse"
}
