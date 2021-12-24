// diffuse 算法
/*
* [-1, 1] -> [A, 1]
* y = a * x + b
* a = (1 - A) / 2
* b = (1 + A) / 2
*/
fixed3 CalcDiffuse(fixed4 albedo, float3 worldLight, float3 worldNormal)
{
	float d = dot(worldLight, worldNormal) * 0.5 + 0.5;
	fixed3 diffuse = albedo.rgb * _LightColor0.rgb * d;
	return diffuse;
}

// diffuse with ramp
fixed3 CalcDiffuseWithRamp(fixed4 albedo, float3 worldLight, float3 worldNormal, sampler2D ramp)
{
	float d = dot(worldLight, worldNormal) * 0.5 + 0.5;
	fixed3 diffuse = albedo.rgb * _LightColor0.rgb * tex2D(ramp, float2(d, d)).rgb;
	return diffuse;
}

fixed3 CalcDiffuseWithEmissive(fixed4 albedo, float3 worldLight, float3 worldNormal, float emissive)
{
	float d = dot(worldLight, worldNormal) * 0.5 + 0.5;
	fixed3 diffuse = albedo.rgb * _LightColor0.rgb * d;
	//diffuse = lerp(diffuse, albedo, emissive);
	diffuse += albedo * emissive;
	return diffuse;
}

// diffuse with ramp, emissive
fixed3 CalcDiffuseWithRampEmissive(fixed4 albedo, float3 worldLight, float3 worldNormal, sampler2D ramp, float emissive)
{
	float d = dot(worldLight, worldNormal) * 0.5 + 0.5;
	fixed3 diffuse = albedo.rgb * _LightColor0.rgb * tex2D(ramp, float2(d, d)).rgb;
	//diffuse = lerp(diffuse, albedo, emissive);
	diffuse += albedo * emissive;
	return diffuse;
}

// specular 算法
fixed3 CalcSpecular(float3 worldView, float3 worldLight, float3 worldNormal, float _SpecularGloss)
{
	fixed3 halfDir = normalize(worldView + worldLight);
	float specD = abs(dot(halfDir, worldNormal));
	fixed3 specular = _LightColor0.rgb * pow(specD, _SpecularGloss);
	return specular;
}

// specular 卡通
fixed3 CalcSpecular4Cartoon(float3 worldView, float3 worldLight, float3 worldNormal, float specScale)
{
	fixed3 halfDir = normalize(worldView + worldLight);
	float specD = abs(dot(halfDir, worldNormal));
	fixed w = fwidth(specD) * 2.0;
	fixed3 specular = _LightColor0.rgb * lerp(0, 1, smoothstep(-w, w, specD + specScale - 1)) * step(0.0001, specScale);
	return specular;
}

// specular 卡通，皮肤遮罩
fixed3 CalcSpecular4Cartoon(float3 worldView, float3 worldLight, float3 worldNormal, float specScale, float maskSkin)
{
	fixed3 halfDir = normalize(worldView + worldLight);
	float specD = abs(dot(halfDir, worldNormal));
	fixed w = fwidth(specD) * 2.0;
	fixed3 specular = _LightColor0.rgb * lerp(0, 1, smoothstep(-w, w, specD + specScale - 1)) * step(0.0001, specScale);
	specular *= maskSkin.r;
	return specular;
}

fixed CalcSpecularRate(float3 worldView, float3 worldLight, float3 worldNormal, float _SpecularGloss)
{
	fixed3 halfDir = normalize(worldView + worldLight);
	float specD = abs(dot(halfDir, worldNormal));
	return pow(specD, _SpecularGloss);
}

fixed3 CalcSpecularWithColor(float3 worldView, float3 worldLight, float3 worldNormal, float _SpecularGloss, fixed3 specCol)
{
	return specCol * CalcSpecular(worldView, worldLight, worldNormal, _SpecularGloss);
}