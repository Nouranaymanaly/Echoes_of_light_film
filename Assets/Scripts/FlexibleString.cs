using UnityEngine;

[RequireComponent(typeof(LineRenderer))]
public class FlexibleString : MonoBehaviour
{
    public Transform pointA;
    public Transform pointB;
    public int segmentCount = 20;
    public float ropeSlack = 0.5f;
    public float connectDuration = 2f;     // Time to extend rope
    public float delayBeforeAttach = 3f;   // Delay before rope starts

    private LineRenderer line;
    private float timer = 0f;
    private bool ropeStarted = false;

    void Start()
    {
        line = GetComponent<LineRenderer>();
        line.positionCount = segmentCount;

        // Optional: hide line initially
        for (int i = 0; i < segmentCount; i++)
            line.SetPosition(i, pointA.position);
    }

    void Update()
    {
        timer += Time.deltaTime;

        if (!ropeStarted)
        {
            if (timer >= delayBeforeAttach)
            {
                ropeStarted = true;
                timer = 0f; // Reset timer for extension
            }
            return;
        }

        float progress = Mathf.Clamp01(timer / connectDuration);

        Vector3 start = pointA.position;
        Vector3 end = Vector3.Lerp(pointA.position, pointB.position, progress);
        Vector3 middle = (start + end) / 2;

        Vector3 direction = end - start;
        Vector3 up = Vector3.Cross(direction.normalized, Vector3.forward); // Adjust if needed
        middle += up * ropeSlack * progress;

        for (int i = 0; i < segmentCount; i++)
        {
            float t = i / (float)(segmentCount - 1);
            Vector3 point = Mathf.Pow(1 - t, 2) * start +
                            2 * (1 - t) * t * middle +
                            Mathf.Pow(t, 2) * end;
            line.SetPosition(i, point);
        }
    }
}
