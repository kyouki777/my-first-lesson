using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class CaretakerAudio : MonoBehaviour //For the heartbeat sound
{
    public Transform player; // assign via spawner or inspector
    public float maxDistance = 20f; // distance where volume is 0
    public float minVolume = 0.1f;  // optional minimum for suspense
    public float maxVolume = 1.8f;    // full volume when very close

    private AudioSource audioSource;

    void Start()
    {
        audioSource = GetComponent<AudioSource>();
        audioSource.loop = true;

        // Start playing immediately
        if (!audioSource.isPlaying)
            audioSource.Play();

        // Auto-find player if not assigned
        if (player == null)
        {
            GameObject playerObj = GameObject.FindGameObjectWithTag("Player");
            if (playerObj != null)
            {
                player = playerObj.transform;
            }
            else
            {
                Debug.LogWarning("[CaretakerAudio] Player not assigned and not found in scene.");
            }
        }
    }

    void Update()
    {
        //if (PauseManager.IsPaused) return;

        if (player == null) return;

        float distance = Vector2.Distance(player.position, transform.position);

        // Smooth volume fade based on distance
        float targetVolume = Mathf.Lerp(minVolume, maxVolume, 1f - Mathf.Clamp01(distance / maxDistance));
        audioSource.volume = Mathf.Lerp(audioSource.volume, targetVolume, Time.deltaTime * 5f);
        
    }
}




/*using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class CaretakerAudio : MonoBehaviour
{
    public Transform player;
    private AudioSource audioSource;

    void Start()
    {
        audioSource = GetComponent<AudioSource>();
    }

    void Update()
    {
        if (player == null) return;

        float distance = Vector2.Distance(player.position, transform.position);
        // Volume decreases as distance increases (smooth fade)
        audioSource.volume = Mathf.Clamp01(1f - (distance / 20f));
    }
}*/
