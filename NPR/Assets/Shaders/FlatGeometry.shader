Shader "Custom/FlatGeometry" {
    Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
            #pragma geometry geom
			#pragma fragment frag

			#include "Lighting.cginc"
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2g {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
            };
            
            struct g2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
            };
			
			v2g vert(a2v v) {
				v2g o;

                // Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// Transform the normal from object space to world space
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				// Transform the vertex from object spacet to world space
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				return o;
			}

            [maxvertexcount(3)]
            void geom (triangle v2g input[3], inout TriangleStream<g2f> tristream) {
				float3 p0 = input[0].worldPos.xyz;
				float3 p1 = input[1].worldPos.xyz;
				float3 p2 = input[2].worldPos.xyz;

				float3 triangleNormal = normalize(cross(p1 - p0, p2 - p0));

				input[0].worldNormal = triangleNormal;
				input[1].worldNormal = triangleNormal;
				input[2].worldNormal = triangleNormal;

                tristream.Append(input[0]);
	            tristream.Append(input[1]);
	            tristream.Append(input[2]);
            }
			
			fixed4 frag(g2f i) : SV_Target {
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				// Compute diffuse term
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				
				// Get the reflect direction in world space
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				// Get the view direction in world space
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				// Compute specular term
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
