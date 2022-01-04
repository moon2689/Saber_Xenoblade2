Shader "Xenoblade/XB_Fur_Base"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _FurTex ("Fur Pattern", 2D) = "white" { }
        
        _FurLength ("Fur Length", Range(0.0, 1)) = 0.5
        _FurDensity ("Fur Density", Range(0, 2)) = 0.11
        _FurThinness ("Fur Thinness", Range(0.01, 10)) = 1
        _FurShading ("Fur Shading", Range(0.0, 1)) = 0.25
    }

    Category
    {

        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
        
        SubShader
        {
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_surface
                #pragma fragment frag_surface
                #define FURSTEP 0.00
                #include "XBFurHelper.cginc"
                
                ENDCG
                
            }


            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.2
                #include "XBFurHelper.cginc"
                
                ENDCG
                
            }
            
          
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.4
                #include "XBFurHelper.cginc"
                
                ENDCG
                
            }
            
          
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.6
                #include "XBFurHelper.cginc"
                
                ENDCG
                
            }
            
           
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 0.8
                #include "XBFurHelper.cginc"
                
                ENDCG
                
            }

            
            Pass
            {
                CGPROGRAM
                
                #pragma vertex vert_base
                #pragma fragment frag_base
                #define FURSTEP 1
                #include "XBFurHelper.cginc"
                
                ENDCG
                
            }
          
        }
    }
}