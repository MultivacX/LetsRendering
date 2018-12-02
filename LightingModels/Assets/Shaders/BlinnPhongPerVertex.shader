Shader "Custom/BlinnPhongPerVertex" {
    Properties {
        [Header(Diffuse)]
        _Color ("Color", Color) = (1,1,1,1)
        _DiffuseLightAttenuation ("Diffuse Light Attenuation", Range(0, 1)) = 1.0
		_DiffuseWarpValue ("Diffuse Warp Value", Range(0.5, 1)) = 0.5
		_DiffuseExponent ("Diffuse Exponent", Range(1, 2)) = 1.0

		[Header(Specular)]
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_SpecularGloss ("Specular Gloss", Range(8.0, 256)) = 20
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
			float _DiffuseWarpValue;
			float _DiffuseExponent;

			fixed4 _SpecularColor;
            float _SpecularGloss;
			
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
                fixed3 diffuse = LambertDiffuseLighting (
                    _Color.rgb, // objects color
                    _LightColor0.rgb, // lights color * intensity
                    _DiffuseLightAttenuation, // value of light at point (shadow/falloff)
                    worldNormal,
                    worldLight);

				// Compute specular term
				fixed3 specular = BlinnPhongSpecularLighting (
                    _Color.rgb,
					_SpecularColor,
					_SpecularGloss,
					worldLight, 
    				worldNormal, 
    				mul(unity_ObjectToWorld, v.vertex).xyz, 
    				_WorldSpaceCameraPos.xyz);
				
				o.color = ambient + diffuse + specular;
				
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
