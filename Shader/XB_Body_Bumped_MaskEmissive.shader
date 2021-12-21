Shader "Xenoblade/XB_Body_Bumped_MaskEmissive"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}

		_Ramp("Ramp Texture", 2D) = "white" {}
		_MaskEmissive("Mask Emissive(RGB)", 2D) = "black" {}
		_MaskSkin("Mask Skin(RGB)", 2D) = "black" {}

		_SpecularScale("Specular Scale", Range(0, 0.1)) = 0.01

		_Outline("Outline", Range(0, 0.01)) = 0.001
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"IgnoreProjector" = "True"
			"Queue" = "Geometry"
		}
		LOD 200

		Pass
		{
			NAME "OUTLINE"

			Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _Outline;
			fixed4 _OutlineColor;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(a2v v)
			{
				v2f o;

				float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				normal.z = -0.5;
				pos = pos + float4(normalize(normal), 0) * _Outline;
				o.pos = mul(UNITY_MATRIX_P, pos);
				//o.pos = UnityObjectToClipPos(v.vertex + v.normal * _Outline);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				return float4(_OutlineColor.rgb, 1);
			}

			ENDCG
		}

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
			sampler2D _NormalMap;
			sampler2D _Ramp;
			sampler2D _MaskEmissive;
			sampler2D _MaskSkin;

			float _SpecularScale;


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
				float4 maskEmission = tex2D(_MaskEmissive, i.uv);
				float4 maskSkin = tex2D(_MaskSkin, i.uv);

				fixed4 albedo = tex2D(_MainTex, i.uv);
				albedo *= _Color;

				fixed3 diffuse = CalcDiffuseWithRampEmissive(albedo, worldLight, worldNormal, _Ramp, maskEmission.r);
				fixed3 specular = CalcSpecular4Cartoon(worldView, worldLight, worldNormal, _SpecularScale, maskSkin.r);
				fixed4 col = fixed4(diffuse + specular, albedo.a);

				return col;
			}

			ENDCG
		}

	}

	Fallback "Diffuse"
}
