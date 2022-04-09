Shader "Unlit/CausticRefractionRayShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "SpecularObj" = "1" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldRefractedRayDirection : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ReceivingPosTexture;
            float4x4 _LightViewProjectionMatrix;
            float3 _LightWorldPosition;
            float _RefractiveIndex;

            float3 VertexEstimateIntersection(float3 specularVertexWorldPos, float3 refractedLightRayDirection, sampler2D positionTexture)
            {
                float3 p1 = specularVertexWorldPos + (1.0 * refractedLightRayDirection);;
                float4 texPt = mul(_LightViewProjectionMatrix, float4(p1, 1));
                float2 tc = 0.5 * texPt.xy / texPt.w + float2(0.5, 0.5);

                float4 recPos = tex2Dlod(_ReceivingPosTexture, float4(tc, 1, 1)); //projected p1 position
                float3 p2 = specularVertexWorldPos + (distance(specularVertexWorldPos, recPos.xzy) * refractedLightRayDirection);
                texPt = mul(_LightViewProjectionMatrix, float4(p2, 1));
                tc = 0.5 * texPt.xy / texPt.w + float2(0.5, 0.5);

                return tex2Dlod(_ReceivingPosTexture, float4(tc, 1, 1)); //projected p2 position
            }

            float3 RefractRay(float3 specularVertexWorldPos, float3 specularVertexWorldNormal)
            {
                float3 vertexToLight = normalize(_LightWorldPosition - specularVertexWorldPos);
                float incidentAngle = dot(vertexToLight, specularVertexWorldNormal);
                float refractionAngle = asin(sin(incidentAngle) / _RefractiveIndex);
                float3 refractedRay = -1 * ((vertexToLight / _RefractiveIndex) + ((cos(asin(sin(incidentAngle) / _RefractiveIndex)) - (cos(incidentAngle) / _RefractiveIndex)) * specularVertexWorldNormal));
                return normalize(refractedRay);
            }

            v2f vert (appdata v)
            {
                v2f o;
                /*float3 specularVertexWorldPos = mul(UNITY_MATRIX_M, v.vertex);
                float3 specularVertexWorldNormal = normalize(mul(transpose(unity_WorldToObject), v.normal));*/
                float3 worldPos = mul(UNITY_MATRIX_M, v.vertex);
                float3 worldNormal = normalize(mul(transpose(unity_WorldToObject), v.normal));
                float3 refractedDirection = RefractRay(worldPos, worldNormal);
                float3 estimatedPosition = VertexEstimateIntersection(worldPos, refractedDirection, _ReceivingPosTexture);

                o.vertex = mul(UNITY_MATRIX_VP, float4(estimatedPosition, 1));
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.worldRefractedRayDirection = refractedDirection;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return float4(i.worldRefractedRayDirection, 1);
                //return float4(1, 1, 1, 1);
            }
            ENDCG
        }
    }
}