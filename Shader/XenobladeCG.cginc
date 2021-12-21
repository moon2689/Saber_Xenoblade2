// diffuse 算法
/*
* [-1, 1] -> [A, 1]
* y = a * x + b
* a = (1 - A) / 2
* b = (1 + A) / 2
*/
fixed3 CalcDiffuse(fixed4 albedo, float3 worldLight, float3 worldNormal)
{
	float d = dot(worldLight, worldNormal) * 0.35 + 0.65;
	fixed3 diffuse = albedo.rgb * _LightColor0.rgb * d;
	return diffuse;
}

// specular 算法
fixed3 CalcSpecular(float3 worldView, float3 worldLight, float3 worldNormal, float _SpecularGloss, float2 uv)
{
	fixed3 halfDir = normalize(worldView + worldLight);
	float specD = abs(dot(halfDir, worldNormal));
	fixed3 specular = _LightColor0.rgb * pow(specD, _SpecularGloss);
	return specular;
}