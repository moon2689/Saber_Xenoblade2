Shader "Xenoblade/XB_Weapon_Blade"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_MaskTex("Mask (RGB)", 2D) = "white" {}
		_NoiseTex("Mask (RGB)", 2D) = "white" {}
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
		}
		LOD 200

		Pass
		{
			Cull Off
			ZWrite Off
			Blend SrcAlpha One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			sampler2D _MaskTex;
			sampler2D _NoiseTex;


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
				fixed4 col = tex2D(_MainTex, i.uv);
				float speed = -_Time.x * 6;
				fixed4 noise = tex2D(_NoiseTex, i.uv + fixed2(0, speed));
				fixed2 uvOffset = noise.rg * 0.2;
				fixed4 mask = tex2D(_MaskTex, (i.uv + uvOffset));
				col.a = i.uv.y < 0.8 ? mask.r : 0;
				return col;
			}

			ENDCG
		}

	}

	Fallback "Diffuse"
}
