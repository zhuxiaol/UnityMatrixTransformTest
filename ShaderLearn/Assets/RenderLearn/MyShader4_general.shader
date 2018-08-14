// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MyShader4_general" {
Properties {
    _Tint ("Tint", Color) = (1, 1, 1, 1)
	_MainTex("Texture",2D)="white"{}
	[Gamma]_Metallic ("Metallic", Range(0, 1)) = 0
	_Smoothness("Smoothness",Range(0,1))=0.5
	_SpecularTint("Specular",Color)=(0.5,0.5,0.5)
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
	#include "UnityPBSLighting.cginc"

	float4 _Tint;
	float4 _MainTex_ST,_DetailTex_ST;
	sampler2D _MainTex;
	float _Smoothness;
	float4 _SpecularTint;
	float _Metallic;
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
		float3 worldPos : TEXCOORD5;
	};


	FragData vert(VertData v)
	{
		FragData o;
		o.position=UnityObjectToClipPos(v.position);
		o.worldPos = mul(unity_ObjectToWorld, v.position);

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
		float3 viewDir=normalize(_WorldSpaceCameraPos-i.worldPos);
		float3 halfVector = normalize(lightDir+viewDir);
		float3 albedo=tex2D(_MainTex,i.uv).rgb*_Tint.rgb;

		float3 specularTint;
		float oneMinusReflectivity;
		albedo = DiffuseAndSpecularFromMetallic(
			albedo, _Metallic, specularTint, oneMinusReflectivity
		);

				UnityLight light;
				light.color = lightColor;
				light.dir = lightDir;
				light.ndotl = DotClamped(i.normal, lightDir);

				UnityIndirect indirectLight;
				indirectLight.diffuse = 0;
				indirectLight.specular = 0;

				return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, _Smoothness,
					i.normal, viewDir,
					light, indirectLight
				);
	}
	
	ENDCG
	
	}


}

}
