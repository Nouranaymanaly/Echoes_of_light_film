Shader "Custom/URP_RadialGlow"
{
    Properties
    {
        _GlowColor ("Glow Color", Color) = (1,1,1,1)
        _Radius ("Glow Radius", Float) = 0.1
        _Softness ("Edge Softness", Float) = 0.2
        _Center ("Glow Center", Vector) = (0.5, 0.5, 0, 0)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Overlay" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            Name "RadialGlow"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _GlowColor;
            float _Radius;
            float _Softness;
            float4 _Center; // in normalized screen space (0–1)

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.uv = input.uv;
                return output;
            }

          half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                float2 center = _Center.xy; // normalized 0–1
                float dist = distance(uv, center);

                // Glow expands outward (transparent at start, fills later)
                float glow = smoothstep(_Radius, _Radius - _Softness, dist);

                return float4(_GlowColor.rgb, glow);
            }


            ENDHLSL
        }
    }
}
