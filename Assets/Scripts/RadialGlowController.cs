using UnityEngine;

[RequireComponent(typeof(UnityEngine.UI.RawImage))]
public class RadialGlowController : MonoBehaviour
{
    public Transform mainCharacter; // drag your Main Character here
    public Camera mainCamera; // your scene camera
    private Material mat;

    void Start()
    {
        mat = GetComponent<UnityEngine.UI.RawImage>().material;
    }

    void Update()
    {
        Vector3 screenPos = mainCamera.WorldToViewportPoint(mainCharacter.position);
        mat.SetVector("_Center", new Vector4(screenPos.x, screenPos.y, 0, 0));
    }

    public void SetRadius(float r) => mat.SetFloat("_Radius", r);
}
