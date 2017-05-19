Shader "Custom/wave" 
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _ScrollXSpeed("X Scroll Speed", Range(0, 10)) = 2
    }
    
    SubShader
    {
        Cull Off
        Lighting Off
        ZWrite Off
        Fog { Mode Off }
        ColorMask RGB
        AlphaTest Greater .01
        Blend One One
        Blend SrcAlpha OneMinusSrcAlpha
        
        Tags
        {
            "LightMode" = "ForwardBase" 
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
        }
        LOD 200
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "unityCG.cginc"
            #pragma target 3.0
            
            sampler2D _MainTex;
            float4 _MainTex_ST;  // 区域图采样
            fixed _ScrollXSpeed;
                        
            struct appdata 
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            
            struct vertOut 
            {    
                float4 pos:SV_POSITION;    
                float2 uv0: TEXCOORD0;
            };
            
            vertOut vert (appdata v) 
            {
                vertOut o;
                o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                o.uv0.xy = v.texcoord;
                o.uv0 = TRANSFORM_TEX(v.texcoord, _MainTex);                

                return o;
            }
            
            fixed4 frag (vertOut i) : COLOR 
            {
            	fixed xScrollValue = _ScrollXSpeed * _Time;
                
                float2 uv = i.uv0;
                uv = -1.0 + 2.0*uv;
                uv.y += (0.01 * sin(6.0*uv.x + 1.5+  _Time.y) * cos(16.0*uv.x - _Time.y) );           
                uv.x += xScrollValue;
          
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }    
    FallBack "Diffuse"
}