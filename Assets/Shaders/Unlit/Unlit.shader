Shader "Unlit/Unlit"
{
	Properties
	{
		_TintColor("TintColor", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {} //scale and offset is there by default

		_MaskTexture("Mask Texture", 2D) = "white" {}
		//alpha handling mode, either multiply alpha or alpha clip
		[Enum(AlphaHandlingMode)] _MaskMode("Mask Mode", Float) = 0
			//Blend mode, the render type
			[Enum(BlendMode)] _BlendMode("Blend Mode", Float) = 0
			//alpha cutoff
			[Range(0,1)] _AlphaCutoff("Alpha Cutoff", Float) = 0.5

			_VertexColors("Use Vertex Colors", Float) = 1

			//sidedness
			[Enum(Sidedness)] _Sidedness("Sidedness", Float) = 0
			//ZWrite
			[Enum(ZWrite)] _ZWrite("ZWrite", Float) = 0

			_OffsetTexture("Offset Texture", 2D) = "white" {}
			_OffsetMagnitude("Offset Magnitude", Vector) = (0,0,0,0)

			[ShaderBool]_PolarUVMapping("Polar UV Mapping", Float) = 0
			_PolarPower("Polar Power", Float) = 1
	}
		SubShader
			{
				//allow both opaque and transparent
				Tags { "RenderType" = "Transparent" }
				LOD 100

				HLSLINCLUDE
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			CBUFFER_START(UnityPerMaterial)
			float4 _TintColor;
			float4 _MainTex_ST;
			float4 _MaskTexture_ST;
			float4 _OffsetTexture_ST;
			float _MaskMode;
			float _BlendMode;
			float _AlphaCutoff;
			float _VertexColors;
			float _Sidedness;
			float _ZWrite;
			float4 _OffsetMagnitude;
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
					o.uvMain = TRANSFORM_TEX(i.uv, _MainTex); //transform UV according to scale and offset
					o.uvMask = TRANSFORM_TEX(i.uv, _MaskTexture); //transform UV according to scale and offset
					o.uvOffset = TRANSFORM_TEX(i.uv, _OffsetTexture); //transform UV according to scale and offset
					o.color = i.color;
					return o;
				}

				float4 frag(VertexOutput i) : SV_Target
				{
					float2 samplePoint = i.uvMain;
					float2 offsetPoint = SAMPLE_TEXTURE2D(_OffsetTexture, sampler_OffsetTexture, i.uvOffset).xy;
					offsetPoint -= 0.5;
					offsetPoint *= 2;
					offsetPoint *= _OffsetMagnitude.xy;
					samplePoint += offsetPoint;
					float4 mainTexCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, samplePoint);
					return mainTexCol.a * _TintColor;
				}

				ENDHLSL
					/*
					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					// make fog work
					#pragma multi_compile_fog

					#include "UnityCG.cginc"

					struct appdata
					{
						float4 vertex : POSITION;
						float2 uv : TEXCOORD0;
					};

					struct v2f
					{
						float2 uv : TEXCOORD0;
						UNITY_FOG_COORDS(1)
						float4 vertex : SV_POSITION;
					};

					sampler2D _MainTex;
					float4 _MainTex_ST;

					v2f vert (appdata v)
					{
						v2f o;
						o.vertex = UnityObjectToClipPos(v.vertex);
						o.uv = TRANSFORM_TEX(v.uv, _MainTex);
						UNITY_TRANSFER_FOG(o,o.vertex);
						return o;
					}

					fixed4 frag (v2f i) : SV_Target
					{
						// sample the texture
						fixed4 col = tex2D(_MainTex, i.uv);
						// apply fog
						UNITY_APPLY_FOG(i.fogCoord, col);
						return col;
					}
					ENDCG
						*/
				}
			}
}