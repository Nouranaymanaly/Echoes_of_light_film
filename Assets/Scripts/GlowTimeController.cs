using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class GlowTimeController : MonoBehaviour
{
    public float glowStartTime = 2.0f; // Time after which glow starts
    private Material material;

    void Start()
    {
        material = GetComponent<Renderer>().material;
        material.SetFloat("_GlowStartTime", glowStartTime);
    }

    void Update()
    {
        material.SetFloat("_CurrentTime", Time.time);
    }
}
