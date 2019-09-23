Shader "Unlit/pointShader"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag
            //#pragma geometry geom

            #include "UnityCG.cginc"

            struct computeData
            {
              float3 pos;
              float4 color;
            };

            StructuredBuffer<computeData> points;

            struct ps_input {
              float4 pos: SV_POSITION;
              float4 color: COLOR0;
            };

            struct gs_input {
              float4 pos: SV_POSITION;
              float4 color: COLOR0;
            };

// Vertex shader - get position and concentrations from computeShader buffer, return world pos and color
            gs_input vert (uint id : SV_VertexID)
            {
                gs_input o;
                o.pos = mul(UNITY_MATRIX_VP, float4(points[id].pos, 1.0));
                o.color = points[id].color;
                return o;
            }

            // Generate a billboard using a geometry Shader

            [maxvertexcount(3)]
            void geom(point gs_input input[1], inout TriangleStream<ps_input> triStream){
              ps_input o;
              o.color = input[0].color;

              o.pos = input[0].pos + float4(10,0,0,0);
              triStream.Append(o);

          }

            fixed4 frag (gs_input i) : COLOR0
            {
                fixed4 col = i.color;
                //if (col.g < 0.5) discard;
                return col;
            }
            ENDCG
        }
    }
}
