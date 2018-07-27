Shader "Custom/MetaBall_shader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Cut("Cut", Range(0,1)) = 0.2
	}
	SubShader {
		Pass{
			Tags{ "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma fragment frag
			#pragma vertex vert
			
			sampler2D _MainTex;
			float _Cut;
			
			struct a2v {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
		
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.uv = i.texcoord;
				return o;
			}


			float4 frag(v2f i) : COLOR{
				return step(_Cut, tex2D(_MainTex,i.uv).x);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
