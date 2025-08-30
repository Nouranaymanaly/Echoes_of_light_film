Shader "Custom/URP_GlowingParticle"
{
    Properties
    {
        _GlowColor ("Glow Color", Color) = (5, 3, 2, 1) // HDR
        _GlowIntensity ("Glow Intensity", Float) = 2.0
        _FlickerStrength ("Flicker Strength", Float) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        ZWrite Off
        Blend SrcAlpha One // Additive with alpha-based softness
        Cull Off

        Pass
        {
            Name "UnlitGlow"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _GlowColor;
            float _GlowIntensity;
            float _FlickerStrength;

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
                output.uv = input.uv;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                return output;
            }

            float rand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float4 frag(Varyings input) : SV_Target
            {
                // Flicker using noise + time
                float noise = rand(input.uv);
                float flicker = lerp(1.0 - _FlickerStrength, 1.0, frac(sin(_Time.y + noise * 10.0) * 0.5 + 0.5));

                float3 emission = _GlowColor.rgb * _GlowIntensity * flicker;

                // Soft radial alpha falloff based on UV
                float2 centerUV = input.uv - 0.5;
                float radialFalloff = saturate(1.0 - dot(centerUV, centerUV) * 2.5); // edge fades faster
                float alpha = radialFalloff;

                return float4(emission, alpha);
            }

            ENDHLSL
        }
    }
}
