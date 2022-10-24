Shader "Unlit/Unlit"
{
    Properties
    {
        _TintColor("TintColor", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {} //scale and offset is there by default
			
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
		Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
			/**/
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
				/**/
        }
    }
}
