using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// Define a struct to hold the datatype passed to the compute shader

struct concentrations {
  public float u;
  public float v;
  public float w;
}


public class Main : MonoBehaviour
{
    public ComputeShader GrayScott;
    Material particleMat;
    public Shader particleShader;

    private static int size = 3 * 4; // struct contains 2 floats (4-byte values)
    // Start is called before the first frame update

    public static int groupSize = 3;
    public static int groupNum = 1;


    private int arraySize = (groupNum * groupSize);

    private int kernel;
    void Start()
    {
      particleMat = new Material(particleShader);


      concentrations[,,] concentrationArray = new concentrations[arraySize,arraySize, arraySize];


      // Find the kernel indexed in the compute shader code
      kernel = GrayScott.FindKernel("RD");
      Debug.Log("Kernel ID: " + kernel.ToString());
      ComputeBuffer buffer = new ComputeBuffer(arraySize * arraySize * arraySize, size);
      buffer.SetData(concentrationArray);
      // Bind the buffer
      GrayScott.SetBuffer(kernel, "dataBuffer", buffer); // Note in the future use property ID instead of string "dataBuffer" for efficiency

      // execute the ComputeShader
      GrayScott.Dispatch(kernel,groupNum,groupNum,groupNum);

      // Output needs to be blitted into memory, so initialise an output array
      concentrations[,,] output = new concentrations [arraySize,arraySize, arraySize];
      buffer.GetData(output);

      for (int i = 0; i<arraySize; i++) {
        for (int j = 0; j<arraySize; j++) {
          for (int k = 0; k<arraySize; k++) {
            Debug.Log("u: " + (output[i,j,k].u.ToString()) + " v: " + (output[i,j,k].v.ToString())+ " w: " + (output[i,j,k].w.ToString()));
          }
        }
      }

      buffer.Release();
    }

    void OnRenderObject(){
      CommandBuffer.DrawProcedural(Matrix4x4.identity, particleMat, -1, MeshTopology.Quads, 4);
    }

}
