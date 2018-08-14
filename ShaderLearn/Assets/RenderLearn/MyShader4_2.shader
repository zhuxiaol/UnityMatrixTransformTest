// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"Custom/MyShader4_2"
{
	Properties{
		_Tint("Tint",Color)=(1,1,1,1)
		_MainTex("Texture",2D)="white"{}

	}


	SubShader{
		Pass{
			Tags{
				"LightMode"="ForwardBase"
			}

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				sampler2D _MainTex;
				float4 _Tint;
				float4 _MainTex_ST;

				struct VertData
				{
					float4 position :POSITION;
					float2 uv:TEXCOORD0;
					float3 normal:NORMAL;
				};

				struct FragData
				{
					float4 position:SV_POSITION;
					float2 uv:TEXCOORD0;
					float3 normal:TEXCOORD1;

				};

				FragData vert(VertData i)
				{
					FragData o;
					o.position=UnityObjectToClipPos(i.position);
					o.uv = i.uv*_MainTex_ST.xy+_MainTex_ST.zw;
					o.normal=mul(unity_ObjectToWorld,float4( i.normal,0));
					o.normal= normalize(o.normal);
					return o;
				}

				float4 frag(FragData i):SV_TARGET
				{
					float3 lightDir=_WorldSpaceLightPos0.xyz;
					float3 lightColor = _LightColor0.rgb;

					float3 diffuse=lightColor*DotClamped(lightDir,i.normal);
					float4 albedo = tex2D(_MainTex,i.uv)*_Tint;

					float3 color=diffuse* albedo.rgb;
					return float4(color,albedo.a);
				}


			ENDCG
		}

	}
}