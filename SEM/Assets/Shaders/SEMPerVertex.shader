Shader "Custom/SEMPerVertex" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 eye = normalize(UnityObjectToViewPos(v.vertex).xyz);
				float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));  
				float3 r = reflect(eye, normal); // r = e - 2. * dot( n, e ) * n;

				// float m = 2.0 * sqrt(pow(r.x, 2.0) + pow(r.y, 2.0) + pow(r.z + 1.0, 2.0));
				float m = 2.82842712474619 * sqrt( r.z + 1.0 );
				o.uv.xy = r.xy / m + 0.5;

				return o;
			}

			float4 frag(v2f i) : SV_Target { 
				fixed3 c = tex2D(_MainTex, i.uv.xy).xyz;
				return fixed4(c, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
