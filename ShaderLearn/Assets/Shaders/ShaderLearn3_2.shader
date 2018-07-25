// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Simple VertextFrament Shader"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 vert(float4 v: POSITION):SV_POSITION
			{
				return UnityObjectToClipPos(v);
				//return 0;
			}
			
			float4 frag():SV_Target
			{
				return fixed(1.0,1.0,1.0,1.0);
				//return 0
			}
			
			ENDCG
			
			
		}
		
		
	}
	FallBack off


}