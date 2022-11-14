Shader "Unlit/UnlitTransparent"
{
	Properties
	{
		_TintColor("TintColor", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {} //scale and offset is there by default

		_MaskTexture("Mask Texture", 2D) = "white" {}
		//alpha handling mode, either multiply alpha or alpha clip
		[Enum(MultiplyAlpha, 0, AlphaClip, 1)] _MaskMode("Mask Mode", Float) = 0
			
		//alpha cutoff
		[Range(0,1)] _AlphaCutoff("Alpha Cutoff", Float) = 0.5

		[Enum(Off, 0, On, 1)]_VertexColors("Use Vertex Colors", Float) = 1

		_OffsetTexture("Offset Texture", 2D) = "white" {}
		_OffsetMagnitude("Offset Magnitude", Vector) = (0,0,0,0)

		[Enum(Off, 0, On, 1)]_PolarUVMapping("Polar UV Mapping", Float) = 0
		_PolarPower("Polar Power", Float) = 1
	}
		SubShader
			{
				//transparent rendering
				Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
				LOD 100
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				HLSLINCLUDE
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			CBUFFER_START(UnityPerMaterial)
			float4 _TintColor;
			float4 _MainTex_ST;
			float4 _MaskTexture_ST;
			float4 _OffsetTexture_ST;
			float _MaskMode;
			float _AlphaCutoff;
			float _VertexColors;
			float4 _OffsetMagnitude;
			float _PolarUVMapping;
			float _PolarPower;
			CBUFFER_END

				TEXTURE2D(_MainTex);
				SAMPLER(sampler_MainTex);

				TEXTURE2D(_MaskTexture);
				SAMPLER(sampler_MaskTexture);

				TEXTURE2D(_OffsetTexture);
				SAMPLER(sampler_OffsetTexture);

				struct VertexInput
				{
					float4 position : POSITION;
					float4 color : COLOR;
					float2 uv : TEXCOORD0;
				};

				struct VertexOutput
				{
					float4 position : SV_POSITION;
					float4 color : COLOR;
					float2 uvMain : TEXCOORD0;
					float2 uvMask : TEXCOORD1;
					float2 uvOffset : TEXCOORD2;
				};
			ENDHLSL

			Pass
			{
				HLSLPROGRAM
	#pragma vertex vert
	#pragma fragment frag

				VertexOutput vert(VertexInput i)
				{
					VertexOutput o;
					o.position = TransformObjectToHClip(i.position.xyz);

					/*
					//if polar UV Mapping is 1, convert the point to polar coordinates
					if (_PolarUVMapping == 1)
					{
						float2 uv = i.uv;
						uv -= (0.5, 0.5);
						uv *= 2;

						float r = sqrt(uv.x * uv.x + uv.y * uv.y);
						float o = atan2(uv.x, uv.y);
						o.uvMain = TRANSFORM_TEX(i.uv, _MainTex);
					}
					else
					*/
					//o.uvMain = i.uv;
					o.uvMain = TRANSFORM_TEX(i.uv, _MainTex); //transform UV according to scale and offset
					o.uvMask = TRANSFORM_TEX(i.uv, _MaskTexture); //transform UV according to scale and offset
					o.uvOffset = TRANSFORM_TEX(i.uv, _OffsetTexture); //transform UV according to scale and offset
					o.color = i.color;
					return o;
				}

				float4 frag(VertexOutput i) : SV_Target
				{
					//what point of the main texture will we sample?
					float2 samplePoint = i.uvMain + _MainTex_ST.xy;

					//offset by offset texture
					float2 offsetPoint = SAMPLE_TEXTURE2D(_OffsetTexture, sampler_OffsetTexture, i.uvOffset).xy;
					offsetPoint -= 0.5;
					offsetPoint *= 2;
					offsetPoint *= _OffsetMagnitude.xy;
					samplePoint += offsetPoint;

					//sample the main texture
					float4 mainTexCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, samplePoint);
					
					//sample mask texture
					float4 maskTexCol = SAMPLE_TEXTURE2D(_MaskTexture, sampler_MaskTexture, i.uvMask);
					//take intensity of mask texture
					float maskIntensity = (maskTexCol.r + maskTexCol.g + maskTexCol.b + maskTexCol.a) / 4.0;
					
					//if maskmode is 1, use cutoff point to floor or round the value
					if (_MaskMode == 1)
						maskIntensity = maskIntensity > _AlphaCutoff ? 1 : 0;

					//multiply final result with tint color
					return mainTexCol * _TintColor * maskIntensity;
				}

				ENDHLSL
				}
			}
}