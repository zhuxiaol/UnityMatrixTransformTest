// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MyShader4" {
Properties {
    _Tint ("Tint", Color) = (1, 1, 1, 1)
	_MainTex("Texture",2D)="white"{}
	//_DetailTex("Detail Texture",2D)="gray"{}
}

SubShader{
	Pass{
	Tags{
	
		"LightMode" = "ForwardBase"
	
	}

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

	#include "UnityCG.cginc"
	#include "Lighting.cginc"

	float4 _Tint;
	float4 _MainTex_ST,_DetailTex_ST;
	sampler2D _MainTex;
	//sampler2D _DetailTex

	struct VertData{
		float4 position:POSITION;
		float3 normal:NORMAL;
		float4 tangent:TANGENT;
		float2 uv:TEXCOORD0;
		
	};
	struct FragData{
		float4 position:SV_POSITION;
		float2 uv:TEXCOORD0;
		//float2 uvDetail:TEXCOORD1;
		float3 normal:TEXCOORD1;
		//float4 tangent:TEXCOORD2;
		//float3 binormal:TEXCOORD3;
		float3 localPosition:TEXCOORD4;
	};


	FragData vert(VertData v)
	{
		FragData o;
		o.position=UnityObjectToClipPos(v.position);
		//o.uv=TRANSFORM_TEX(v.uv,_MainTex);
		o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
		//o.normal=mul((float3x3)unity_ObjectToWorld, v.normal); //法线方向n
		//i.normal = mul(transpose((float3x3)unity_WorldToObject),v.normal);
		o.normal = UnityObjectToWorldNormal(v.normal);
		//o.uvDetail=v.uv*_DetailTex_ST.xy + _DetailTex_ST.zw;
		return o;
	}
	float4 frag(FragData i):SV_TARGET
	{
		i.normal = normalize(i.normal);
		float3 lightColor= _LightColor0.rgb;
		float3 lightDir=  _WorldSpaceLightPos0.xyz;
		float4 albedo=tex2D(_MainTex,i.uv)*_Tint;
		float3 diffuse = lightColor*DotClamped(lightDir,i.normal);
		//float3 diffuse = lightColor*saturate(dot(lightDir,i.normal));
		//float3 diffuse = lightColor*max(0,dot(lightDir,i.normal));
		float3 color =diffuse*albedo.rgb;
		//color*=tex2D(_DetailTex,i.uvDetail)*2;
		return float4( color,1);
	}
	
	ENDCG
	
	}


}

}
