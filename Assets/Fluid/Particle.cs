using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Particle : MonoBehaviour {

    public Material flow_material;
    public Texture noice_texture;

    public ComputeShader particle_compute;

    public int count = 10000;

    private ComputeBuffer particle_buffer, switch_buffer;
    private RenderTexture flow_texture;

    int Cal_HANDLE = -1, Init_HANDLE = -1, Blur_HANDLE = -1;

	// Use this for initialization
	void Start () {
        flow_texture = new RenderTexture(1024, 1024, 24);
        flow_texture.enableRandomWrite = true;
        flow_texture.filterMode = FilterMode.Trilinear;
        flow_texture.Create();
        flow_material.SetTexture("_MainTex", flow_texture);
        particle_buffer = new ComputeBuffer(count, sizeof(float) * 6);
        switch_buffer = new ComputeBuffer(count, sizeof(float) * 6);
        Cal_HANDLE = particle_compute.FindKernel("Cal");
        particle_compute.SetTexture(Cal_HANDLE, "noice_texture", noice_texture);
        Init_HANDLE = particle_compute.FindKernel("Init");
        particle_compute.SetInt("count", count);
        particle_compute.SetBuffer(Init_HANDLE, "particle_buffer", particle_buffer);
        particle_compute.SetTexture(Init_HANDLE, "noice_texture", noice_texture);
        particle_compute.Dispatch(Init_HANDLE, count / 64 + 1, 1, 1);
        //Blur_HANDLE = particle_compute.FindKernel("Blur");
        PostRenderEvent.AddEvent(Camera.main, aaa);
    }

    bool flag = true;
	// Update is called once per frame
	void Update ()
    {
        particle_compute.SetInt("count", count);
        if (flag)
        {
            flag = !flag;
            particle_compute.SetBuffer(Cal_HANDLE, "particle_buffer", particle_buffer);
            particle_compute.SetBuffer(Cal_HANDLE, "switch_buffer", switch_buffer);
        }
        else
        {
            flag = !flag;
            particle_compute.SetBuffer(Cal_HANDLE, "particle_buffer", switch_buffer);
            particle_compute.SetBuffer(Cal_HANDLE, "switch_buffer", particle_buffer);
        }
        particle_compute.Dispatch(Cal_HANDLE, count / 64 + 1, 1, 1);
    }

    void aaa(Camera camera)
    {
        flow_material.SetBuffer("particle_buffer", particle_buffer);
        flow_material.SetPass(0);

        Graphics.DrawProcedural(MeshTopology.Points, particle_buffer.count);
    }


    struct Info
    {
        Vector3 pos, v;
    }
}
