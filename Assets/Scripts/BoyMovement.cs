using System.Collections.Generic;
using UnityEngine;

public class BoyMovement : MonoBehaviour
{
    public float moveSpeed = 1f;
    float collisionOffset = 0.05f;
    public ContactFilter2D movementFilter;

    Vector2 movementInput;
    SpriteRenderer spriteRenderer;
    Rigidbody2D rb;
    Animator animator;
    List<RaycastHit2D> castCollisions = new List<RaycastHit2D>();

    bool canMove = true;

    private void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        spriteRenderer = rb.GetComponent<SpriteRenderer>();
        animator = GetComponent<Animator>(); // 🔹 Make sure you have an Animator component
    }

    void Update()
    {
        movementInput.x = Input.GetAxisRaw("Horizontal");
        movementInput.y = Input.GetAxisRaw("Vertical");

        bool isMoving = movementInput != Vector2.zero;

        if (isMoving)
        {
            Vector2 moveDir = movementInput.normalized;
            TryMoveSliding(moveDir);

            // 🔹 Flip sprite depending on direction
            /*if (movementInput.x < 0)
                spriteRenderer.flipX = false;
            else if (movementInput.x > 0)
                spriteRenderer.flipX = true;*/

        }

        // 🔹 Update animator parameters
        if (animator != null)
        {
            animator.SetBool("isWalking", isMoving);
            animator.SetFloat("moveX", movementInput.x);
            animator.SetFloat("moveY", movementInput.y);
        }
    }


    private void TryMoveSliding(Vector2 direction)
    {
        if (!canMove || direction == Vector2.zero) return;

        if (TryMove(direction))
            return;

        if (TryMove(new Vector2(direction.x, 0)))
            return;

        TryMove(new Vector2(0, direction.y));
    }


    private bool TryMove(Vector2 direction)
    {
        if (direction == Vector2.zero) return false;

        int count = rb.Cast(
            direction,
            movementFilter,
            castCollisions,
            moveSpeed * Time.fixedDeltaTime + collisionOffset
        );

        if (count == 0)
        {
            rb.MovePosition(rb.position + direction * moveSpeed * Time.fixedDeltaTime);
            return true;
        }

        return false;
    }
}
