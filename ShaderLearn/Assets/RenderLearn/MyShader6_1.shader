// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Bump Map
//by：puppet_master
//2016.12.13
//Bump Map HeightMap
Shader "Custom/MyShader6_1"
{
	//属性
	Properties{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_MainTex("Base 2D", 2D) = "white"{}
		_BumpMap("Bump Map", 2D) = "black"{}
		_BumpScale ("Bump Scale", Range(0.1, 30.0)) = 10.0
	}
 
	//子着色器	
	SubShader
	{
		Pass
		{
			//定义Tags
			Tags{ "RenderType" = "Opaque" }
 
			CGPROGRAM
			//引入头文件
			#include "Lighting.cginc"
			//定义Properties中的变量
			fixed4 _Diffuse;
			sampler2D _MainTex;
			//使用了TRANSFROM_TEX宏就需要定义XXX_ST
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_TexelSize;
			float _BumpScale;
 
			//定义结构体：应用阶段到vertex shader阶段的数据
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			//定义结构体：vertex shader阶段输出的内容
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				//转化纹理坐标
				float2 uv : TEXCOORD1;
			};
 
			//定义顶点shader
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//把法线转化到世界空间
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				//通过TRANSFORM_TEX宏转化纹理坐标，主要处理了Offset和Tiling的改变,默认时等同于o.uv = v.texcoord.xy;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
 
			//定义片元shader
			fixed4 frag(v2f i) : SV_Target
			{
				//unity自身的diffuse也是带了环境光，这里我们也增加一下环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _Diffuse.xyz;
				//归一化法线，即使在vert归一化也不行，从vert到frag阶段有差值处理，传入的法线方向并不是vertex shader直接传出的
				fixed3 worldNormal1 = normalize(i.worldNormal);
				//采样bump贴图,需要知道该点的斜率，xy方向分别求，所以对于一个点需要采样四次
				fixed bumpValueU = tex2D(_BumpMap, i.uv + fixed2(-1.0 * _BumpMap_TexelSize.x, 0)).r - tex2D(_BumpMap, i.uv + fixed2(1.0 * _BumpMap_TexelSize.x, 0)).r;
				fixed bumpValueV = tex2D(_BumpMap, i.uv + fixed2(0, -1.0 * _BumpMap_TexelSize.y)).r - tex2D(_BumpMap, i.uv + fixed2(0, 1.0 * _BumpMap_TexelSize.y)).r;
				//用上面的斜率来修改法线的偏移值
				fixed3 worldNormal = fixed3(worldNormal1.x * bumpValueU * _BumpScale, worldNormal1.y * bumpValueV * _BumpScale, worldNormal1.z);
 
				//把光照方向归一化
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//根据半兰伯特模型计算像素的光照信息
				fixed3 lambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				//最终输出颜色为lambert光强*材质diffuse颜色*光颜色
				fixed3 diffuse = lambert * _Diffuse.xyz * _LightColor0.xyz + ambient;
				//进行纹理采样
				fixed4 color = tex2D(_MainTex, i.uv);
				return fixed4(diffuse * color.rgb, 1.0);
			}
 
			//使用vert函数和frag函数
			#pragma vertex vert
			#pragma fragment frag	
 
			ENDCG
		}
 
	}
		//前面的Shader失效的话，使用默认的Diffuse
		FallBack "Diffuse"
}
