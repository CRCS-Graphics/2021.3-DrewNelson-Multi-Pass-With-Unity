/*
* Simple shader which is used on items that should be considered specular objects.
* The primary difference between this shader and a basic unlit shader is the use of the 
* "SpecularObj" tag in the shader.
*/
Shader "Unlit/SpecularObjectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        /*
        * Note: The parameters below are not actually used here. Rather, they are picked up
        * by the replacement shaders that are rendering the same object.
        */
        _ObjectRefractionIndex ("Refraction Index", Float) = 1.0
        _AbsorbtionCoefficient ("Absorbtion Coefficient", Float) = 0.00017
        _SpecularColorFactor ("Specular Color Factor (0-1)", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "SpecularObj" = "1" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
