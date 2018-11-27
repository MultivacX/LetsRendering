Shader "Custom/GoochPerVertex" {
    Properties {
        _Outline ("Outline", Range(0, 1)) = 0.1
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _NormalZ ("Normal Z", Range(-1, 1)) = -0.5

        _Color ("Color", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
        _Shine ("Shine", Range(1.0, 500)) = 20

		_a ("a", Range(0.0, 1.0)) = 0.2
		_b ("b", Range(0.0, 1.0)) = 0.6
		_kBlue ("Cool", Color) = (0.0, 0.0, 0.4)
		_kYellow ("Warm", Color) = (0.4, 0.4, 0.0)
	}
	SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		UsePass "Custom/ProceduralGeometrySilhouetting01/OUTLINE"
        
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
            fixed4 _Color;
			fixed4 _Specular;
            float _Shine;

			float _a;
			float _b;
			fixed4 _kBlue;
			fixed4 _kYellow;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 color : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);

				 // diffuse
				float NL = dot(normalize(worldNormal), -normalize(worldLightDir));
                float it = (1.0 + NL) / 2.0; // ((1 + dot(I, n)) / 2)
				fixed3 kCool = _kBlue + _a * _Color.rgb;
				fixed3 kWarm = _kYellow + _b * _Color.rgb;
                fixed3 color = it * kCool + (1 - it) * kWarm;

                // specular
                fixed3 R = reflect( -normalize(worldLightDir), normalize(worldNormal) );
                float ER = clamp( dot( normalize(viewDir), normalize(R)), 0.0, 1.0);
                fixed4 spec = _Specular * pow(ER, _Shine);

				o.color = color + spec.rgb;

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
