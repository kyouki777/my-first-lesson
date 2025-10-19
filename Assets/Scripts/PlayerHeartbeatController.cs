using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class PlayerHeartbeat : MonoBehaviour
{
    [Header("Heartbeat Settings")]
    public Transform caretaker; // assigned by your CaretakerSpawner
    public float maxDistance = 10f;  // distance at which heartbeat is quietest
    public float minVolume = 0.1f;   // quietest volume
    public float maxVolume = 1.0f;   // loudest when very close

    private AudioSource heartbeatSource;

    void Start()
    {
        heartbeatSource = GetComponent<AudioSource>();
    }

    void Update()
    {
        if (caretaker == null)
        {
            // fade out if caretaker not around
            if (heartbeatSource.volume > 0)
                heartbeatSource.volume = Mathf.Lerp(heartbeatSource.volume, 0, Time.deltaTime * 2);
            Debug.Log("caretaker not here");
               
            return;
        }

        float distance = Vector2.Distance(transform.position, caretaker.position);

        // normalize distance (closer = louder)
        float t = Mathf.InverseLerp(maxDistance, 0f, distance);
        float targetVolume = Mathf.Lerp(minVolume, maxVolume, t);

        // smooth fade to prevent sudden jumps
        heartbeatSource.volume = Mathf.Lerp(heartbeatSource.volume, targetVolume, Time.deltaTime * 5);
    }
}
