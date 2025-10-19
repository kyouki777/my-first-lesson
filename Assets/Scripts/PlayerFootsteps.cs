using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class PlayerFootsteps : MonoBehaviour
{
    private BoyMovement playerMovement;
    private AudioSource audioSource;

    void Start()
    {
        playerMovement = GetComponent<BoyMovement>();
        audioSource = GetComponent<AudioSource>();
    }

    void Update()
    {
        // Check if player is moving
        bool isMoving = playerMovement != null && playerMovement.enabled &&
                        (Input.GetAxisRaw("Horizontal") != 0 || Input.GetAxisRaw("Vertical") != 0);

        // Play footsteps only while moving
        if (isMoving && !audioSource.isPlaying)
        {
            audioSource.Play();
        }
        else if (!isMoving && audioSource.isPlaying)
        {
            audioSource.Stop();
        }
    }
}
