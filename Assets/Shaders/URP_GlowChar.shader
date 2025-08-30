
    Shader "Custom/URP_GlowChar"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _GlowColor ("Glow Color", Color) = (5, 3, 2, 1) // HDR glow triggers bloom
        _GlowIntensity ("Glow Intensity", Float) = 1.5
        _PulseSpeed ("Pulse Speed", Float) = 3.0
        _MinGlow ("Minimum Glow", Range(0, 1)) = 0.3
        _GlowStartTime ("Glow Start Time", Float) = 2.0 // Time in seconds before glow starts
        _CurrentTime ("Current Time", Float) = 0.0 // Updated each frame from script

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Include core functions from URP
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
            };

            // Shader properties
            float4 _BaseColor;
            float4 _GlowColor;
            float _GlowIntensity;
            float _PulseSpeed;
            float _MinGlow;
            float _GlowStartTime;
            float _CurrentTime;


            Varyings vert(Attributes input)
            {
                Varyings output;
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.positionHCS = TransformWorldToHClip(positionWS);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float3 lightDir = normalize(_MainLightPosition.xyz);
                float NdotL = saturate(dot(input.normalWS, lightDir));
                float3 litColor = _BaseColor.rgb * NdotL;

                float pulse = 0.0;

                if (_CurrentTime >= _GlowStartTime)
                {
                    float t = _CurrentTime - _GlowStartTime;
                    pulse = sin(t * _PulseSpeed) * 0.5 + 0.5;
                    pulse = lerp(_MinGlow, 1.0, pulse);
                }

                float3 emission = _GlowColor.rgb * _GlowIntensity * pulse;

                return float4(litColor + emission, 1.0);
            }


            ENDHLSL
        }
    }

    FallBack "Hidden/InternalErrorShader"
}

