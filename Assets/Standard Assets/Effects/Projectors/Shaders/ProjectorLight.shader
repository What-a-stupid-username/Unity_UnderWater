// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'
// Upgrade NOTE: replaced '_ProjectorClip' with 'unity_ProjectorClip'

Shader "Projector/Light" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_ShadowTex ("Cookie", 2D) = "" {}
		_FalloffTex ("FallOff", 2D) = "" {}
		_NoiceTex("Noice", 2D) = "black"{}
	}
	
	Subshader {
		Tags {"Queue"="Transparent"}
		Pass {
			ZWrite Off
			ColorMask RGB
			Blend DstColor One
			Offset -1, -1
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			
			struct v2f {
				float4 uvShadow : TEXCOORD0;
				float4 uvFalloff : TEXCOORD1;
				UNITY_FOG_COORDS(2)
				float4 pos : SV_POSITION;
			};
			
			float4x4 unity_Projector;
			float4x4 unity_ProjectorClip;
			
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				o.uvShadow = mul (unity_Projector, vertex);
				o.uvFalloff = mul (unity_ProjectorClip, vertex);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 _Color;
			sampler2D _ShadowTex;
			sampler2D _FalloffTex;
			sampler2D _NoiceTex;

			fixed4 frag (v2f i) : SV_Target
			{
				float a = tex2D(_NoiceTex, UNITY_PROJ_COORD(i.uvShadow) + _Time.xy / 100);
				float b = tex2D(_NoiceTex, UNITY_PROJ_COORD(i.uvShadow) + 0.3);
				float2 bias = float2(a, b) / 50;

				fixed4 texS = tex2D(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow) + bias);
				texS += tex2D(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow)*2 + bias + sin(_Time.xy/160 + 0.3)) * (0.7 + sin(_Time.x / 10 + 0.3) * 0.3);
				texS += tex2D(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow)*4 + bias + sin(_Time.zw/80 + 0.6)) * (0.7 + sin(_Time.x / 10 + 0.6) * 0.3);
				texS.rgb *= _Color.rgb;
				texS = clamp(texS * 2 - 1,0,1);
				texS.a = 1.0-texS.a;
	
				fixed4 texF = tex2Dproj (_FalloffTex, UNITY_PROJ_COORD(i.uvFalloff));
				fixed4 res = texS * texF.a;

				UNITY_APPLY_FOG_COLOR(i.fogCoord, res, fixed4(0,0,0,0));
				return res;
			}
			ENDCG
		}
	}
}
