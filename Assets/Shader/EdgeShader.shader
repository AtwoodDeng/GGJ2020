// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/EdgeShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise" , 2D) = "white" {}
        _Color ("Main Color" , COLOR) = (1,1,1,1)
        _ColorDark( "Dark Color" , COLOR) = (1,1,1,1) 
        _NoiseSpeed("Noise Speed" , float )= 1
        _NoiseScale("Noise Scale" , float )= 1
        _AlphaClip( "Alpha Threshold" , float) = 0.5
    }
    SubShader
    {
        Tags{"Queue" = "Transparent"  "IgnoreProjection" = "True" "RenderType" = "Transparent" }
        
        ZWrite Off // 关闭深度写入
        Blend SrcAlpha OneMinusSrcAlpha // 混合的参数

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work 
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            sampler2D _ColorfulRamp;
            float4 _ColorfulRamp_ST;

            float4 _Color;
            float4 _ColorDark;
            float _NoiseSpeed;
            float _NoiseScale;
            float _AlphaClip;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(UNITY_MATRIX_M , v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 res = lerp( _ColorDark , _Color , col.r );
                res.a = col.a;

                float2 noiseUV = float2( i.worldPos.x * _NoiseScale , i.worldPos.y * _NoiseScale)
                    + _Time.y * _NoiseSpeed * float2(1,3)
                    + _Time.y * _NoiseSpeed * 0.7 * float2(-1,2);
                fixed4 noiseCol = tex2D( _NoiseTex , noiseUV );

                fixed alpha = noiseCol.r + col.r;

                alpha = (alpha > _AlphaClip? 1 : 0) * ( col.r == 0 ? 0 : 1 );

                return fixed4(res.xyz,alpha);
            }
            ENDCG
        }
    }
}
