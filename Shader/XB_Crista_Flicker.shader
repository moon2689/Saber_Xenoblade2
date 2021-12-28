Shader "Xenoblade/XB_Crista_Flicker"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_FlickerTex("Flicker (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "Geometry"
			"IgnoreProjector" = "True"
		}
		LOD 200

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			sampler2D _FlickerTex;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				fixed4 flicker = tex2D(_FlickerTex, i.uv);
				//float speed = abs(_SinTime.w);
				float speed = _SinTime.w;
				float offset = max(0, flicker.r * speed);
				fixed4 col = albedo * (1 + offset);
				return col;
			}

			ENDCG
		}

	}

	Fallback "Diffuse"
}
