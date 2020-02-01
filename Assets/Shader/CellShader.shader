// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/CellShader"
{
    Properties
    {
        _FirstMainTex ("Main", 2D) = "white" {}
        _SecMainTex("SecondMainTex" , 2D) = "white"{}
        _EdgeTex ("Edge", 2D) = "white" {}
        _ColorfulRamp ("Colorful Ramp", 2D) = "white" {}
        _NoiseTex("Noise" , 2D) = "white" {}
        _NoiseTexSub("NoiseSub" , 2D) = "white" {}

        _Color ("Main Color" , COLOR) = (1,1,1,1)
        //_ColorDark( "Dark Color" , COLOR) = (1,1,1,1) 
        _InfectRate("Infect Rate" , range(0,1) )= 1
        _HealRate("Heal Rate" , range(0,1)) = 1
        _VirusRate("Virus Rate" , range(0,1) ) = 1
        _FadeRate("Fade Rate" , range(0,1) ) =1 


        _NoiseSpeed("Infect Noise Speed" , float )= 1
        _NoiseScale("Infect Noise Scale" , float )= 1
        
        _VirusNoiseSpeed("Virus Noise Speed" , float )= 1
        _VirusNoiseScale("Virus Noise Scale" , float )= 1

        _HealNoiseSpeed("Heal Noise Speed" , float )= 1
        _HealNoiseScale("Heal Noise Scale" , float )= 1


        _EdgeNoiseSpeed("Edge Speed" , float )= 1
        _EdgeNoiseScale("Edge Scale" , float )= 1
        _EdgeClip("Edge Clip" , float )= 1
        _BreathSpeed("Breath Cycle" , float ) = 3
        _BreathOffset("Breath Offset " , float ) = 1

        [Toggle]_UseSelfColor("Use SelfColor" , float ) = 1
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

            sampler2D _FirstMainTex;
            float4 _FirstMainTex_ST;
            sampler2D _SecMainTex;
            float4 _SecMainTex_ST;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            sampler2D _NoiseTexSub;
            float4 _NoiseTexSub_ST;

            sampler2D _EdgeTex;
            float4 _EdgeTex_ST;

            sampler2D _ColorfulRamp;
            float4 _ColorfulRamp_ST;

            float4 _Color;
            float4 _ColorDark;


            float _NoiseSpeed;
            float _NoiseScale;
            
            float _VirusNoiseSpeed;
            float _VirusNoiseScale;
            float _HealNoiseSpeed;
            float _HealNoiseScale;

            float _EdgeNoiseSpeed;
            float _EdgeNoiseScale;
            float _EdgeClip;
            
            float _InfectRate;
            float _HealRate;
            float _VirusRate;
            float _FadeRate;
            float _BreathSpeed;
            float _BreathOffset;

            float _UseSelfColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _FirstMainTex);
                o.worldPos = mul(UNITY_MATRIX_M , v.vertex);
                return o;
            }

            float GetBreathPos()
            {
                return sin( _Time.y * _BreathSpeed + _BreathOffset);
            }

            fixed4 ShiftHue(fixed4 from , fixed4 shift )
            {
                
                return fixed4(
                from.r-shift.r*(2*from.r-from.g-from.b),
                from.g-shift.g*(2*from.g-from.r-from.b),
                from.b-shift.b*(2*from.b-from.r-from.g),
                from.a
                );

            }


            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 colorDark = _Color * 0.5;
                fixed4 colorEdge = _Color * 0.23;
                fixed4 colorBright = lerp(_Color, fixed4(1,1,1,1) , 0.25);

                // sample the texture
                fixed4 mainTexCol = tex2D(_FirstMainTex, i.uv);
                fixed4 edge = tex2D(_EdgeTex, i.uv);
                fixed4 secMainTexCol = tex2D( _SecMainTex, i.uv);

                float overlayRate = max( max( _InfectRate , _VirusRate ) , _HealRate) ;


                float2 mainNoiseUV = float2( i.worldPos.x * _NoiseScale  , i.worldPos.y * _NoiseScale );
                fixed4 mainNoiseCol = tex2D( _NoiseTex , mainNoiseUV );

                float mainFade = clamp( _FadeRate * ( 1 + mainNoiseCol.r * 4 ) , 0 , 1 );

                fixed4 mainCol = lerp( mainTexCol , secMainTexCol, mainFade);
                fixed3 lerpCol = lerp( colorDark.rgb , colorBright , mainCol.r + GetBreathPos() * 0.2 );
                
                float mainIllum = lerp( mainCol.r , max(mainCol.r,max(mainCol.g,mainCol.b)) , _UseSelfColor);
                mainCol.rgb = lerp( lerpCol.rgb , mainCol.rgb , _UseSelfColor);

                

                //------------ main Color ----------------

                float noiseScale = lerp(_NoiseScale , _VirusNoiseScale , _VirusRate > _InfectRate ? 1 : 0 );
                noiseScale = lerp(noiseScale , _HealNoiseScale , _HealRate > _InfectRate ? 1 : 0 ); 
                float noiseSpeed = lerp(_NoiseSpeed , _VirusNoiseSpeed , _VirusRate > _InfectRate ? 1 : 0 );
                noiseSpeed = lerp(noiseSpeed , _HealNoiseSpeed , _HealRate > _InfectRate ? 1 : 0 );

                float2 noiseUV = float2( i.worldPos.x * noiseScale , i.worldPos.y * noiseScale)
                    + sin( _Time.y * noiseSpeed ) * float2(1,0.5)
                    + sin( _Time.y * noiseSpeed * 0.8 + 4 ) * float2(-1,0.5)
                    + sin( _Time.y * noiseSpeed * 0.5 + 7) * float2(0.5,-1);
                    
                fixed4 noiseCol = tex2D( _NoiseTex , noiseUV );
                fixed4 rampColor = tex2D( _ColorfulRamp , noiseCol.rr );
                fixed4 effectColor = ShiftHue( _Color , rampColor );
                fixed4 KangtiColor = lerp( colorDark , fixed4( 1 , 1 , 0 , 1 ) , noiseCol.r * 2 );
                effectColor = lerp( effectColor , KangtiColor , _HealRate );

                mainCol.rgb = lerp( effectColor.rgb , mainCol.rgb , clamp( mainIllum + ( 2 + GetBreathPos()  ) * ( 1 - overlayRate),0,1) );
                //mainCol.rgb = lerp( effectColor.rgb , mainCol.rgb , mainIllum );

                //========== Edge ========== 
                
                float2 edgeNoiseUV1 = float2( i.worldPos.x * _EdgeNoiseScale , i.worldPos.y * _EdgeNoiseScale)
                    + _Time.y * _EdgeNoiseSpeed * float2(1,3);
                float2 edgeNoiseUV2 = float2( i.worldPos.x * _EdgeNoiseScale , i.worldPos.y * _EdgeNoiseScale)
                    + _Time.y * _EdgeNoiseSpeed * 0.7 * float2(-1,2);

                fixed4 edgeNoiseCol1 = tex2D( _NoiseTex , edgeNoiseUV1 );
                fixed4 edgeNoiseCol2 = tex2D( _NoiseTex , edgeNoiseUV2 );

                float edgeAlpha = lerp( ( edgeNoiseCol1.r + edgeNoiseCol2.r ) * 0.5, 0.5 , 1 -  overlayRate ) + edge.r;
                
                edgeAlpha = (edgeAlpha - _EdgeClip > 0 ? 1 : 0 ) * ( edge.r > 0 ? 1 : 0 );
                fixed4 edgeColor = lerp( colorDark , colorBright , 1 - edge.r) ;
                //fixed4 edgeColor = colorDark;

                // combine main and edge
                fixed4 finalColor = lerp( mainCol , edgeColor , edgeAlpha);

                return fixed4( finalColor.rgb , max(edgeAlpha, mainCol.a));
            }
            ENDCG
        }
    }
}
