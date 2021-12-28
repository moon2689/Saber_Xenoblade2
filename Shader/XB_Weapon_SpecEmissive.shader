﻿Shader "Xenoblade/XB_Weapon_SpecEmissive"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_Ramp("Ramp Texture", 2D) = "white" {}

		_SpecTex("Specular Texture", 2D) = "white" {}
		_SpecularGloss("Specular Gloss", float) = 8
		_SpecMask("Specular Mask", 2D) = "white" {}

		_EmissiveTex("Emissive (RGB)", 2D) = "black" {}
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

		UsePass "Xenoblade/XB_Cloth_Base/OUTLINE"

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

			sampler2D _MainTex;
			sampler2D _NormalMap;
			sampler2D _Ramp;

			sampler2D _SpecTex;
			float _SpecularGloss;
			sampler2D _SpecMask;

			sampler2D _EmissiveTex;


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 T2W1 : TEXCOORD1;
				float4 T2W2 : TEXCOORD2;
				float4 T2W3 : TEXCOORD3;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 binormal = cross(normalize(worldNormal), normalize(worldTangent)) * v.tangent.w;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.T2W1 = float4(worldTangent.x, binormal.x, worldNormal.x, worldPos.x);
				o.T2W2 = float4(worldTangent.y, binormal.y, worldNormal.y, worldPos.y);
				o.T2W3 = float4(worldTangent.z, binormal.z, worldNormal.z, worldPos.z);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float3 worldPos = float3(i.T2W1.w, i.T2W2.w, i.T2W3.w);
				float3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 tangentNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
				float3x3 tanToWorld = float3x3(i.T2W1.xyz, i.T2W2.xyz, i.T2W3.xyz);
				float3 worldNormal = mul(tanToWorld, tangentNormal);

				fixed4 col;

				// 漫反射
				fixed4 emissiveTex = tex2D(_EmissiveTex, i.uv);
				fixed4 albedo = tex2D(_MainTex, i.uv);
				fixed3 diffuse = CalcDiffuseWithRamp(albedo, worldLight, worldNormal, _Ramp);
				diffuse += emissiveTex;
				col.rgb = diffuse;

				// 高光1
				fixed4 maskSpec = tex2D(_SpecMask, i.uv);
				if (maskSpec.b > 0.5)
				{
					fixed4 texSpec = tex2D(_SpecTex, i.uv);
					fixed3 specCol = CalcSpecularWithColor(worldView, worldLight, worldNormal, _SpecularGloss, texSpec);
					col.rgb += specCol;
				}

				col.a = albedo.a;
				return col;
			}

			ENDCG
		}

	}

	Fallback "Diffuse"
}
