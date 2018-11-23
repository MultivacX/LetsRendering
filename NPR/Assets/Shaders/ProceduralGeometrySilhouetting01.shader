Shader "Custom/ProceduralGeometrySilhouetting01" {
    Properties {
		_Outline ("Outline", Range(0, 1)) = 0.1
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)

        _NormalZ ("Normal Z", Range(-1, 1)) = -0.5
	}
    SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass {
			NAME "OUTLINE"
			
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float _Outline;
			fixed4 _OutlineColor;
            float _NormalZ;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			}; 
			
			struct v2f {
			    float4 pos : SV_POSITION;
			};
			
			v2f vert (a2v v) {
				v2f o;
				
                // 转换顶点位置到相机空间
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex);

                // 转换顶点法向量到相机空间
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  

                // 法向量z取负值意味着它指向屏幕里
                // 这样移动顶点后不会挡住正面的三角形
                // 毕竟我们只是需要描边
				normal.z = _NormalZ;

                // 顶点沿着法向量的方向进行扩张
                // _Outline表示扩张的大小 
				pos = pos + float4(normalize(normal), 0) * _Outline;

                // 将修改过的顶点位置转换到投影坐标系
				o.pos = mul(UNITY_MATRIX_P, pos);
				
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				return float4(_OutlineColor.rgb, 1);               
			}
			
			ENDCG
		}
    }
}
