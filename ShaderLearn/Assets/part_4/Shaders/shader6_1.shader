Shader "custom/Shader6_1"
{
	Properties
	{
		
 
        _Tint ("Tint", Color) = (1, 1, 1, 1)
 
        _MainTex ("Albedo", 2D) = "white" {}
 
        [NoScaleOffset] _NormalMap ("Normals", 2D) = "bump" {}
 
        _BumpScale ("Bump Scale", Float) = 1
 
        [Gamma] _Metallic ("Metallic", Range(0, 1)) = 0
 
        _Smoothness ("Smoothness", Range(0, 1)) = 0.1
 
        _DetailTex ("Detail Texture", 2D) = "gray" {}
	}
	SubShader
	{
		Pass
		{
			Tags {
 
			    "LightMode" = "ForwardBase"
 
			}

			CGPROGRAM
			 
			#pragma target 3.0
			 
			 #pragma multi_compile VERTEXLIGHT_ON

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			
			//#define POINT
			#define FORWARD_BASE_PASS

			#include "CustomLighting.cginc"
			 
			ENDCG
		}
		Pass {
		    Tags {
		        "LightMode" = "ForwardAdd"
		    }
			Blend One One
			ZWrite Off

		    CGPROGRAM
 
		    #pragma target 3.0
 
			//#pragma multi_compile DIRECTIONAL POINT SPOT DIRECTIONAL_COOKIE

		    #pragma vertex MyVertexProgram
		    #pragma fragment MyFragmentProgram

			//#define POINT

		    #include "CustomLighting.cginc"
 
		    ENDCG
		}

	}
}
