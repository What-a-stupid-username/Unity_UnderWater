Shader "Custom/DrawBuffer" 
{
	Properties {
		_ParticleTex("Particle texture",2D) = "black" {}
		_Size("Particle size", float) = 0.4
	}
		SubShader
	{
		Pass
		{
			Cull off
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma target 5.0
			#pragma enable_d3d11_debug_symbols

			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			sampler2D _ParticleTex;
			float _Size;

			struct Info
			{
				float3 pos, v;
			};


			uniform StructuredBuffer<Info> particle_buffer;

			//sampler2D _CameraDepthTexture;

			struct v2g{
				float4 id : SV_POSITION;
			};


			v2g vert(uint index : SV_VertexID)
			{
				v2g o;
				o.id = index;
				return o;
			}

			
			struct g2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			[maxvertexcount(6)]
			void geom(point v2g points[1], inout TriangleStream<g2f> triStream) {
				int id = points[0].id;
				
				float4 pos = UnityObjectToClipPos(float4(particle_buffer[id].pos/100, 1));
				float3 v = particle_buffer[id].v;
				g2f o;
				o.pos = pos;
				o.uv = 0;
				triStream.Append(o);
				o.pos = pos + float4(_Size,0,0,0);
				o.uv = float2(1, 0);
				triStream.Append(o);
				o.pos = pos + float4(0, _Size, 0, 0);
				o.uv = float2(0, 1);
				triStream.Append(o);
				o.pos = pos + float4(_Size, 0, 0, 0);
				o.uv = float2(1, 0);
				triStream.Append(o);
				o.pos = pos + float4(_Size, _Size, 0, 0);
				o.uv = float2(1, 1);
				triStream.Append(o);
				o.pos = pos + float4(0, _Size, 0, 0);
				o.uv = float2(0, 1);
				triStream.Append(o);
			   
			}


			float4 frag(g2f IN) : COLOR
			{
				return float4(1, 1, 1, tex2D(_ParticleTex, IN.uv).a);
			}

			ENDCG

		}
	}
}