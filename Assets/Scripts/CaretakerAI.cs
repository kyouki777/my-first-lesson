using UnityEngine;
using Pathfinding;

[RequireComponent(typeof(AIPath), typeof(AIDestinationSetter))]
public class CaretakerAI : MonoBehaviour
{
    [HideInInspector] public Transform player;

    private AIPath aiPath;
    private AIDestinationSetter destinationSetter;
    private Animator animator;
    private bool capturedPlayer = false;
    public AudioClip jumpscareClip;

    // For manual movement when stuck
    private bool forceMoveThroughObstacles = false;
    private float forceMoveSpeed = 3f;

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
            destinationSetter.target = player;

        aiPath.canMove = true;
        capturedPlayer = false;
    }

    void Update()
    {
        if (capturedPlayer || player == null) return;

        if (destinationSetter != null && !forceMoveThroughObstacles)
            destinationSetter.target = player;

        if (animator != null)
            animator.SetFloat("Speed", aiPath.velocity.magnitude);

        if (forceMoveThroughObstacles)
        {
            // Move directly towards the player ignoring pathfinding
            transform.position = Vector3.MoveTowards(transform.position, player.position, forceMoveSpeed * Time.deltaTime);
        }

        // Check if AIPath is stuck
        if (!forceMoveThroughObstacles && aiPath.reachedEndOfPath && Vector3.Distance(transform.position, player.position) > 1f)
        {
            Debug.Log("Path blocked, forcing movement through obstacles...");
            forceMoveThroughObstacles = true;
            aiPath.canMove = false; // temporarily disable AIPath
        }
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

            if (jumpscareClip != null)
                AudioSource.PlayClipAtPoint(jumpscareClip, transform.position);

            if (Computer1.Instance != null)
                Computer1.Instance.CloseComputerUI();

            GameOverManager gameOver = Object.FindAnyObjectByType<GameOverManager>();
            if (gameOver != null)
                gameOver.TriggerGameOver();
        }
    }
}
