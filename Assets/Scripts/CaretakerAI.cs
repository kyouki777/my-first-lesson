using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
public class CaretakerAI2D_Aggressive : MonoBehaviour
{
    public Transform player;
    public float chaseSpeed = 3.5f;
    public float patrolSpeed = 1.5f;
    public float detectionRange = 10f;
    public LayerMask obstacleMask;

    [Header("Unpredictability")]
    public float jitterIntensity = 1.2f;
    public float hesitationChance = 0.02f;

    private Rigidbody2D rb;
    private Vector2 moveDir;
    private Animator animator;
    private bool capturedPlayer = false;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
    }

    void Update()
    {
        if (capturedPlayer) return; // stop moving if captured

        if (!player) return;

        Vector2 dirToPlayer = (player.position - transform.position);
        float distance = dirToPlayer.magnitude;

        bool canSee = CanSeePlayer();

        if (canSee || distance < detectionRange)
        {
            ChasePlayer(dirToPlayer.normalized);
        }
        else
        {
            moveDir = Vector2.zero;
        }

        // Update animator movement direction
        if (animator != null)
        {
            animator.SetFloat("moveX", moveDir.x);
            animator.SetFloat("moveY", moveDir.y);
        }
    }

    void FixedUpdate()
    {
        if (capturedPlayer || moveDir == Vector2.zero) return;

        Vector2 nextPos = rb.position + moveDir * Time.fixedDeltaTime;
        RaycastHit2D hit = Physics2D.Raycast(rb.position, moveDir.normalized,
            moveDir.magnitude * Time.fixedDeltaTime + 0.05f, obstacleMask);

        if (hit.collider != null)
        {
            Vector2 slideDir = Vector2.Perpendicular(hit.normal) *
                               Mathf.Sign(Vector2.Dot(moveDir, Vector2.Perpendicular(hit.normal)));
            rb.MovePosition(rb.position + slideDir * moveDir.magnitude * Time.fixedDeltaTime);
        }
        else
        {
            rb.MovePosition(nextPos);
        }
    }

    bool CanSeePlayer()
    {
        Vector2 dir = (player.position - transform.position).normalized;
        float dist = Vector2.Distance(transform.position, player.position);
        RaycastHit2D hit = Physics2D.Raycast(transform.position, dir, dist, obstacleMask);
        return hit.collider == null;
    }

    void ChasePlayer(Vector2 direction)
    {
        Vector2 jitter = new Vector2(
            Mathf.PerlinNoise(Time.time * 1.5f, 0f) - 0.5f,
            Mathf.PerlinNoise(0f, Time.time * 1.5f) - 0.5f
        ) * jitterIntensity;

        direction += jitter * 0.2f;

        if (Random.value < hesitationChance)
            moveDir = Vector2.zero;
        else
            moveDir = direction.normalized * chaseSpeed;
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.collider.CompareTag("Player"))
        {
            capturedPlayer = true;
            moveDir = Vector2.zero;

            if (animator != null)
                animator.SetBool("CapturedPlayer", true);

            Debug.Log("Caretaker captured the player!");
            Object.FindAnyObjectByType<GameOverManager>().TriggerGameOver();

        }
    }
}
