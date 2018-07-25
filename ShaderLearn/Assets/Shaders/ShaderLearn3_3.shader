Shader "Tutorial/Basic"
{
	Properties
	{
		_Color("Main Color",Color)=(1,0.5,0.5,1)
	}
	SubShader{
	/*
		Pass{
				Material{
							Diffuse[_Color]
				}
				Lighting  On
		}
	*/
		Pass {
		    Material {
		        Diffuse [_Color]
		        Ambient [_Color]
		        Shininess [_Shininess]
		        Specular [_SpecColor]
		        Emission [_Emission]
		    }
		    Lighting On
		    SeparateSpecular On
		    SetTexture [_MainTex] {
		        constantColor [_Color]
		        Combine texture * primary DOUBLE, texture * constant
		    }
		}

	}

	FallBack off


}