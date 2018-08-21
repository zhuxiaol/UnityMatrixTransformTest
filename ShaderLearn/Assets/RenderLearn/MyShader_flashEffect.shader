// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UICustom/FlashEffect" {
	Properties {
		[PerRendererData] _MainTex("Sprite Texture",2D) = "white"{}
		[NoScaleOffset]_FlowTex("Flash Texture",2D) = "white"{}
		_ScrollXSpeed("X Speed",Range(0,10)) =2
		_ScrollYSpeed("Y Speed",Range(0,10)) =0
		_ScrollDirection("Direction",Range(-1,1)) = -1
		_FlowColor("Flash Color",Color) = (1,1,1,1)


		_Color("Tint", Color) = (1,1,1,1)

        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255

        _ColorMask("Color Mask", Float) = 15
	}


	SubShader {

			Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
                "PreviewType" = "Plane"
                "CanUseSpriteAtlas" = "True"
            }

            Stencil
            {
                Ref[_Stencil]
                Comp[_StencilComp]
                Pass[_StencilOp]
                ReadMask[_StencilReadMask]
                WriteMask[_StencilWriteMask]
            }

            Cull Off
            Lighting Off
            ZWrite Off
            ZTest[unity_GUIZTestMode]
            Fog { Mode Off }
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask[_ColorMask]


		Pass{

		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			sampler2D _FlowTex;
			fixed _ScrollXSpeed;
			fixed _ScrollYSpeed;
			fixed _ScrollDirection;
			float4 _FlowColor;
			float4 _MainTex_ST;



			struct VertData
			{
				float4 position:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct FragData
			{
				float4 position:POSITION;
				float2 uv:TEXCOORD0;
				float3 worldPosition:TEXCOORD4;				
			};


			FragData vert(VertData v)
			{
				FragData o;
				o.position = UnityObjectToClipPos(v.position);
				o.worldPosition=mul(unity_ObjectToWorld,v.position);
				o.uv = v.uv*_MainTex_ST.xy+_MainTex_ST.zw;

				return o;
			}

			float4 frag(FragData o) :SV_TARGET
			{
				fixed2 scrollUV=o.uv;
				// _Time.y等同于Time.timeSinceLevelLoad
				fixed xScrollValue=_ScrollXSpeed*_Time.y;
				fixed yScrollValue=_ScrollYSpeed*_Time.y;
				
				scrollUV+=fixed2(xScrollValue,yScrollValue)*_ScrollDirection;

				//颜色混合
				//float4 c= tex2D(_FlowTex,scrollUV);
				float4 c= tex2D(_FlowTex,scrollUV);
				float4 d = tex2D(_MainTex,o.uv);
				float3 albedo = c.rgb*_FlowColor.rgb+d.rgb;

				return float4(albedo,d.a);
			}



		ENDCG
		}
	}
}
