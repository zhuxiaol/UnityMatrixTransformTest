Shader "custom/Shader4_1"
{
	Properties
	{
		
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Splat Map", 2D) = "white" {}
		_SpecularTint ("Specular", Color) = (0.5, 0.5, 0.5)
		[Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Pass
		{
			Tags {
 
			    "LightMode" = "ForwardBase"
 
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			//#pragma multi_compile_fog
			
			//#include "UnityCG.cginc"
			#include "UnityStandardBRDF.cginc"
			//#include "UnityStandardUtils.cginc"
			#include "UnityPBSLighting.cginc"
			struct VertexData {
			 
			    float4 position : POSITION;
			 
			    float3 normal : NORMAL;
			 
			    float2 uv : TEXCOORD0;
			 
			};
			struct Interpolators {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST,_Tint,_SpecularTint;
			//sampler2D _Texture1, _Texture2, _Texture3, _Texture4;
			 float _Smoothness,_Metallic;
			//float4 _MainTex_ST;
			
			Interpolators vert (VertexData v)
			{
				Interpolators i;
				//i.position = mul(UNITY_MATRIX_MVP, v.position);
				i.position = UnityObjectToClipPos(v.position);
				i.worldPos = mul(unity_ObjectToWorld, v.position);

				i.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//i.normal = normalize( mul(unity_ObjectToWorld, float4(v.normal, 0)));
				//i.normal = normalize( mul(transpose((float3x3)unity_WorldToObject), v.normal));
				i.normal = UnityObjectToWorldNormal(v.normal);
				return i;
			}
			/*
			//普通漫反射光照模型，兰伯特
			fixed4 frag (Interpolators i) : SV_Target
			{
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				//return float4(i.normal * 0.5 + 0.5, 1);
				//return dot(float3(0,1,0),i.normal);
				//return max(0, dot(float3(0, 1, 0), i.normal));
				//return saturate(dot(float3(0, 1, 0), i.normal));
				//return DotClamped(lightDir, i.normal);

				float3 lightColor = _LightColor0.rgb;
				//float3 diffuse = lightColor*DotClamped(lightDir,i.normal);

				float3 albedo = tex2D(_MainTex,i.uv).rgb*_Tint.rgb;
				float3 diffuse = albedo*lightColor*DotClamped(lightDir,i.normal);


				return float4(diffuse,1);
			}
			*/

			/*
			//镜面高光 Blinn
			fixed4 frag (Interpolators i) : SV_Target
			{
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;

				float3 reflectionDir = reflect(-lightDir, i.normal);

				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				float3 lightColor = _LightColor0.rgb;
				float3 albedo = tex2D(_MainTex,i.uv).rgb*_Tint.rgb;

				float3 diffuse = albedo*lightColor*DotClamped(lightDir,i.normal);


				//return float4(diffuse,1);
				//return float4(reflectionDir * 0.5 + 0.5, 1);
				//return DotClamped(viewDir, reflectionDir);
				return pow( DotClamped(viewDir, reflectionDir),_Smoothness*100);
			}
			*/

			/*
			//镜面高光 Blinn-Phong
			fixed4 frag (Interpolators i) : SV_Target
			{
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

				float3 halfVector = normalize(lightDir + viewDir);

				
				float3 lightColor = _LightColor0.rgb;
				float3 albedo = tex2D(_MainTex,i.uv).rgb*_Tint.rgb;

                //float3 specularTint = albedo * _Metallic;
                //float oneMinusReflectivity = 1 - _Metallic;
				float3 specularTint ;
				float oneMinusReflectivity;
				//albedo *= oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specularTint, oneMinusReflectivity);


				//float oneMinusReflectivity;
				//albedo =EnergyConservationBetweenDiffuseAndSpecular(albedo, _SpecularTint.rgb, oneMinusReflectivity);

				//albedo *= 1 - _SpecularTint.rgb;

				float3 diffuse = albedo*lightColor*DotClamped(lightDir,i.normal);


				//return float4(diffuse,1);
				//return float4(reflectionDir * 0.5 + 0.5, 1);
				//return DotClamped(viewDir, reflectionDir);
				//return pow( DotClamped(halfVector, i.normal),_Smoothness*100);
				float3 specular= _SpecularTint.rgb * lightColor* pow( DotClamped(halfVector, i.normal),_Smoothness*100);
				//return float4( specular,1);
				return float4(diffuse + specular, 1);
			}
			*/

			//光照模型 PBS
			fixed4 frag (Interpolators i) : SV_Target
			{
				i.normal = normalize(i.normal);
 
				float3 lightDir = _WorldSpaceLightPos0.xyz;
 
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
 
 
 
				float3 lightColor = _LightColor0.rgb;
 
				float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
 
 
 
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


/*
inline half DotClamped (half3 a, half3 b) {
 
    #if (SHADER_TARGET < 30 || defined(SHADER_API_PS3))
 
        return saturate(dot(a, b));
 
    #else
 
        return max(0.0h, dot(a, b));
 
    #endif
 
}
*/

/*

half SpecularStrength(half3 specular) {
 
    #if (SHADER_TARGET < 30)
 
        ＼＼ SM2.0: instruction count limitation
 
        ＼＼ SM2.0: simplified SpecularStrength
 
        ＼＼ Red channel - because most metals are either monochrome
 
        ＼＼or with redish/yellowish tint
 
        return specular.r;
 
    #else
 
        return max(max(specular.r, specular.g), specular.b);
 
    #endif
 
}
 
  
 
＼＼Diffuse/Spec Energy conservation
 
inline half3 EnergyConservationBetweenDiffuseAndSpecular (
 
    half3 albedo, half3 specColor, out half oneMinusReflectivity
 
) {
 
    oneMinusReflectivity = 1 - SpecularStrength(specColor);
 
    #if !UNITY_CONSERVE_ENERGY
 
        return albedo;
 
    #elif UNITY_CONSERVE_ENERGY_MONOCHROME
 
        return albedo * oneMinusReflectivity;
 
    #else
 
        return albedo * (half3(1, 1, 1) - specColor);
 
    #endif
 
}
*/