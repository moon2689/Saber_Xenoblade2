Shader "Xenoblade/XB_Scene_Diffuse"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Ramp("Ramp Texture", 2D) = "white" {}
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
			NAME "OUTLINE"

			Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

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
				pos = pos + float4(normalize(normal), 0) * 0.01;
				o.pos = mul(UNITY_MATRIX_P, pos);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				return float4(0, 0, 0, 1);
			}

			ENDCG
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			Cull Off

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


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD4;
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
                //float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));
				float3 worldNormal = normalize(i.worldNormal);
				
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = CalcDiffuseWithRamp(albedo, worldLight, worldNormal, _Ramp);
				//fixed3 diffuse = CalcDiffuse(albedo, worldLight, worldNormal);
				fixed4 col = fixed4(ambient + diffuse, albedo.a);
				return col;
			}

			ENDCG
		}

	} 

	Fallback "Diffuse"
}
