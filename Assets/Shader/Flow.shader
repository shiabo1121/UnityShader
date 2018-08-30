Shader "Custom/Flow" 
{
	Properties
	{
		_MainTex("底图 (RGB)", 2D) = "white" {}
		_FlowTex("流光图 (A)", 2D) = "white" {}
		_ScrollXSpeed("横向速度", Range(0, 10)) = 2
		_ScrollYSpeed("竖向速度", Range(0, 10)) = 0
		_ScrollDirection("方向", Range(-1, 1)) = -1
		_FlowColor("流光颜色",Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }			

	 	Pass
	    {	    
		    Cull Off Lighting Off ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha
			LOD 200			
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
	    	#pragma exclude_renderers xbox360 ps3 flash 
			#include "UnityCG.cginc"				

			sampler2D _MainTex;
			sampler2D _FlowTex;
			fixed _ScrollXSpeed;
			fixed _ScrollYSpeed;
			fixed _ScrollDirection;
			float4 _FlowColor;
			float4 _MainTex_ST;
			float4 _FlowTex_ST;
			
			struct v2f 
			{
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
				float2 uv_FlowTex : TEXCOORD1;
			};

			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord: TEXCOORD0; // 输入的模型纹理坐标集
			};

			v2f vert(in appdata_t v) 
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv_FlowTex = TRANSFORM_TEX(v.texcoord, _FlowTex);
				return o;
			}

			fixed4 frag(v2f IN) : COLOR
			{
				//改变流光图的uv
				fixed2 scrolledUV = IN.uv_FlowTex;
				fixed xScrollValue = _ScrollXSpeed * _Time.y;// _Time.y等同于Time.timeSinceLevelLoad
				fixed yScrollValue = _ScrollYSpeed * _Time.y;
				scrolledUV += fixed2(xScrollValue, yScrollValue) * _ScrollDirection;
				
				fixed4 finalCol ;
				fixed4 c = tex2D(_FlowTex, scrolledUV);
				float4 d = tex2D(_MainTex, IN.uv);
				finalCol = fixed4(c.rgb * _FlowColor.rgb +  d.rgb , 1.0);
				finalCol.a = d.a;
				return finalCol;
			}
			ENDCG
		}		
	}
	FallBack "Diffuse"
}
