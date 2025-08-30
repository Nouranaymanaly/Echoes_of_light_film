Shader "Unlit/BendShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BendAmount ("Bend Amount", Float) = 0.1

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
            Name "BendFogDissolve"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex;
            float4 _FogColor;
            float _FogStart;
            float _FogEnd;
            float _BendAmount;
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

                float3 pos = input.positionOS.xyz;

                // 🔄 Apply bending (in local space)
                pos.y += _BendAmount * pow(pos.x, 2);

                float3 worldPos = TransformObjectToWorld(pos);
                output.worldPos = worldPos;
                output.positionHCS = TransformWorldToHClip(worldPos);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float distToCam = distance(_WorldSpaceCameraPos.xyz, input.worldPos);
                float fogFactor = saturate((distToCam - _FogStart) / (_FogEnd - _FogStart));

                // Sample dissolve noise
                float noise = tex2D(_NoiseTex, input.uv).r;

                float dissolve = smoothstep(_DissolveAmount - _EdgeSoftness, _DissolveAmount + _EdgeSoftness, noise);
                float alpha = fogFactor * dissolve;

                float3 baseColor = tex2D(_MainTex, input.uv).rgb;

                return float4(lerp(baseColor, _FogColor.rgb, fogFactor), alpha);
            }
            ENDHLSL
        }
    }
}
