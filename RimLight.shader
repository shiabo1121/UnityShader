Shader "Custom/RimLight" {
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
 		_ShineScale ("Shine Scale", float) = 0.0
 		_ShineScaleSpeed ("Shine Scale Speed", float) = 2.5
		_ShinePower ("Shine Power", Range(0.0,8.0)) = 0.1
		_ShineColor ("Shine Color", Color) = (1.0, 0.0, 0.0, 1.0)
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_CurrentTime("Current Time", float) = 0.0
		_RimLightToggle("Rim Light Toggle", float) = 1.0
		_MaxValue("Max Value", float) = 1.0
	}
	SubShader
	{
		LOD 200
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
		}
		Pass
		{
			Cull off
			Lighting Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _ShineScale;
			float _ShinePower;
			fixed4 _ShineColor;
			fixed4 _Color;
			fixed4 _DebugColor;
			float _CurrentTime;
			float _ShineScaleSpeed;
			float _RimLightToggle;
			float _MaxValue;

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal: NORMAL;
			};
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;

				float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				_ShineScale = lerp(_ShineScale, 0.0,  clamp( _ShineScaleSpeed*(_Time.y - _CurrentTime), 0.0, _MaxValue)) ;

				o.color = _ShineScale * pow(1 - saturate(dot( normalize(viewDir), v.normal)), _ShinePower) * _ShineColor;
				return o;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				_Color = lerp(_Color, fixed4(1.0,1.0,1.0,1.0), clamp( _Time.y - _CurrentTime, 0.0, _MaxValue )) ;
				fixed4 col = _Color*tex2D(_MainTex, IN.texcoord) + _RimLightToggle * IN.color;
				return col;
			}
			ENDCG
		}
	}
	SubShader
	{
		Pass
		{
			//Tags { "Queue" = "Transparent" }
			//ZWrite Off
			Lighting Off
			Cull Off
		 	SetTexture [_MainTex]
		 	{
               combine texture
            }
		}
	}
}
