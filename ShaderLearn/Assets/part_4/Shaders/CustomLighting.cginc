
#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

			// make fog work
			//#pragma multi_compile_fog
			
			//#include "UnityCG.cginc"
			#include "UnityStandardBRDF.cginc"
			//#include "UnityStandardUtils.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"

			struct VertexData {
			 
			    float4 position : POSITION;
			 
			    float3 normal : NORMAL;
			 
			    float2 uv : TEXCOORD0;
			 
			};
			struct Interpolators {
				float4 position : SV_POSITION;
				float4  uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				#if defined(VERTEXLIGHT_ON)
 
				    float3 vertexLightColor : TEXCOORD3;
 
				#endif
			};

			sampler2D _MainTex,_NormalMap,_DetailTex;
			float4 _MainTex_ST,_Tint,_SpecularTint,_DetailTex_ST;
			//sampler2D _Texture1, _Texture2, _Texture3, _Texture4;
			 float _Smoothness,_Metallic,_BumpScale; 
			//float4 _MainTex_ST;
			
			//void ComputeVertexLightColor (inout Interpolators i) {
			//	#if defined(VERTEXLIGHT_ON)
 
			//	    i.vertexLightColor = unity_LightColor[0].rgb;
 
			//	#endif			 
			//}

			//void ComputeVertexLightColor (VertexData v,inout Interpolators i) {
			//	#if defined(VERTEXLIGHT_ON)
 
			//	    i.vertexLightColor = unity_LightColor[0];
 
			//	    float3 lightPos = float3(
 
			//	        unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x
 
			//	    );
 
			//	    float3 lightVec = lightPos - i.worldPos;
 
			//	    float3 lightDir = normalize(lightVec);
 
			//	    float ndotl = DotClamped(i.normal, lightDir);
 
			//	    //float attenuation = 1 / (1 + dot(lightDir, lightDir));
			//		float attenuation = 1 /(1 + dot(lightDir, lightDir) * unity_4LightAtten0.x);
 
			//	    i.vertexLightColor = unity_LightColor[0].rgb * ndotl * attenuation;
 
			//	#endif 
			//}

			void ComputeVertexLightColor (VertexData v, inout Interpolators i) {
			 
			    #if defined(VERTEXLIGHT_ON)
			 
			        i.vertexLightColor = Shade4PointLights(
			 
			            unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
			 
			            unity_LightColor[0].rgb, unity_LightColor[1].rgb,
			 
			            unity_LightColor[2].rgb, unity_LightColor[3].rgb,
			 
			            unity_4LightAtten0, i.worldPos, i.normal
			 
			        );
			 
			    #endif
			 
			}

			Interpolators MyVertexProgram (VertexData v)
			{
				Interpolators i;
				//i.position = mul(UNITY_MATRIX_MVP, v.position);
				i.position = UnityObjectToClipPos(v.position);
				i.worldPos = mul(unity_ObjectToWorld, v.position);

				i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
				//i.normal = normalize( mul(unity_ObjectToWorld, float4(v.normal, 0)));
				//i.normal = normalize( mul(transpose((float3x3)unity_WorldToObject), v.normal));
				i.normal = UnityObjectToWorldNormal(v.normal);

				 ComputeVertexLightColor(v,i);
				return i;
			}

				//UnityLight CreateLight (Interpolators i) {
				//    UnityLight light;
				//    light.dir = _WorldSpaceLightPos0.xyz;
				//    light.color = _LightColor0.rgb;
				//    light.ndotl = DotClamped(i.normal, light.dir);
				//    return light;
				//}
				UnityLight CreateLight (Interpolators i) {
						UnityLight light;
 
						#if defined(POINT) || defined(POINT_COOKIE) || defined(SPOT)
 
						    light.dir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
 
						#else
 
						    light.dir = _WorldSpaceLightPos0.xyz;
 
						#endif
 
						float3 lightVec = _WorldSpaceLightPos0.xyz - i.worldPos;
 
						//float attenuation = 1 / (1+dot(lightVec, lightVec));
						UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);
						light.color = _LightColor0.rgb * attenuation;
 
						light.ndotl = DotClamped(i.normal, light.dir);
 
						return light;
				}
				UnityIndirect CreateIndirectLight (Interpolators i) {
				 
				    UnityIndirect indirectLight;
				 
				    indirectLight.diffuse = 0;
				 
				    indirectLight.specular = 0;
				 
				  
				 
				    #if defined(VERTEXLIGHT_ON)
				 
				        indirectLight.diffuse = i.vertexLightColor;
				 
				    #endif

					#if defined(FORWARD_BASE_PASS)
						indirectLight.diffuse += max(0, ShadeSH9(float4(i.normal, 1)));
					#endif
				 
				    return indirectLight;
				 
				}

			void InitializeFragmentNormal(inout Interpolators i) {
			 
				//i.normal = tex2D(_NormalMap, i.uv).rgb;
				//i.normal = tex2D(_NormalMap, i.uv).xyz * 2 - 1;

				//i.normal.xy = tex2D(_NormalMap, i.uv).wy * 2 - 1;
				//i.normal.xy *= _BumpScale;
				//i.normal.z = sqrt(1 - dot(i.normal.xy, i.normal.xy));

				i.normal = UnpackScaleNormal(tex2D(_NormalMap, i.uv.xy), _BumpScale);

				i.normal = i.normal.xzy;

				i.normal = normalize(i.normal);
			 
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
			fixed4 MyFragmentProgram (Interpolators i) : SV_Target
			{
				//i.normal = normalize(i.normal);
				InitializeFragmentNormal(i);
 
				float3 lightDir = _WorldSpaceLightPos0.xyz;
 
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
 
 
 
				float3 lightColor = _LightColor0.rgb;
 
				float3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Tint.rgb;
				albedo *= tex2D(_DetailTex, i.uv.zw) * unity_ColorSpaceDouble;
 
 
				float3 specularTint;
 
				float oneMinusReflectivity;
 
				albedo = DiffuseAndSpecularFromMetallic(
 
				    albedo, _Metallic, specularTint, oneMinusReflectivity
 
				);
 
				
 
				//UnityLight light;
 
				//light.color = lightColor;
 
				//light.dir = lightDir;
 
				//light.ndotl = DotClamped(i.normal, lightDir);
 
				UnityIndirect indirectLight;
 
				indirectLight.diffuse = 0;
 
				indirectLight.specular = 0;
 
 
    // float3 shColor = ShadeSH9(float4(i.normal, 1));
 
    //return float4(shColor, 1);

				return UNITY_BRDF_PBS(
 
				    albedo, specularTint,
 
				    oneMinusReflectivity, _Smoothness,
 
				    i.normal, viewDir,
 
				    CreateLight(i), CreateIndirectLight(i)
 
				);
			}



#endif
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
/*
#ifdef POINT
 
uniform sampler2D _LightTexture0;
 
uniform unityShadowCoord4x4 unity_WorldToLight;
 
#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) \
 
    unityShadowCoord3 lightCoord = \
 
        mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)).xyz; \
 
    fixed destName = \
 
        (tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr). \
 
        UNITY_ATTEN_CHANNEL * SHADOW_ATTENUATION(input));
 
#endif
*/
/*
#ifdef SPOT
 
uniform sampler2D _LightTexture0;
 
uniform unityShadowCoord4x4 unity_WorldToLight;
 
uniform sampler2D _LightTextureB0;
 
inline fixed UnitySpotCookie(unityShadowCoord4 LightCoord) {
 
return tex2D(_LightTexture0, LightCoord.xy / LightCoord.w + 0.5).w;
 
}
 
inline fixed UnitySpotAttenuate(unityShadowCoord3 LightCoord) {
 
return tex2D(_LightTextureB0, dot(LightCoord, LightCoord).xx). \
 
    UNITY_ATTEN_CHANNEL;
 
}
 
#define UNITY_LIGHT_ATTENUATION(destName, input, worldPos) \
 
unityShadowCoord4 lightCoord = \
 
    mul(unity_WorldToLight, unityShadowCoord4(worldPos, 1)); \
 
fixed destName = (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * \
 
    UnitySpotAttenuate(lightCoord.xyz) * SHADOW_ATTENUATION(input);
 
#endif
*/

/*
half3 UnpackScaleNormal (half4 packednormal, half bumpScale) {
 
    #if defined(UNITY_NO_DXT5nm)
 
        return packednormal.xyz * 2 - 1;
 
    #else
 
        half3 normal;
 
        normal.xy = (packednormal.wy * 2 - 1);
 
        #if (SHADER_TARGET >= 30)
 
            // SM2.0: instruction count limitation
 
            // SM2.0: normal scaler is not supported
 
            normal.xy *= bumpScale;
 
        #endif
 
        normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
 
        return normal;
 
    #endif
 
}
*/