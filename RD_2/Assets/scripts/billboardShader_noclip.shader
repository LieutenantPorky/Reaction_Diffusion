Shader "Billboard geometry noclip" {
  Properties {
    // Input data from the editor - set billboard size and texture
   _MainTex ("Texture Image", 2D) = "white" {}
   _Scale ("Billboard scale", Float) = 0.5
 }


    SubShader {
      Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
      Blend SrcAlpha OneMinusSrcAlpha
    Pass{
        ZWrite Off
        Cull Off
        CGPROGRAM
        #pragma target 5.0

        // define the render passes for the compiler
        #pragma vertex vert
        #pragma geometry geom
        #pragma fragment frag

        #include "UnityCG.cginc"
        #include "UnityStandardUtils.cginc"

        // Define uniforms for editor Input

        uniform float _Scale;
        uniform sampler2D _MainTex;

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
            float2 tex : TEXCOORD0;
        };

        // This is the vertex shader
        gs_in vert (uint id : SV_VertexID){

            // create an output object
            gs_in output = (gs_in)0;

            // Trasform to camera space

            float3 pos = points[id].pos;
            output.pos = float4(pos,1);
            output.col = points[id].color;
            return output;
        }

        [maxvertexcount(4)]
        void geom(point gs_in input[1], inout TriangleStream<ps_in> triStream){
            ps_in output = (ps_in)0;


            //output quad
            output.col =  input[0].col;
            output.col.a = output.col.r;
            float sizeMul = _Scale * (1 + output.col.r);

            float4 r = input[0].pos - float4(_WorldSpaceCameraPos, 0);
            float3 w = normalize(float3(r.z,0,-1.0 * r.x));
            float3 h = normalize(cross(w,r.xyz));
            float3 start = input[0].pos - (w+h) * sizeMul * 0.5;

            output.pos = UnityObjectToClipPos(start);
            output.tex = float2(0,0);
            triStream.Append(output);

            output.pos = UnityObjectToClipPos(start + w * sizeMul);
            output.tex = float2(1,0);
            triStream.Append(output);

            output.pos = UnityObjectToClipPos(start + h * sizeMul);
            output.tex = float2(0,1);
            triStream.Append(output);

            output.pos = UnityObjectToClipPos(start + (w + h) * sizeMul);
            output.tex = float2(1,1);
            triStream.Append(output);

            triStream.RestartStrip();

        }

        fixed4 frag (ps_in i ) : COLOR0 {
          fixed4 col = i.col;
          if (col.r < 0.1) discard;
          fixed4 tex = tex2D(_MainTex, i.tex);
          return fixed4(0.8 * tex.rgb * clamp(1.5 - col.r, 1.0, 1.5), tex.a * pow(col.a,3));
        }

        ENDCG

        }
    }

    Fallback Off
    }
