Shader "Custom/SEMPerFrag" {
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
				float3 eye : TEXCOORD0;
				float3 vn : TEXCOORD1;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.eye = UnityObjectToViewPos(v.vertex).xyz;
				o.vn = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  

				return o;
			}

			float4 frag(v2f i) : SV_Target { 
				float3 r = reflect(normalize(i.eye), normalize(i.vn)); // r = e - 2. * dot( n, e ) * n;

				// float m = 2.0 * sqrt(pow(r.x, 2.0) + pow(r.y, 2.0) + pow(r.z + 1.0, 2.0));
				float m = 2.82842712474619 * sqrt( r.z + 1.0 );
				float2 xy = r.xy / m + 0.5;

				fixed3 c = tex2D(_MainTex, xy).xyz;
				return fixed4(c, 1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
