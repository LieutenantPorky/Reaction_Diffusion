Shader "Unlit/pointShader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct data
            {
              float3 pos;
              float4 color;
            };

            StructuredBuffer<data> points;

            struct ps_input {
              float4 pos: SV_POSITION;
              float4 color: COLOR0;
            };

            ps_input vert (uint id : SV_VertexID)
            {
                ps_input o;
                o.pos = mul(UNITY_MATRIX_VP, float4(points[id].pos, 1.0));
                o.color = points[id].color;
                return o;
            }

            fixed4 frag (ps_input i) : COLOR
            {
                fixed4 col = i.color;
                return col;
            }
            ENDCG
        }
    }
}
