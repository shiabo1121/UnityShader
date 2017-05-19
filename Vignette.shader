Shader "Custom/Vignette" 
{
	Properties 
	{
		_MainTex ("MainTex", 2D) = "white" {} 
	    _fade      ("Opacity",   float) = 1
		_intensity ("Intensity", float) = 1
		_width     ("Width",     float) = 0.5
		_height    ("Height",    float) = 0.5
		_ellipse   ("Ellipse",   float) = 2
		_fuzzy     ("Fuzzy",     float) = 0
	}
	
	SubShader 
	{ 
		Tags 
		{ 
		  "QUEUE"="Transparent" 
		  "IgnoreProjector"="True"
		  "RenderType"="Transparent" 
		}
		Pass 
		{
			Cull Off Lighting Off ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha
//			Blend Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
        	#pragma exclude_renderers xbox360 ps3 flash 
			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 vertex : POSITION;
				float2 uv: TEXCOORD0;
			};

			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord: TEXCOORD0; // 输入的模型纹理坐标集
			};

			float _fade;
			float _intensity;
			float _width;
			float _height;
			float _ellipse;
			float _fuzzy;
			float4 _MainTex_ST;  // 区域图采样
			sampler2D _MainTex;  // 区域图样本对象
			
			v2f vert(in appdata_t v) 
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			half4 frag(v2f IN) : COLOR
			{				
				half4 mainCol = tex2D(_MainTex , IN.uv);
				half4 fragColor = (0.0,0.0,0.0,0.0);
				float2 p = (_MainTex_ST.xy - 2.0 * IN.uv.xy) / _MainTex_ST.y;
				half4 col = (1.0,1.0,1.0);
				
				col.w = clamp(pow(abs(p.x / 0.5)* _width, _ellipse) + 
							pow(abs(p.y / 0.5)* _height, _ellipse), 0.0, 1.0);					
				half res = step(1.0, col.w);
				half colw = 1.0 - res;
				col.w *= _fade * _intensity * _fuzzy * colw;
				fragColor = lerp(mainCol, col, col.w) * colw;			
				return fragColor;
			}
			ENDCG
		}
	}
	
	FallBack "Diffuse"
}