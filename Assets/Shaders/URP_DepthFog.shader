Shader "Custom/URP_DepthFog"
{
    Properties
    {
        _FogColor ("Fog Color", Color) = (0.5, 0.6, 0.7, 1)
        _FogStart ("Start Distance", Float) = 10.0
        _FogEnd ("End Distance", Float) = 50.0
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0,1)) = 0.5
        _EdgeSoftness ("Edge Softness", Float) = 0.1
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            Name "FogPass"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _NoiseTex;
            float4 _FogColor;
            float _FogStart;
            float _FogEnd;
            float _DissolveAmount;
            float _EdgeSoftness;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                float3 worldPos = TransformObjectToWorld(input.positionOS.xyz);
                output.worldPos = worldPos;
                output.positionHCS = TransformWorldToHClip(worldPos);
                output.uv = input.uv;
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float distToCam = distance(_WorldSpaceCameraPos.xyz, input.worldPos);
                float fogFactor = saturate((distToCam - _FogStart) / (_FogEnd - _FogStart));

                // Sample noise texture
                float noise = tex2D(_NoiseTex, input.uv).r;

                // Soft dissolve: compare noise to dissolve amount with edge softness
                float dissolve = smoothstep(_DissolveAmount - _EdgeSoftness, _DissolveAmount + _EdgeSoftness, noise);

                // Combine dissolve with fog factor
                float finalAlpha = fogFactor * dissolve;

                return float4(_FogColor.rgb, finalAlpha);
            }
            ENDHLSL
        }
    }
}

