Shader "Xenoblade/XB_Body_MaskEmissive"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}

		_Ramp("Ramp Texture", 2D) = "white" {}
		_MaskEmissive("Mask Emissive(RGB)", 2D) = "black" {}
		_MaskCloth("Mask Cloth(RGB)", 2D) = "white" {}

		_SpecularScale("Specular Scale", Range(0, 0.1)) = 0.01
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
			sampler2D _MaskEmissive;
			sampler2D _MaskCloth;
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
				float4 maskSkin = tex2D(_MaskCloth, i.uv);

				fixed4 albedo = tex2D(_MainTex, i.uv);
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
