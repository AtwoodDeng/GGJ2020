// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/CellShader"
{
    Properties
    {
        _MainTex ("Main", 2D) = "white" {}
        _EdgeTex ("Edge", 2D) = "white" {}
        _ColorfulRamp ("Colorful Ramp", 2D) = "white" {}
        _NoiseTex("Noise" , 2D) = "white" {}
        _Color ("Main Color" , COLOR) = (1,1,1,1)
        //_ColorDark( "Dark Color" , COLOR) = (1,1,1,1) 
        _InfectRate("Infect Rate" , range(0,1) )= 1
        _NoiseSpeed("Noise Speed" , float )= 1
        _NoiseScale("Noise Scale" , float )= 1
        _EdgeNoiseSpeed("Edge Speed" , float )= 1
        _EdgeNoiseScale("Edge Scale" , float )= 1
        _EdgeClip("Edge Clip" , float )= 1
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
            sampler2D _EdgeTex;
            float4 _EdgeTex_ST;
            sampler2D _ColorfulRamp;
            float4 _ColorfulRamp_ST;

            float4 _Color;
            float4 _ColorDark;
            float _NoiseSpeed;
            float _NoiseScale;
            float _EdgeNoiseSpeed;
            float _EdgeNoiseScale;
            float _EdgeClip;
            float _InfectRate;

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
                fixed4 edge = tex2D(_EdgeTex, i.uv);

                fixed4 colorDark = _Color * 0.5;
                fixed4 colorEdge = _Color * 0.23;
                fixed4 colorBright = lerp(_Color, fixed4(1,1,1,1) , 0.5);

                fixed4 res = lerp( colorDark , _Color , col.r );
                res.a = col.a;

                float2 noiseUV = float2( i.worldPos.x * _NoiseScale , i.worldPos.y * _NoiseScale)
                    + sin( _Time.y * _NoiseSpeed ) * float2(1,0.5)
                    + sin( _Time.y * _NoiseSpeed ) * 0.8 * float2(-1,2)
                    + sin( _Time.y * _NoiseSpeed ) * 0.5 * float2(0.5,-2);
                    
                fixed4 noiseCol = tex2D( _NoiseTex , noiseUV );
                fixed4 doubleNoiseCol = tex2D( _NoiseTex , noiseUV + _Time.y * _NoiseSpeed * 2 * float2(-noiseCol.x, 5 * noiseCol.y));

                fixed4 sifiColor = tex2D( _ColorfulRamp , noiseCol.rr );

                res.rgb = lerp( sifiColor.rgb , res.rgb , clamp( col.g + ( 2 + sin( _Time.y * 2 )  ) * ( 1 - _InfectRate),0,1) );

                // deal with edge 
                
                float2 edgeNoiseUV1 = float2( i.worldPos.x * _EdgeNoiseScale , i.worldPos.y * _EdgeNoiseScale)
                    + _Time.y * _EdgeNoiseSpeed * float2(1,3);
                float2 edgeNoiseUV2 = float2( i.worldPos.x * _EdgeNoiseScale , i.worldPos.y * _EdgeNoiseScale)
                    + _Time.y * _EdgeNoiseSpeed * 0.7 * float2(-1,2);

                fixed4 edgeNoiseCol1 = tex2D( _NoiseTex , edgeNoiseUV1 );
                fixed4 edgeNoiseCol2 = tex2D( _NoiseTex , edgeNoiseUV2 );

                float edgeAlpha = lerp( ( edgeNoiseCol1.r + edgeNoiseCol2.r ) * 0.5, 0.5 , 1 -  _InfectRate ) + edge.r;
                
                edgeAlpha = (edgeAlpha - _EdgeClip > 0 ? 1 : 0 ) * ( edge.r > 0 ? 1 : 0 );
                //fixed4 edgeColor = lerp( colorDark , colorBright , 1 - edge.r) ;
                fixed4 edgeColor = colorDark;

                fixed4 finalColor = lerp( res , edgeColor , edgeAlpha);

                return fixed4( finalColor.rgb , max(edgeAlpha, col.a));
            }
            ENDCG
        }
    }
}
