Shader "Xenoblade/XB_Hair_Base"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}

		_Ramp("Ramp Texture", 2D) = "white" {}

		_SpecularScale("Specular Scale", Range(0, 0.1)) = 0.01

		_Outline("Outline", Range(0, 0.01)) = 0.001
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
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
		
		UsePass "Xenoblade/XB_Body_Bumped_MaskEmissive/OUTLINE"

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
			sampler2D _Ramp;

			float _SpecularScale;


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

				fixed3 diffuse = CalcDiffuseWithRamp(albedo, worldLight, worldNormal, _Ramp);
				fixed3 specular = CalcSpecular4Cartoon(worldView, worldLight, worldNormal, _SpecularScale);

				fixed4 col = fixed4(diffuse + specular, albedo.a);

				return col;
			}

			ENDCG
		}

	} 

	Fallback "Diffuse"
}
