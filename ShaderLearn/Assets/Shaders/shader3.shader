Shader "custom/Shader3"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_DetailTex ("Detail Texture", 2D) = "gray" {}
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct Interpolators {
			    float4 position : SV_POSITION;
			    float2 uv : TEXCOORD0;
			    float2 uvDetail : TEXCOORD1;
			};
			//struct v2f
			//{
			//	float2 uv : TEXCOORD0;
			//	UNITY_FOG_COORDS(1)
			//	float4 vertex : SV_POSITION;
			//};

			sampler2D _MainTex, _DetailTex;
			float4 _MainTex_ST, _DetailTex_ST;
			float4 _Tint;
			//float4 _MainTex_ST;
			
			Interpolators vert (appdata v)
			{
				Interpolators o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
				//o.uv = v.uv;
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (Interpolators i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv)*_Tint;
				col *= tex2D(_DetailTex, i.uvDetail*1)*unity_ColorSpaceDouble;
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
