Shader "Custom/URP_TrailGlow"
{
    Properties
    {
        _GlowColor ("Glow Color", Color) = (5, 3, 2, 1) // HDR
        _GlowIntensity ("Glow Intensity", Float) = 1.5
        _PulseSpeed ("Pulse Speed", Float) = 2.0
        _MinPulse ("Min Pulse", Range(0,1)) = 0.3
        _MainTex ("Main Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        ZWrite Off
        Blend One One // Additive blend
        Cull Off

        Pass
        {
            Name "TrailGlow"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;
            float4 _GlowColor;
            float _GlowIntensity;
            float _PulseSpeed;
            float _MinPulse;

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

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(v.positionOS);
                o.uv = v.uv;
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                // Pulses between _MinPulse and 1.0
                float pulse = lerp(_MinPulse, 1.0, sin(_Time.y * _PulseSpeed) * 0.5 + 0.5);

                float texSample = tex2D(_MainTex, i.uv).r;

                float3 emission = _GlowColor.rgb * _GlowIntensity * pulse * texSample;

                return float4(emission, 1.0); // Additive blend
            }

            ENDHLSL
        }
    }
    FallBack "Hidden/InternalErrorShader"
}
