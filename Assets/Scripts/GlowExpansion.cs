using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class GlowExpansion : MonoBehaviour
{
    public RadialGlowController glowController;
    public float duration = 3f;
    public float waitTime = 2f;

    private RawImage rawImage;

    void Start()
    {
        rawImage = glowController.GetComponent<RawImage>();
        rawImage.enabled = false; // Hide at start
        StartCoroutine(ExpandGlow());
    }

    IEnumerator ExpandGlow()
    {
        yield return new WaitForSeconds(waitTime);

        rawImage.enabled = true; // Show at the right time

        float start = 0.05f;
        float end = 2.0f;
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = elapsed / duration;

            float radius = Mathf.SmoothStep(start, end, t);
            glowController.SetRadius(radius);

            yield return null;
        }

        glowController.SetRadius(end);
    }
}
