Shader "Billboard geometry" {
    SubShader {
      Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
      ZWrite Off
      Blend SrcAlpha OneMinusSrcAlpha

    Pass{

        CGPROGRAM
        #pragma target 5.0

        // define the render passes for the compiler
        #pragma vertex vert
        #pragma geometry geom
        #pragma fragment frag

        #include "UnityCG.cginc"
        #include "UnityStandardUtils.cginc"

        // this is what the data coming out of the compute shader looks like
        struct computeData
        {
          float3 pos;
          float4 color;
        };
        // This references the compute buffer
        StructuredBuffer<computeData> points;


        // What goes into the geometry shader
        struct gs_in {
            float4 pos : SV_POSITION;
            float4 col : COLOR;
        };

        // What goes into the fragment shader
        struct ps_in {
            float4 pos : SV_POSITION;
            float4 col : COLOR;
        };

        // This is the vertex shader
        gs_in vert (uint id : SV_VertexID){

            // create an output object
            gs_in output = (gs_in)0;

            // Trasform to camera space

            float3 pos = points[id].pos;
            output.pos = UnityObjectToClipPos(pos);
            output.col = points[id].color;
            return output;
        }

        [maxvertexcount(4)]
        void geom(point gs_in input[1], inout TriangleStream<ps_in> triStream){
            ps_in output = (ps_in)0;

            float sizeMul = 3.0;

            //output quad
            output.col =  input[0].col;
            output.col.a = output.col.g;

            output.pos = input[0].pos;
            triStream.Append(output);

            output.pos = input[0].pos + float4(0,0.3,0,0) * input[0].col.g * sizeMul;
            triStream.Append(output);

            output.pos = input[0].pos + float4(0.1,0,0,0) * input[0].col.g * sizeMul;
            triStream.Append(output);

            output.pos = input[0].pos + float4(0.1,0.3,0,0) * input[0].col.g * sizeMul;
            triStream.Append(output);

            triStream.RestartStrip();

        }

        fixed4 frag (ps_in i ) : COLOR0 {
          fixed4 col = i.col;
          if (col.g < 0.1) discard;
          return col;
        }

        ENDCG

        }
    }

    Fallback Off
    }
