using System.Collections;
using System.Collections.Generic;
using UnityEngine;

struct concentrationData {
  public float u;
  public float v;
};


public class ComputeShader_Call : MonoBehaviour
{
    public Shader pointShader;
    private Material pointMaterial;
    public ComputeShader computeShader;

    private ComputeBuffer voxelField;
    private ComputeBuffer positions;
    int bufferSizeVox = 2 * 4; // float2
    int bufferSizePos = 7 * 4; // float3 pos and float4 color

    static int groupNum = 5;
    static int groupSize = 10;
    static int totalSize = groupNum * groupSize;
    static int totalPoints = totalSize * totalSize * totalSize;


    private int kernel;

    void initBuffer() {
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
      for (int i = 22; i<28; i++) {
        for (int j = 22; j<28; j++) {
          for (int k = 22; k<28; k++) {
            concentrations[i,j,k].u = 1.0f;
            concentrations[i,j,k].v = 0.5f;
          }
        }
      }
      voxelField.SetData(concentrations);
    }
    // Start is called before the first frame update
    void Start()
    {
      pointMaterial = new Material(pointShader);
      initBuffer();
      updateConcentrations();
      pointMaterial.SetBuffer("points", positions);
    }

    // Update is called once per frame
    void Update()
    {

    }

    void OnRenderObject() {
      dispatchKernel();
      pointMaterial.SetPass(0);
      Graphics.DrawProceduralNow(MeshTopology.Points, totalPoints);
    }
}
