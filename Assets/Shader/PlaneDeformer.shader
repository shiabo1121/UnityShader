Shader "Custom/PlaneDeformer" 
{
	Properties 
	{
		_MainTint("Diffuse Tint", Color) = (1.0,1.0,1.0,1.0)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _ScrollXSpeed("X Scroll Speed", Range(0.0, 10.0)) = 2.0
        _ScrollYSpeed("Y Scroll Speed", Range(0.0, 10.0)) = 2.0
        _PhaseOffset ("PhaseOffset", Range(0.0, 1.0)) = 0.0
        _Speed ("Speed", Range(0.0,10.0)) = 1.0
        _Depth ("Depth", Range(0.0,1.0)) = 0.2
        _Smoothing ("Smoothing", Range(0.0, 1.0)) = 0.0
        _XDrift ("X Drift", Range(0.0,3.0)) = 0.05
        _ZDrift ("Z Drift", Range(0.0,3.0)) = 0.12
        _Scale ("Scale", Range(0.1,10.0)) = 1.0
	}
	SubShader 
	{
	
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Tags 
		{
			"LightMode" = "Always" 
			"Queue" = "Transparent-2"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
        #pragma exclude_renderers d3d11_9x d3d11 xbox360 ps3 flash

		sampler2D _MainTex;

		fixed4 _MainTint;
		float _ScrollXSpeed;
		float _ScrollYSpeed;		
		float _PhaseOffset;
		float _Speed;
		float _Depth;
		float _Smoothing;
		float _XDrift;
		float _ZDrift;
		float _Scale;
		
		struct Input {
			float2 uv_MainTex;
		};
		
		void vert( inout appdata_full v, out Input o )
		{
            UNITY_INITIALIZE_OUTPUT(Input,o);  
			float3 v0 = mul( _Object2World, v.vertex ).xyz;			
			
			float3 v1 = v0 + float3( 0.05, 0, 0 ); 
			float3 v2 = v0 + float3( 0, 0, 0.05 );
			
			float phase = _PhaseOffset * (3.14 * 2);
			float phase2 = _PhaseOffset * (3.14 * 1.123);
			float speed = _Time.y * _Speed;
			float speed2 = _Time.y * (_Speed * 0.33 );
			float _Depth2 = _Depth * 1.0;
			float v0alt = v0.x * _XDrift + v0.z * _ZDrift;
			float v1alt = v1.x * _XDrift + v1.z * _ZDrift;
			float v2alt = v2.x * _XDrift + v2.z * _ZDrift;
			
			v0.y += sin( phase  + speed  + ( v0.x  * _Scale ) ) * _Depth;
			v0.y += sin( phase2 + speed2 + ( v0alt * _Scale ) ) * _Depth2; 
			
			v1.y += sin( phase  + speed  + ( v1.x  * _Scale ) ) * _Depth;
			v1.y += sin( phase2 + speed2 + ( v1alt * _Scale ) ) * _Depth2;
			
			v2.y += sin( phase  + speed  + ( v2.x  * _Scale ) ) * _Depth;
			v2.y += sin( phase2 + speed2 + ( v2alt * _Scale ) ) * _Depth2;
			
			v1.y -= (v1.y - v0.y) * _Smoothing;
			v2.y -= (v2.y - v0.y) * _Smoothing;
			
			float3 vna = cross( v2-v0, v1-v0 );
			float3x3 temp =  (float3x3)_Object2World;
			float3 vn = mul(temp, vna );
			
			v.normal = normalize( vn );
			
			v.vertex.xyz = mul( (float3x3)_Object2World, v0 );
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			float2 scrolledUV = IN.uv_MainTex;

			float xScrollValue = _ScrollXSpeed * _Time;
			float yScrollValue = _ScrollYSpeed * _Time;
			scrolledUV += float2(xScrollValue, yScrollValue);
			half4 c = tex2D (_MainTex, scrolledUV);
			o.Albedo = c.rgb * _MainTint;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
