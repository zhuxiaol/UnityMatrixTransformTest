Shader "custom/Shader5_1"
{
	Properties
	{
		
		_Tint ("Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Splat Map", 2D) = "white" {}
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
