Shader "Custom/Sh01" {
    // 着色器属性
    Properties {
        // uniform变量名 ("材质编辑器面板上显示的名字", 变量类型) = 默认值
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
	}

    // 子着色器
	SubShader {
        Pass {
            // 使用前向渲染
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM

            // 顶点着色器函数名
            #pragma vertex vert
            // 片元着色器函数名
            #pragma fragment frag

            #include "Lighting.cginc"
            
            // uniform变量 顶点着色器和片元着色器都可以使用
            uniform fixed4 _Color;

            // 发送给顶点着色器的 attribute 数据结构
			struct a2v {
                float4 vertex : POSITION; // 模型坐标系下的顶点位置
				float3 normal : NORMAL; // 模型坐标系下的顶点法向量
            };
            
            // 发送给片元着色器的 varying 数据结构
            struct v2f {
                float4 pos : SV_POSITION; // 投影坐标系下的顶点位置
                float3 worldNormal : TEXCOORD0; // 世界坐标系下的顶点法向量
            };
            
            v2f vert(a2v v) {
            	v2f o;

                // 将顶点位置从模型坐标系转换到投影坐标系
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// 将顶点法向量从模型坐标系转换到世界坐标系
                // 注意法向量的变换矩阵
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                // 归一化
                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
                // 根据法向量和光源方向计算散射光的亮度值
				float diffuse = max(0, dot(worldNormal, worldLightDir));
                
                // 根据亮度值，分别阶梯式地映射到新的亮度值
                if (diffuse > 0.8) {
                    diffuse = 1.0;
                }
                else if (diffuse > 0.5) {
                    diffuse = 0.6;
                }
                else if (diffuse > 0.2) {
                    diffuse = 0.4;
                }
                else {
                    diffuse = 0.2;
                }

                // 输出颜色
                return fixed4(_Color.rgb * diffuse, 1.0);
            }

            ENDCG
        }
    }
}
