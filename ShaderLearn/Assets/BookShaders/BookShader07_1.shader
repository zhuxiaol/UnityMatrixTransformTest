// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Book/Shader07_1"
{
//法线贴图
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint",Color)=(1,1,1,1)
		_BumpMap("Normal Map",2D) = "white" {}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
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
			#include "Lighting.cginc"


			float4 _Color,_Specular;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			float _BumpScale,_Gloss;

			float4 _MainTex_ST;
			float4 _BumpMap_ST;



			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float4 tangent:TANGENT;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy*_BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 binormal = cross(v.normal,v.tangent.xyz)*v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);

				float3 lightDir = _WorldSpaceLightPos0.xyz;
				lightDir = mul((float3x3)unity_WorldToObject,lightDir);
				o.lightDir = mul(rotation,lightDir);
				o.lightDir = normalize(o.lightDir);

				float3 viewDir = _WorldSpaceCameraPos.xyz - mul((float3x3)unity_ObjectToWorld,v.vertex);
				viewDir = mul((float3x3)unity_WorldToObject,viewDir);
				o.viewDir = mul(rotation,viewDir);
				o.viewDir = normalize(o.viewDir);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentNormal; 
				fixed4 packedNormal  = tex2D(_BumpMap,i.uv.zw);
				packedNormal = packedNormal*2 -1;
				tangentNormal.xy=packedNormal.xy* _BumpScale;
				tangentNormal.z = sqrt(1.0-max(0,dot(tangentNormal.xy,tangentNormal.xy)));
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb*_Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
				fixed3 diffuse = _LightColor0.rgb*albedo*max(0,dot(tangentNormal,i.lightDir));
				fixed3 halfDir = normalize(i.lightDir+i.viewDir);
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
				

				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
	}
}
