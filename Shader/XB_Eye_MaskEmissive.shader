Shader "Xenoblade/XB_Eye_MaskEmissive"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}

		_MaskEmissive("Mask Emissive(RGB)", 2D) = "black" {}

		_SpecularGloss ("Specular Gloss", float) = 8
	}

	SubShader
	{
		Tags 
		{
			"RenderType" = "Transparent"
			"IgnoreProjector" = "True"
			"Queue" = "Transparent+100"
		}
		LOD 200
		
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			#include "XenobladeCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			sampler2D _MaskEmissive;

			float _SpecularGloss;


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
				albedo *= _Color;

				float4 mask = tex2D(_MaskEmissive, i.uv);

				fixed3 diffuse = CalcDiffuse(albedo, worldLight, worldNormal);
				fixed3 specular = CalcSpecular(worldView, worldLight, worldNormal, _SpecularGloss, i.uv);

				fixed4 col = fixed4(diffuse + specular, albedo.a);
				col = lerp(col, albedo, mask.r);

				return col;
			}

			ENDCG
		}

	} 

	Fallback "Specular"
}
