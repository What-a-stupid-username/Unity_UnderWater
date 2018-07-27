using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawInk : MonoBehaviour {

    public ComputeShader flow_compute;

    public Material flow_material;
    public int resolution = 1024;

    private int FirstStage_HANDLE = -1, SecondStage_HANDLE = -1;
    private RenderTexture flow_texture;
    private ComputeBuffer flow_field_buffer;
    private ComputeBuffer temp_buffer;

    // Use this for initialization
    void Start ()
    {
        FirstStage_HANDLE = flow_compute.FindKernel("FirstStage");
        SecondStage_HANDLE = flow_compute.FindKernel("SecondStage");

        flow_texture = new RenderTexture(resolution, resolution, 24)
        {
            enableRandomWrite = true
        };
        flow_texture.Create();
        flow_material.SetTexture("_MainTex", flow_texture);
        flow_field_buffer = new ComputeBuffer(resolution * resolution, sizeof(float) * 5);
        temp_buffer = new ComputeBuffer(resolution * resolution, sizeof(float) * 5);
        InitFlowFieldBuffer();
        
    }
	
	// Update is called once per frame
	void Update ()
    {
        Flow_field_Info[] ff = new Flow_field_Info[resolution * resolution];
        flow_field_buffer.GetData(ff);
        ff[resolution / 2 + resolution * resolution / 2] = new Flow_field_Info(Vector2.zero, 1000);
        flow_field_buffer.SetData(ff);
        flow_compute.SetBuffer(FirstStage_HANDLE, "flow_field_buffer", flow_field_buffer);
        flow_compute.SetBuffer(FirstStage_HANDLE, "temp_buffer", temp_buffer);
        flow_compute.SetVector("stride", new Vector4(1,resolution,resolution*resolution,resolution*resolution*resolution));
        flow_compute.Dispatch(FirstStage_HANDLE, resolution / 8, resolution / 8, 1);

        flow_compute.SetBuffer(SecondStage_HANDLE, "flow_field_buffer", flow_field_buffer);
        flow_compute.SetBuffer(SecondStage_HANDLE, "temp_buffer", temp_buffer);
        flow_compute.SetTexture(SecondStage_HANDLE, "flow_Texture", flow_texture);
        flow_compute.Dispatch(SecondStage_HANDLE, resolution / 8, resolution / 8, 1);
    }

    void InitFlowFieldBuffer()
    {
        int Init_HANDLE = flow_compute.FindKernel("Init");
        flow_compute.SetBuffer(Init_HANDLE, "flow_field_buffer", flow_field_buffer);
        flow_compute.Dispatch(Init_HANDLE, resolution * resolution / 64, 1, 1);
    }
}

struct Flow_field_Info
{
    Vector2 v,a;
    float density;
    public Flow_field_Info(Vector2 v_in = new Vector2(), float density_in = 1, Vector2 a_in = new Vector2())
    {
        v = v_in;
        a = a_in;
        density = density_in;
    }
}