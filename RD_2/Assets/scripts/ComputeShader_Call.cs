using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// This is what the data in the voxelField buffer looks like
struct concentrationData {
  public float u;
  public float v;
};


public class ComputeShader_Call : MonoBehaviour
{
    // User-editable references to the compute shader and material with rendering shader
    public Material pointMaterial;
    public ComputeShader computeShader;

    // Declare the buffers for the GPU, and figure out how big their elements are
    private ComputeBuffer voxelField;
    private ComputeBuffer positions;
    int bufferSizeVox = 2 * 4; // float2
    int bufferSizePos = 7 * 4; // float3 pos and float4 color

    static int groupNum = 5;
    static int groupSize = 10;
    static int totalSize = groupNum * groupSize;
    static int totalPoints = totalSize * totalSize * totalSize;

    // The function in the compute shader that we want to call has a specific kernel ID - store it here
    private int kernel;

    void initBuffer() {
      // Figure out what the kernel ID is for the compute function we want to call
      kernel = computeShader.FindKernel("Reaction_Diffusion");
      voxelField = new ComputeBuffer(totalPoints ,bufferSizeVox);
      positions = new ComputeBuffer(totalPoints, bufferSizePos);

      computeShader.SetBuffer(kernel, "states", voxelField);
      computeShader.SetBuffer(kernel, "positions", positions);

    }

    void dispatchKernel() {
      computeShader.Dispatch(kernel, groupNum, groupNum, groupNum);
    }

    void end() {
      voxelField.Release();
      positions.Release();
    }

    void updateConcentrations() {
      concentrationData[,,] concentrations = new concentrationData[totalSize, totalSize, totalSize];
      for (int i = 0; i<totalSize; i++) {
        for (int j = 0; j<totalSize; j++) {
          for (int k = 0; k<totalSize; k++) {
            concentrations[i,j,k].u = 1.0f;
            concentrations[i,j,k].v = 0.0f;
          }
        }
      }
      for (int i = totalSize/2 - 5; i<totalSize/2 + 5; i++) {
        for (int j = totalSize/2 - 5; j<totalSize/2 + 5; j++) {
          for (int k = totalSize/2 - 5; k<totalSize/2 + 5; k++) {
            concentrations[i,j,k].v = 1.0f;
          }
        }
      }
      voxelField.SetData(concentrations);
    }
    // Start is called before the first frame update
    void Start()
    {
      initBuffer();
      updateConcentrations();
      pointMaterial.SetBuffer("points", positions);
    }

    // Update is called once per frame
    void Update()
    {
      dispatchKernel();
    }

    void OnRenderObject() {
      pointMaterial.SetPass(0);
      Graphics.DrawProceduralNow(MeshTopology.Points, totalPoints);
    }
}
