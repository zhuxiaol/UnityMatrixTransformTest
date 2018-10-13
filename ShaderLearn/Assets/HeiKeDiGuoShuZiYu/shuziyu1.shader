//【经验分享】黑客帝国数字矩阵特效做法
Shader "custom/Shuziyu1"
{
    Properties
    {
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _RandomTex ("Random Tex", 2D) = "white" {}
        _FlowingTex ("Flowing Tex", 2D) = "white" {}
        _NumberTex ("Number Tex", 2D) = "white" {}
        _CellSize ("格子大小,只取XY", Vector) = (0.03, 0.04, 0.03, 0)
        _TexelSizes ("X:Random Tex宽度，Y:Flowing Tex宽度，Z:Number Tex数字个数（这些数值根据图片更改）", Vector) = (0.015625, 0.00390625, 10, 0)
        _Speed ("X:图片下落速度，Y:数字变化速度", Vector) = (1,5,0,0)
        _Intensity ("Global Intensity", Float) = 1
    }

    Subshader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "IgnoreProjector"="True"
        }
        Pass
        {
            Fog { Mode Off }
            Lighting Off
            Blend One One
            Cull Off
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            
            float4 _TintColor;
            sampler2D _RandomTex;
            sampler2D _FlowingTex;
            sampler2D _NumberTex;
            float4 _CellSize;
            float4 _TexelSizes;
            float4 _Speed;
            float _Intensity;
			float4 _RandomTex_TexelSize;
			float4 _FlowingTex_TexelSize;
			float4 _NumberTex_TexelSize;
            
            #define _RandomTexelSize (_TexelSizes.x)
            #define _FlowingTexelSize (_TexelSizes.y)
            #define _NumberCount (_TexelSizes.z)
            #define T (_Time.y)
            #define EPSILON (0.00876)

            struct appdata_v
            {
                float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float3 texc : TEXCOORD0;
				float2 uv : TEXCOORD1;
            };

            v2f vert (appdata_v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.texc = v.vertex.xyz;
				o.uv = v.texcoord;
                return o;
            }
            
            fixed4 frag1 (v2f i) : COLOR
            {

				float speed= _Time.y*_Speed.x*0.03;

				float2 speedUv= float2(0,speed);
				i.uv +=speedUv;
				float2 randomUv = float2( floor(i.uv.x*10)*0.1,floor(i.uv.y*10)*0.1);
				float2 flowUv=randomUv;
				randomUv+=speedUv*0.08;
				float random= tex2D(_RandomTex,randomUv).r;
				float off= round(random*10)*0.1;
				float2 tmpUv =float2(frac( i.uv.x*10)*0.1+off,i.uv.y*10);
				//tmpUv+=speedUv;
				float4 colorOfNumber= tex2Dlod(_NumberTex,float4(tmpUv,0,0));

				float intens = tex2D(_FlowingTex, flowUv).r;
                return colorOfNumber* pow(intens,3)*_TintColor;
            }
			
            fixed4 frag (v2f i) : COLOR
            {
                float3 cellc = i.texc.xyz / _CellSize + EPSILON;
                float speed = tex2D(_RandomTex, cellc.xz * _RandomTexelSize).g * 3 + 1;
                cellc.y += T*speed*_Speed.x;
                float intens = tex2D(_FlowingTex, cellc.xy * _FlowingTexelSize).r;
                
                float2 nc = cellc;
                nc.x += round(T*_Speed.y*speed);
                float number = round(tex2D(_RandomTex, nc * _RandomTexelSize).r * _NumberCount) / _NumberCount;
                
                float2 number_tex_base = float2(number, 0);
                float2 number_tex = number_tex_base + float2(frac(cellc.x/_NumberCount), frac(cellc.y));
                fixed4 ncolor = tex2Dlod(_NumberTex, float4(number_tex, 0, 0)).rgba;
                
                return ncolor * pow(intens,3) * _Intensity * _TintColor;
            }
            ENDCG
        }
    }
}