Shader "Custom/CoolDown"
{
	Properties {
		_CurrentTime("Current Time", float) = 0.0
		_MaskScale("Mask Scale", float) = 1.0
		_CoolDown("Cool Down",float) = 1.0
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	Category
	{
		Tags { "Queue"="Transparent-1" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off

		SubShader {
			Pass {
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
            	#pragma exclude_renderers xbox360 ps3 flash

				#include "UnityCG.cginc"
				#define M_PI2 3.14159265358979 * 2

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _CurrentTime;
				float _MaskScale;
				float _CoolDown;

				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				v2f vert(appdata_t v)
				{
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}

				fixed4 frag(v2f iParam) : SV_Target
				{
					fixed4 col = float4(1.0, 1.0, 1.0, 1.0);
					fixed4 fragColor = float4(1,1,1,1);
					float angle = (_Time.y - _CurrentTime) * M_PI2 / _CoolDown;
					angle = clamp(angle, 0, M_PI2);
					float2 p = (_MainTex_ST.xy - 2.0 * iParam.uv.xy) / _MainTex_ST.y;
					float q = atan2(p.x, p.y);
					float f = step(0.0, cos((q - angle) * 0.5));

					float2 uv = iParam.uv.xy / _MainTex_ST.xy;
					float4 tc = tex2D(_MainTex, iParam.uv);
					float2 vf = float2(f,f);
					fragColor = lerp(tc, col, vf * _MaskScale);
					return tc*fragColor;
				}
				ENDCG
			}
		}
		FallBack "Diffuse"
	}
}