using System.Collections.Generic;
using UnityEngine;

public class BoyMovement : MonoBehaviour
{
    public float moveSpeed = 1f;
    float collisionOffset = 0.05f;
    public ContactFilter2D movementFilter;

    Vector2 movementInput;
    Vector2 lastMoveDir; // 🔹 Remember last direction moved
    SpriteRenderer spriteRenderer;
    Rigidbody2D rb;
    Animator animator;
    List<RaycastHit2D> castCollisions = new List<RaycastHit2D>();

    bool canMove = true;

    private void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        spriteRenderer = rb.GetComponent<SpriteRenderer>();
        animator = GetComponent<Animator>();
    }

    void Update()
    {
        //if (PauseManager.IsPaused)
            //return;


        movementInput.x = Input.GetAxisRaw("Horizontal");
        movementInput.y = Input.GetAxisRaw("Vertical");

        bool isMoving = movementInput != Vector2.zero;

        if (isMoving)
        {
            Vector2 moveDir = movementInput.normalized;
            TryMoveSliding(moveDir);

            // 🔹 Store the last non-zero direction
            lastMoveDir = movementInput;

            // 🔹 Flip sprite horizontally if needed
            /*if (movementInput.x < 0)
                spriteRenderer.flipX = false;
            else if (movementInput.x > 0)
                spriteRenderer.flipX = true;*/
        }

        // 🔹 Update animator parameters
        if (animator != null)
        {
            animator.SetBool("isWalking", isMoving);
            animator.SetFloat("moveX", isMoving ? movementInput.x : lastMoveDir.x);
            animator.SetFloat("moveY", isMoving ? movementInput.y : lastMoveDir.y);
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
