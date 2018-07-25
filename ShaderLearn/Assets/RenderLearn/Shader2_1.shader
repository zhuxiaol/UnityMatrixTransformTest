// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Render Learn/Learn2"
{
	Properties {
	    _Tint ("Tint", Color) = (1, 1, 1, 1)
	    _MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
           struct Interpolators {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                //float3 localPosition : TEXCOORD0;
            };			
			
			Interpolators vert(a2v v) 
			{
				//声明输出结构
				Interpolators o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv=v.texcoord* _MainTex_ST.xy+ _MainTex_ST.zw;
				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex)
				return o;
			}
			
			fixed4 frag(Interpolators i) : SV_Target
			{
				return tex2D(_MainTex, i.uv)* _Tint;
			}
			ENDCG
		}
	}
}

//// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Shader "Render Learn/Learn2"
//{
//	Properties {
//	    _Tint ("Tint", Color) = (1, 1, 1, 1)
//	    _MainTex ("Texture", 2D) = "white" {}
//	}

//	SubShader
//	{


//        CGPROGRAM
//        #pragma vertex vert
//        #pragma fragment frag
//		#include "UnityCG.cginc"

//		float4 _Tint;
//		sampler2D _MainTex;
//           struct Interpolators {
//                float4 position : SV_POSITION;
//                float2 uv : TEXCOORD0;
//                //float3 localPosition : TEXCOORD0;
//            };
//		Interpolators vert (appdata_full v) {
//		    Interpolators i;
//		    //i.localPosition = v.position.xyz;
//		    i.position = UnityObjectToClipPos(v.vertex);
//		    return i;
//		}
//		float4 frag (Interpolators i) : SV_TARGET {
//			return tex2D(_MainTex, i.uv);
//		}

//		ENDCG
//	}
//	FallBack off

//}