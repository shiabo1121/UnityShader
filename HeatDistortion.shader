﻿Shader "Custom/HeatDistortion"
{
	Properties
    {
    	_GrabTexture("GrabTex", 2D) = "white" {}
	    _NoiseTex ("絮乱图", 2D) = "white" {}
	    _AreaTex ("区域图(Alpha)：白色为显示区域，透明为不显示区域", 2D) = "white" {}
	    _MoveSpeed  ("絮乱图移动速度", range (0,1.5)) = 1
	    _MoveForce  ("絮乱图叠加后移动强度", range (0,0.1)) = 0.1
    }
    Category
    {
    	Tags { "Queue"="Transparent"
        "RenderType"="Transparent" }

         Blend SrcAlpha OneMinusSrcAlpha
         AlphaTest Greater .01
         ZWrite Off

		SubShader
		{
			Pass
			{
                Tags { "LightMode" = "Always" }
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
	            #pragma fragmentoption ARB_precision_hint_fastest
	            #include "UnityCG.cginc"

				struct appdata_t
				{
	                float4 vertex : POSITION; // 输入的模型坐标顶点信息
	                float2 texcoord: TEXCOORD0; // 输入的模型纹理坐标集
	            };

	            struct v2f
	            {

	                float4 vertex : SV_POSITION; // 输出的顶点信息
	                float4 uvgrab : TEXCOORD0; // 输出的纹理做标集0
	                float2 uvmain : TEXCOORD1; // 输出的纹理坐标集1
	            };

				float _MoveSpeed;  // 声明絮乱图移动速度
				float _MoveForce;  // 声明运动强度
				float4 _NoiseTex_ST; // 絮乱图采样
				float4 _AreaTex_ST;  // 区域图采样
				sampler2D _NoiseTex; // 絮乱图样本对象
				sampler2D _AreaTex;  // 区域图样本对象
				sampler2D _GrabTexture; // 全屏幕纹理的样本对象，由GrabPass赋值
	            float4 _GrabTexture_ST;
	            v2f vert (appdata_t v)
	            {
	                v2f o;
	                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
	                #if UNITY_UV_STARTS_AT_TOP  // Direct3D类似平台scale为-1；OpenGL类似平台为1。
	                float scale = -1.0;
	                #else
	                float scale = 1.0;
	                #endif
	                o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
	                o.uvgrab.zw = o.vertex.zw;
					o.uvmain.xy = v.texcoord;
	                o.uvmain = TRANSFORM_TEX(v.texcoord, _AreaTex);
					return o;
	            }

				half4 frag( v2f i ) : COLOR
	            {
	                half4 offsetColor1 = tex2D(_NoiseTex, i.uvmain + _Time.xz * _MoveSpeed);// 将xy与xz交叉位移
	                half4 offsetColor2 = tex2D(_NoiseTex, i.uvmain - _Time.yx * _MoveSpeed);// 将xy与yx交叉位移
	                i.uvmain.x += ((offsetColor1.r + offsetColor2.r) - 1) * _MoveForce; // 叠加强度
	                i.uvmain.y += ((offsetColor1.g + offsetColor2.g) - 1) * _MoveForce;

	                half4 noiseCol = tex2D(_AreaTex , i.uvmain);
	                half4 areaCol = tex2D(_GrabTexture, i.uvmain);
	                half4 result = noiseCol *(areaCol );
	                return  result;
	            }
				ENDCG
			}
		}
		FallBack "Diffuse"
	}
}
