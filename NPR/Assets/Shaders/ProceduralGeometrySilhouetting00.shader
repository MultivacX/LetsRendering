Shader "Custom/ProceduralGeometrySilhouetting00" {
    SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass {
			Cull Back
            // Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			int _NormalType;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			}; 
			
			struct v2f {
			    float4 pos : SV_POSITION;
                fixed4 color_debug : COLOR0;
			};
			
			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				if (_NormalType == 0) {
					o.color_debug = fixed4(normalize(v.normal) * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
				}
				else if (_NormalType == 1) {
					// 将顶点法向量变换到摄像机空间
					// 注意Unity3D的摄像机空间是右手坐标系
					float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);

					// 由于单位法向量 xyz 的取值范围是 [-1, 1]，颜色 rgb 取值范围是 [0, 1]
					// 所以需要对 xyz 做变换 r = x * 0.5 + 0.5
					// 例如指向摄像机的法向量 (0, 0, 1) 对应的颜色为 (0.5, 0.5, 1.0)
					o.color_debug = fixed4(normalize(normal) * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
				} else if (_NormalType == 2) {
					o.color_debug = fixed4(normalize(mul(v.normal, (float3x3)unity_WorldToObject)) * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);
				}

				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
                return i.color_debug;        
			}
			
			ENDCG
		}
    }
}
