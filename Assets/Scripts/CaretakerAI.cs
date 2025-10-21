using UnityEngine;
using System.Collections;
using Pathfinding; // For A* Pathfinding components

[RequireComponent(typeof(AIPath), typeof(AIDestinationSetter))]
public class CaretakerAI : MonoBehaviour
{
    [HideInInspector] public Transform player; // assigned by spawner

    private AIPath aiPath;
    private AIDestinationSetter destinationSetter;
    private Animator animator;
    private bool capturedPlayer = false;
    public AudioClip jumpscareClip;


    void Awake()
    {
        aiPath = GetComponent<AIPath>();
        destinationSetter = GetComponent<AIDestinationSetter>();
        animator = GetComponent<Animator>();
    }

    // Called by CaretakerSpawner right after spawning
    public void Initialize(Transform target)
    {
        player = target;
        if (destinationSetter != null)
        {
            destinationSetter.target = player;
        }

        aiPath.canMove = true;
        capturedPlayer = false;

        // Start reappear cycle
        StartCoroutine(DisappearAndReappearRoutine());
    }

    void Update()
    {
        if (capturedPlayer || player == null) return;

        // Continuously follow the player
        if (destinationSetter != null)
            destinationSetter.target = player;

        // Animate speed
        if (animator != null)
            animator.SetFloat("Speed", aiPath.velocity.magnitude);
    }

    private void OnTriggerEnter2D(Collider2D other)
    {
        if (capturedPlayer) return;

        if (other.CompareTag("Player"))
        {
            capturedPlayer = true;
            aiPath.canMove = false;

            if (animator != null)
                animator.SetBool("CapturedPlayer", true);

            Debug.Log("Caretaker captured the player (trigger)!");

            // Play jumpscare sound
            if (jumpscareClip != null)
                AudioSource.PlayClipAtPoint(jumpscareClip, transform.position);

            // Close computer UI if open
            if (Computer1.Instance != null)
                Computer1.Instance.CloseComputerUI();

            // Trigger Game Over
            GameOverManager gameOver = Object.FindAnyObjectByType<GameOverManager>();
            if (gameOver != null)
                gameOver.TriggerGameOver();
        }
    }



    IEnumerator DisappearAndReappearRoutine()
    {
        while (!capturedPlayer)
        {
            // Wait before disappearing (30–180 sec)
            float waitTime = Random.Range(30f, 180f);
            yield return new WaitForSeconds(waitTime);

            // Disappear
            aiPath.canMove = false;
            gameObject.SetActive(false);
            Debug.Log("Caretaker disappeared...");

            // Wait before reappearing (15–45 sec)
            float hiddenTime = Random.Range(15f, 45f);
            yield return new WaitForSeconds(hiddenTime);

            // Reappear at a random spawn point
            CaretakerSpawner spawner = Object.FindAnyObjectByType<CaretakerSpawner>();
            if (spawner != null && spawner.spawnPoints.Length > 0)
            {
                Transform newSpot = spawner.spawnPoints[Random.Range(0, spawner.spawnPoints.Length)];
                transform.position = newSpot.position;
            }

            gameObject.SetActive(true);
            aiPath.canMove = true;
            Debug.Log("Caretaker reappeared!");
        }
    }
}
