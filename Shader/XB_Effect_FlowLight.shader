Shader "Xenoblade/XB_Effect_FlowLight"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Speed("Speed", float) = 6
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
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			float _Speed;


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
				float speed = -_Time.x * _Speed;
				fixed4 col = tex2D(_MainTex, i.uv + fixed2(speed, speed));
				return col;
			}

			ENDCG
		}

	} 

	Fallback "Diffuse"
}
