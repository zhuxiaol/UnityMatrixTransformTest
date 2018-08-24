// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Bump Map
//by：puppet_master
//2016.12.13
//nomal map

Shader "Hidden/normal"
{
	//属性
	
	Properties{
		_MainTex("Texture", 2D) = "white"{}
		_NormalTex("Noraml Texture", 2D) = "white"{}
		
	}
	
 
	//子着色器	
	SubShader
	{
		Pass
		{
			//定义Tags
			//Tags{ "RenderType" = "Opaque" }
 
			CGPROGRAM
			//引入头文件
			//#include "Lighting.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
			//定义Properties中的变量
			
			sampler2D _MainTex;
			sampler2D _NormalTex;
			//使用了TRANSFROM_TEX宏就需要定义XXX_ST
			float4 _MainTex_ST;
 
			//定义结构体：应用阶段到vertex shader阶段的数据
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 uv : TEXCOORD0;
				float4 tangent:TANGENT;
			};
			//定义结构体：vertex shader阶段输出的内容
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 normalDir:TEXCOORD1;
				float3 tangentDir:TEXCOORD2;
				float3 bitangentDir:TEXCOORD3;
			};
 
             struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

			//定义顶点shader
			v2f vert1(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv=v.uv*_MainTex_ST.xy+_MainTex_ST.zw;
				o.tangentDir=normalize(mul(unity_ObjectToWorld,v.tangent.xyz));
				o.normalDir=normalize(UnityObjectToWorldNormal(v.vertex));
				o.bitangentDir=normalize(cross(o.normalDir,o.tangentDir));
				return o;
			}
 
             v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.tangentDir = normalize(mul(unity_ObjectToWorld,v.tangent.xyz));
                o.normalDir = normalize(UnityObjectToWorldNormal(v.vertex));
                o.bitangentDir = normalize(cross(o.normalDir,o.tangentDir));
                return o;
            }
             fixed4 frag1 (v2f i) : SV_Target
            {
                // 从法线贴图中获取切线向量，并将之从切线空间转换到世界空间
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 normalFromTex = UnpackNormal(tex2D(_NormalTex,i.uv)).rgb;
                float3 normalDirection = normalize(mul(normalFromTex,tangentTransform));
                // 获取世界空间的灯光向量
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                // N 点乘 L
                float NdotL = max(0,dot(normalDirection,lightDirection));

                // 计算方向光
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float3 directDiffuse = NdotL * attenColor;

                // 计算环境光
                float3 inDirectDiffuse = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = col.rgb*(inDirectDiffuse+directDiffuse);
                col.a = 1;
                return col;
            }

			//定义片元shader
			fixed4 frag(v2f i) : SV_Target
			{
				float3x3 tangentTransform = float3x3(i.tangentDir,i.bitangentDir,i.normalDir);
				//float3 normalFromTex=tex2D(_NormalTex,i.uv).rgb*2-1;
				float3 normalFromTex=UnpackNormal( tex2D(_NormalTex,i.uv)).rgb;
				float3 normalDir=normalize(mul(normalFromTex,tangentTransform));
				
				float3 lightDir=normalize( _WorldSpaceLightPos0.xyz);

				//N 点乘 L
				float NdotL = max(0,dot(normalDir,lightDir));

				fixed4 ambelo = tex2D(_MainTex,i.uv);
				ambelo.rgb*=NdotL*_LightColor0.xyz;
				ambelo.a=1;
				return  ambelo;
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

/*
Shader "Hidden/normal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex("Normal Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            //struct v2f
            //{
            //    float2 uv : TEXCOORD0;
            //    float4 vertex : SV_POSITION;
            //    float3 normalDir : TEXCOORD1;
            //    float3 tangentDir : TEXCOORD2;
            //    float3 bitangentDir : TEXCOORD3;
            //};

			//定义结构体：vertex shader阶段输出的内容
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 normalDir:TEXCOORD1;
				float3 tangentDir:TEXCOORD2;
				float3 bitangentDir:TEXCOORD3;
			};

            v2f vert1 (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.tangentDir = normalize(mul(unity_ObjectToWorld,v.tangent.xyz));
                o.normalDir = normalize(UnityObjectToWorldNormal(v.vertex));
                o.bitangentDir = normalize(cross(o.normalDir,o.tangentDir));
                return o;
            }
			//定义顶点shader
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv=v.uv;
				o.tangentDir=normalize(mul(unity_ObjectToWorld,v.tangent.xyz));
				o.normalDir=normalize(UnityObjectToWorldNormal(v.vertex));
				o.bitangentDir=normalize(cross(o.normalDir,o.tangentDir));
				return o;
			}

            sampler2D _MainTex;
            sampler2D _NormalTex;
            fixed4 frag1 (v2f i) : SV_Target
            {
                // 从法线贴图中获取切线向量，并将之从切线空间转换到世界空间
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 normalFromTex = UnpackNormal(tex2D(_NormalTex,i.uv)).rgb;
                float3 normalDirection = normalize(mul(normalFromTex,tangentTransform));
                // 获取世界空间的灯光向量
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                // N 点乘 L
                float NdotL = max(0,dot(normalDirection,lightDirection));

                // 计算方向光
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float3 directDiffuse = NdotL * attenColor;

                // 计算环境光
                float3 inDirectDiffuse = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = col.rgb*(inDirectDiffuse+directDiffuse);
                col.a = 1;
                return col;
            }
			//定义片元shader
			fixed4 frag(v2f i) : SV_Target
			{
				float3x3 tangentTransform = float3x3(i.tangentDir,i.bitangentDir,i.normalDir);
				//float3 normalFromTex=tex2D(_NormalTex,i.uv).rgb*2-1;
				float3 normalFromTex=UnpackNormal( tex2D(_NormalTex,i.uv)).rgb;
				float3 normalDir=normalize(mul(normalFromTex,tangentTransform));
				
				float3 lightDir=normalize( _WorldSpaceLightPos0.xyz);

				//N 点乘 L
				float NdotL = max(0,dot(normalDir,lightDir));

                // 计算方向光
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float3 directDiffuse = NdotL * attenColor;

				  // 计算环境光
                float3 inDirectDiffuse = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed4 ambelo = tex2D(_MainTex,i.uv);
				ambelo.rgb*=(directDiffuse+inDirectDiffuse);
				//ambelo.rgb=NdotL;
				ambelo.a=1;
				return  ambelo;
			}

            ENDCG
        }
    }
}
*/