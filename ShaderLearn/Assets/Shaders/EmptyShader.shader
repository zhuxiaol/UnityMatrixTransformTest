// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Tutorial/Display Normals" {
SubShader {
    Pass {

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

struct v2f {
    float4 pos : SV_POSITION;
    float3 color : COLOR0;
};

v2f vert (appdata_base v)
{
    v2f o;
    o.pos = UnityObjectToClipPos (v.vertex);
    o.color = v.normal * 0.5 + 0.5;
    return o;
}

half4 frag (v2f i) : COLOR
{
    return half4 (i.color, 1);
}
ENDCG

    }
}
Fallback "VertexLit"
} 


/*
Shader "Custom/My First Shader" 
{
	SubShader
	{
		CGPROGRAM
		 
		#pragma vertex MyVertexProgram
		#pragma fragment MyFragmentProgram
		 
		// SV表示系统值，而POSITION表示最终顶点位置。
		float4 MyVertexProgram ():SV_POSITION 
		{
		 return 0;
		}

		//我们必须指出最终的颜色应该写在哪里。 我们使用SV_TARGET，它是默认的着色器目标，也就是帧缓冲区，其中包含着我们正在生成的图像。
		//顶点程序的输出会被用作片段程序的输入
		float4 MyFragmentProgram (float4 position:SV_POSITION):SV_TARGET 
		{
		 return 0;
		}
		 
		ENDCG
	}
	FallBack off
}

*/


