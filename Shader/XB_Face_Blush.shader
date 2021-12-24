Shader "Xenoblade/XB_Face_Blush"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_MaskTex("Mask (RGB)", 2D) = "white" {}
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
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "XenobladeCG.cginc"

			sampler2D _MainTex;
			sampler2D _MaskTex;
			sampler2D _Ramp;


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float3 worldPos = i.worldPos;
				float3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 worldNormal = normalize(i.worldNormal);

				fixed4 albedo = tex2D(_MainTex, i.uv);
				fixed3 diffuse = CalcDiffuse(albedo, worldLight, worldNormal);
				fixed4 col = fixed4(diffuse, albedo.a);
				fixed4 colMask = tex2D(_MaskTex, i.uv);
				col.a = colMask.r;

				return col;
			}

			ENDCG
		}

	}

	Fallback "Diffuse"
}
