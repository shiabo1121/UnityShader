Shader "Custom/WaterCaustic" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {

		Cull Off
        Lighting Off
        ZWrite Off
        Fog { Mode Off }
        ColorMask RGB
        AlphaTest Greater .01
        Blend One One
        Blend SrcAlpha OneMinusSrcAlpha

		Pass{
			Tags
			{
				"RenderType"="Opaque"
				"Queue" = "Transparent"
			}
			LOD 200

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma target 3.0

			#define TAU 6.28318530718
			#define MAX_ITER 4.0

			sampler2D _MainTex;
			float4 _MainTex_ST;  // 区域图采样

			struct vertOut {
	            float4 pos:SV_POSITION;
	            float4 srcPos;
	            float2 uv0: TEXCOORD0;
	        };

	        vertOut vert(appdata_base v) {
	            vertOut o;
	            o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
	            o.srcPos = ComputeScreenPos(o.pos);

             	o.uv0.xy = v.texcoord;
                o.uv0 = TRANSFORM_TEX(v.texcoord, _MainTex);

	            return o;
	        }

	        fixed4 frag(vertOut vo) : COLOR0 {
	        	float2 uv = vo.uv0;

	        	float2 p = fmod(uv*TAU*2.0, TAU)-250.0;
				float2 i = float2(p);
				float c = 1.0;
				float inten = .005;

				for (float n = 0.0; n < MAX_ITER; n++)
				{
					float t = _Time * (1.0 - (3.5 / float(n+1))) * 10;
					i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
					c = c + 1.0/length(float2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
				}
				c = c / float(MAX_ITER);
				c = 1.17-pow(c, 1.4);
				float3 colour = float3(pow(abs(c), 8.0));
			    colour = clamp(colour + float3(0.0, 0.71, 0.93), 0.0, 1.0);
			    fixed4 col = fixed4(colour, 0.65);
			    fixed4 mainColor =  tex2D(_MainTex, uv.xy);
				return col * mainColor.w ;
	        }

			ENDCG
		}
	}
	FallBack "Diffuse"
}
